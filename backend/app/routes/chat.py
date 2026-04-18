from fastapi import APIRouter
from pydantic import BaseModel
from app.demo_data import demo_chat_fallbacks

router = APIRouter()

class ChatIn(BaseModel):
    message: str
    student_id: str
    session_id: str

@router.post("/")
def chat(payload: ChatIn):
    msg = payload.message.lower()

    if "library" in msg:
        return {"reply": demo_chat_fallbacks["library"]}
    elif "bus" in msg or "transport" in msg:
        return {"reply": demo_chat_fallbacks["bus"]}
    elif "rule" in msg or "attendance" in msg or "exam" in msg:
        return {"reply": demo_chat_fallbacks["rules"]}
    elif "admission" in msg or "register" in msg:
        return {"reply": demo_chat_fallbacks["admission"]}
    else:
        return {"reply": demo_chat_fallbacks["default"]}
