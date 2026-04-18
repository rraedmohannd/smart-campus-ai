from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from app.db import get_db
from app.models.models import ChatSession
from app.services.ai_service import get_ai_response

router = APIRouter()


# ✅ Schema للطلب
class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = "default"
    student_id: Optional[str] = None

    class Config:
        schema_extra = {
            "example": {
                "message": "hi",
                "session_id": "default",
                "student_id": "12345"
            }
        }


# ✅ Schema للرد
class ChatResponse(BaseModel):
    reply: str


# ✅ Endpoint لفحص حالة السيرفر
@router.get("/")
def chat_status():
    return {"message": "Chat service is running"}


# ✅ Endpoint رئيسي للمحادثة مع الذكاء الاصطناعي
@router.post("/", response_model=ChatResponse)
def chat_with_ai(request: ChatRequest, db: Session = Depends(get_db)):
    # منع الخطأ 422 إذا الحقل message ناقص أو فاضي
    if not request.message or request.message.strip() == "":
        raise HTTPException(status_code=422, detail="Field 'message' is required and cannot be empty")

    try:
        # استدعاء خدمة الذكاء الاصطناعي
        reply = get_ai_response(request.message, request.session_id)
    except Exception as e:
        # منع الخطأ 500 الغامض وإرجاع رسالة واضحة
        raise HTTPException(status_code=500, detail=f"AI service error: {str(e)}")

    # إذا فيه student_id، نخزن المحادثة في قاعدة البيانات
    if request.student_id:
        db.add(ChatSession(
            student_id=request.student_id,
            message=request.message,
            response=reply
        ))
        db.commit()

    return ChatResponse(reply=reply)


# ✅ Endpoint لإرجاع سجل المحادثات حسب الطالب
@router.get("/history/{student_id}")
def get_chat_history(student_id: str, db: Session = Depends(get_db)):
    history = (
        db.query(ChatSession)
        .filter(ChatSession.student_id == student_id)
        .order_by(ChatSession.timestamp.asc())
        .all()
    )

    return [
        {
            "message": h.message,
            "response": h.response,
            "timestamp": h.timestamp
        }
        for h in history
    ]
