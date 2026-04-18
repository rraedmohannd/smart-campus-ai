from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from app.db import get_db
from app.models.models import Student
from app.services.auth_service import verify_password, hash_password, create_access_token

router = APIRouter()


class LoginRequest(BaseModel):
    student_id: str
    password: str


class RegisterRequest(BaseModel):
    student_id: str
    name: str
    email: str
    password: str
    department: Optional[str] = None


class AuthResponse(BaseModel):
    token: str
    student_id: str
    name: str
    department: Optional[str]


@router.post("/login", response_model=AuthResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    student = db.query(Student).filter(Student.student_id == request.student_id).first()
    if not student:
        raise HTTPException(status_code=401, detail="Student ID not found")
    if not verify_password(request.password, student.password):
        raise HTTPException(status_code=401, detail="Incorrect password")

    token = create_access_token({"sub": student.student_id})

    return AuthResponse(
        token=token,
        student_id=student.student_id,
        name=student.name,
        department=student.department
    )


@router.post("/register", response_model=AuthResponse)
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(Student).filter(
        (Student.student_id == request.student_id) | (Student.email == request.email)
    ).first()

    if existing:
        raise HTTPException(status_code=400, detail="Student ID or email already registered")

    student = Student(
        student_id=request.student_id,
        name=request.name,
        email=request.email,
        password=hash_password(request.password),
        department=request.department,
    )

    db.add(student)
    db.commit()
    db.refresh(student)

    token = create_access_token({"sub": student.student_id})

    return AuthResponse(
        token=token,
        student_id=student.student_id,
        name=student.name,
        department=student.department
    )