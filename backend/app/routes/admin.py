from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.models import (
    Book,
    Bus,
    Notification,
    StudentProfile,
    User,
)

router = APIRouter()


class UserPayload(BaseModel):
    name: str | None = None
    full_name: str | None = None
    university_id: str | None = None
    email: str | None = None
    password: str | None = None
    role: str = "student"
    is_active: bool | None = None


class NotificationPayload(BaseModel):
    title: str
    message: str
    type: str | None = "general"
    user_id: int | None = None


def _clean(value: str | None) -> str | None:
    if value is None:
        return None
    value = value.strip()
    return value or None


def _profile_for(db: Session, user_id: int) -> StudentProfile | None:
    return db.query(StudentProfile).filter(StudentProfile.user_id == user_id).first()


def user_to_dict(user: User, profile: StudentProfile | None = None):
    profile_data = None
    if profile:
        profile_data = {
            "id": profile.id,
            "full_name": profile.full_name,
            "name": profile.full_name,
            "department": profile.department,
            "major": profile.major,
            "gpa": float(profile.gpa) if profile.gpa is not None else None,
            "credits_completed": profile.credits_completed,
            "total_credits": profile.total_credits,
            "class_rank": profile.class_rank,
            "academic_status": profile.academic_status,
            "avatar_url": profile.avatar_url,
        }

    return {
        "id": user.id,
        "user_id": user.id,
        "university_id": user.university_id,
        "student_id": user.university_id,
        "email": user.email,
        "role": user.role,
        "is_active": user.is_active,
        "name": profile.full_name if profile else (user.email or user.university_id),
        "full_name": profile.full_name if profile else None,
        "profile": profile_data,
        "created_at": user.created_at,
    }


@router.get("/dashboard")
def dashboard(db: Session = Depends(get_db)):
    total_users = db.query(User).count()
    active_users = db.query(User).filter(User.is_active.is_(True)).count()
    students = db.query(User).filter(User.role == "student").count()
    alerts = db.query(Notification).filter(Notification.is_read.is_(False)).count()

    return {
        "users": total_users,
        "active_users": active_users,
        "students": students,
        "ai_requests": 0,
        "alerts": alerts,
        "books": db.query(Book).count(),
        "buses": db.query(Bus).count(),
    }


@router.get("/users")
def list_users(db: Session = Depends(get_db)):
    users = db.query(User).order_by(User.id.asc()).all()
    return [user_to_dict(user, _profile_for(db, user.id)) for user in users]


@router.post("/users")
def create_user(payload: UserPayload, db: Session = Depends(get_db)):
    role = _clean(payload.role.lower()) or "student"
    email = _clean(payload.email)
    university_id = _clean(payload.university_id)
    password = _clean(payload.password) or "pass123"
    name = _clean(payload.full_name) or _clean(payload.name)

    if role == "student" and not university_id:
        next_id = (db.query(User).filter(User.role == "student").count() + 1)
        university_id = f"STU{next_id:03d}"

    if role != "student" and not email:
        raise HTTPException(status_code=422, detail="Email is required for staff users")

    if email and db.query(User).filter(User.email == email).first():
        raise HTTPException(status_code=409, detail="Email already exists")
    if university_id and db.query(User).filter(User.university_id == university_id).first():
        raise HTTPException(status_code=409, detail="University ID already exists")

    user = User(
        university_id=university_id,
        email=email,
        password_hash=password,
        role=role,
        is_active=True if payload.is_active is None else payload.is_active,
    )
    db.add(user)
    db.flush()

    profile = None
    if role == "student":
        profile = StudentProfile(
            user_id=user.id,
            full_name=name or "Student",
            academic_status="ACTIVE",
        )
        db.add(profile)

    db.commit()
    db.refresh(user)
    if profile:
        db.refresh(profile)

    return user_to_dict(user, profile)


@router.put("/users/{user_id}")
def update_user(user_id: int, payload: UserPayload, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    updates = payload.model_dump(exclude_unset=True)
    if "role" in updates:
        user.role = (_clean(payload.role.lower()) or user.role)
    if "email" in updates:
        user.email = _clean(payload.email)
    if "university_id" in updates:
        user.university_id = _clean(payload.university_id)
    if "password" in updates and _clean(payload.password):
        user.password_hash = _clean(payload.password)
    if "is_active" in updates and payload.is_active is not None:
        user.is_active = payload.is_active

    profile = _profile_for(db, user.id)
    name = _clean(payload.full_name) or _clean(payload.name)
    if user.role == "student" and name:
        if profile:
            profile.full_name = name
        else:
            profile = StudentProfile(user_id=user.id, full_name=name)
            db.add(profile)

    db.commit()
    db.refresh(user)
    if profile:
        db.refresh(profile)
    return user_to_dict(user, profile)


@router.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(user)
    db.commit()
    return {"message": "User deleted successfully"}


@router.get("/students")
def list_students(db: Session = Depends(get_db)):
    students = db.query(User).filter(User.role == "student").order_by(User.id.asc()).all()
    return [user_to_dict(user, _profile_for(db, user.id)) for user in students]


@router.post("/notifications")
def create_notification(payload: NotificationPayload, db: Session = Depends(get_db)):
    notification = Notification(
        user_id=payload.user_id,
        title=payload.title.strip(),
        message=payload.message.strip(),
        type=(payload.type or "general").strip().lower() or "general",
    )
    if not notification.title or not notification.message:
        raise HTTPException(status_code=422, detail="Title and message are required")

    db.add(notification)
    db.commit()
    db.refresh(notification)

    return {
        "id": notification.id,
        "user_id": notification.user_id,
        "title": notification.title,
        "message": notification.message,
        "type": notification.type,
        "is_read": notification.is_read,
        "created_at": notification.created_at,
    }
