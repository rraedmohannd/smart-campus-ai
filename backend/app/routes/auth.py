from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.models import User, StudentProfile

router = APIRouter()


class LoginRequest(BaseModel):
    identifier: str
    password: str
    role: str


@router.post("/login")
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    role = payload.role.lower().strip()
    identifier = payload.identifier.strip()
    password = payload.password.strip()

    if role == "student":
        user = (
            db.query(User)
            .filter(User.university_id == identifier, User.role == "student")
            .first()
        )
    else:
        user = (
            db.query(User)
            .filter(User.email == identifier, User.role == role)
            .first()
        )

    if not user or user.password_hash != password:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account is inactive")

    profile = None
    if user.role == "student":
        profile = (
            db.query(StudentProfile)
            .filter(StudentProfile.user_id == user.id)
            .first()
        )

    return {
        "message": "Login successful",
        "token": f"demo_token_{user.id}",
        "user": {
            "id": user.id,
            "university_id": user.university_id,
            "email": user.email,
            "role": user.role,
            "is_active": user.is_active,
            "profile": {
                "full_name": profile.full_name,
                "department": profile.department,
                "major": profile.major,
                "gpa": float(profile.gpa) if profile and profile.gpa is not None else None,
                "credits_completed": profile.credits_completed,
                "total_credits": profile.total_credits,
                "class_rank": profile.class_rank,
                "academic_status": profile.academic_status,
            } if profile else None
        }
    }