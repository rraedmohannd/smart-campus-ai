import json
from typing import Dict, List, Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.config import OPENAI_API_KEY
from app.knowledge.bus_data import bus_data
from app.knowledge.library_data import library_data
from app.knowledge.rules_data import university_rules_data

try:
    from openai import OpenAI
except Exception:  # pragma: no cover - the fallback still serves chat without OpenAI.
    OpenAI = None

try:
    from app.knowledge.campus_data import university_data
except Exception:
    university_data = {}

router = APIRouter()

client = OpenAI(api_key=OPENAI_API_KEY) if OpenAI and OPENAI_API_KEY else None
session_memory: Dict[str, List[dict]] = {}

SYSTEM_PROMPT = """
You are Smart Campus AI Assistant for Middle East University in Amman, Jordan.
Answer only campus-related questions about buses, library services, university
rules, registration, exams, attendance, and general campus services. Keep
answers clear, concise, and helpful. If the user asks in Arabic, answer in
Arabic. If the information is not available in project data, say so plainly.
"""


class ChatRequest(BaseModel):
    message: Optional[str] = None
    question: Optional[str] = None
    session_id: Optional[str] = "default"
    student_id: Optional[str] = None
    user_id: Optional[str] = None


class ChatResponse(BaseModel):
    reply: str
    session_id: str
    used_context: bool
    response: str
    answer: str


def normalize_text(text: str) -> str:
    return (text or "").strip().lower()


def detect_arabic(text: str) -> bool:
    return any("\u0600" <= ch <= "\u06FF" for ch in text)


def trim_memory(messages: List[dict], max_items: int = 12) -> List[dict]:
    return messages[-max_items:]


def build_knowledge_chunks() -> List[dict]:
    chunks = [
        {"source": "bus", "data": bus_data, "text": json.dumps(bus_data, ensure_ascii=False)},
        {
            "source": "library",
            "data": library_data,
            "text": json.dumps(library_data, ensure_ascii=False),
        },
        {
            "source": "rules",
            "data": university_rules_data,
            "text": json.dumps(university_rules_data, ensure_ascii=False),
        },
    ]
    if university_data:
        chunks.append(
            {
                "source": "university",
                "data": university_data,
                "text": json.dumps(university_data, ensure_ascii=False),
            }
        )
    return chunks


def score_chunk(query: str, text: str) -> int:
    query = normalize_text(query)
    text = normalize_text(text)
    score = 0

    keyword_groups = {
        "library": ["library", "book", "borrow", "return", "study", "مكتبة", "كتاب"],
        "bus": ["bus", "route", "transport", "shuttle", "departure", "باص", "حافلة"],
        "rules": ["rules", "policy", "attendance", "exam", "regulation", "قوانين", "امتحان"],
        "university": ["university", "faculty", "major", "campus", "جامعة", "كلية"],
    }

    for words in keyword_groups.values():
        for word in words:
            if word in query and word in text:
                score += 3

    for word in query.replace("?", " ").replace(",", " ").split():
        if len(word) >= 3 and word in text:
            score += 1

    return score


def retrieve_context(user_message: str, top_k: int = 3) -> List[dict]:
    scored = []
    for chunk in build_knowledge_chunks():
        score = score_chunk(user_message, chunk["text"])
        if score > 0:
            scored.append({**chunk, "score": score})
    scored.sort(key=lambda item: item["score"], reverse=True)
    return scored[:top_k]


def build_context_block(retrieved_chunks: List[dict]) -> str:
    if not retrieved_chunks:
        return "No directly matching campus context was found."
    return "\n\n".join(
        f"[{item['source']}]\n{item['text']}" for item in retrieved_chunks
    )


