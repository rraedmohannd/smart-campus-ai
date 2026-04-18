from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.demo_data import demo_users

router = APIRouter()

class LoginIn(BaseModel):
    student_id: str
    password: str

@router.post("/login")
def login(payload: LoginIn):
    user = next(
        (u for u in demo_users if u["student_id"] == payload.student_id and u["password"] == payload.password),
        None
    )
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return {
        "message": "Login successful",
        "student_id": user["student_id"],
        "name": user["name"],
        "email": user["email"],
        "token": f"demo_token_{user['student_id']}"
    }