def fallback_reply(message: str, retrieved_chunks: List[dict]) -> str:
    arabic = detect_arabic(message)
    query = normalize_text(message)
    sources = {item["source"] for item in retrieved_chunks}

    if "library" in sources or any(word in query for word in ["library", "book", "مكتبة"]):
        hours = library_data.get("working_hours", {})
        weekday_hours = hours.get("Sunday-Thursday", "08:00 - 18:00")
        if arabic:
            return f"المكتبة متاحة من الأحد إلى الخميس خلال {weekday_hours}. يمكنك البحث عن الكتب وحالة توفرها من شاشة المكتبة."
        return f"The library is available Sunday to Thursday during {weekday_hours}. You can search books and availability from the Library screen."

    if "bus" in sources or any(word in query for word in ["bus", "route", "transport", "shuttle", "باص"]):
        if arabic:
            return "افتح شاشة Smart Bus لعرض الباصات الحية، المسار، السائق، الوقت المتوقع، المقاعد المتاحة، ونسبة الإشغال."
        return "Open Smart Bus to see live buses, route, driver, ETA, available seats, and occupancy from the database."

    if "rules" in sources or any(word in query for word in ["rule", "policy", "exam", "attendance", "قوانين"]):
        if arabic:
            return "يمكنك مراجعة شاشة Rules للسياسات الجامعية مثل الحضور والامتحانات والتسجيل. إذا أردت، اسألني عن سياسة محددة."
        return "You can review campus policies in the Rules screen, including attendance, exams, and registration. Ask me about a specific policy for a focused answer."

    if retrieved_chunks:
        source_names = ", ".join(item["source"] for item in retrieved_chunks)
        if arabic:
            return f"وجدت معلومات جامعية مرتبطة في قسم {source_names}. اطرح السؤال بتفصيل أكثر لأعطيك إجابة أدق."
        return f"I found related campus information in {source_names}. Ask with a little more detail and I can narrow it down."

    if arabic:
        return "أنا مساعد Smart Campus AI. أستطيع مساعدتك في الباصات، المكتبة، القوانين الجامعية، والحضور أو الامتحانات."
    return "I am Smart Campus AI. I can help with buses, library services, university rules, attendance, exams, and campus information."


def request_text(request: ChatRequest) -> str:
    return (request.message or request.question or "").strip()


@router.get("/")
def chat_status():
    return {"message": "Chat service is running"}


@router.post("/", response_model=ChatResponse)
def chat_with_ai(request: ChatRequest):
    user_message = request_text(request)
    if not user_message:
        raise HTTPException(
            status_code=422,
            detail="Field 'message' or 'question' is required and cannot be empty",
        )

    session_id = request.session_id or "default"
    session_memory.setdefault(session_id, [])

    retrieved = retrieve_context(user_message, top_k=3)
    used_context = bool(retrieved)
    reply = ""

    if client:
        messages = [
            {"role": "system", "content": SYSTEM_PROMPT},
            {
                "role": "system",
                "content": (
                    "Use this project context when relevant:\n"
                    f"{build_context_block(retrieved)}"
                ),
            },
            *trim_memory(session_memory[session_id], max_items=10),
            {"role": "user", "content": user_message},
        ]
        try:
            response = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=messages,
                temperature=0.4,
                max_tokens=500,
            )
            reply = response.choices[0].message.content or ""
        except Exception:
            reply = ""

    if not reply.strip():
        reply = fallback_reply(user_message, retrieved)

    session_memory[session_id].append({"role": "user", "content": user_message})
    session_memory[session_id].append({"role": "assistant", "content": reply})
    session_memory[session_id] = trim_memory(session_memory[session_id], max_items=12)

    return ChatResponse(
        reply=reply,
        response=reply,
        answer=reply,
        session_id=session_id,
        used_context=used_context,
    )


@router.get("/history/{session_id}")
def get_chat_history(session_id: str):
    history = session_memory.get(session_id, [])
    return {
        "session_id": session_id,
        "messages": [
            {
                "role": item.get("role", "unknown"),
                "message": item.get("content", ""),
                "text": item.get("content", ""),
            }
            for item in history
        ],
    }


@router.delete("/history/{session_id}")
def clear_chat_history(session_id: str):
    session_memory.pop(session_id, None)
    return {"message": f"History cleared for session '{session_id}'"}
