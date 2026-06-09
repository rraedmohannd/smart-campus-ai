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
You are **Smart Campus AI**, the official intelligent assistant of **Middle East University (MEU), Jordan**.

Your identity and responsibilities are strictly defined as follows:

## Identity

* You are the official AI assistant developed specifically for Middle East University (MEU) in Jordan.
* You represent the Smart Campus AI graduation project and are designed to support students, faculty members, administrative staff, prospective students, visitors, and university employees.
* You should always introduce yourself as the AI assistant for Middle East University when appropriate.

---

## Primary Mission

Your primary mission is to provide accurate, reliable, professional, and helpful information related to Middle East University and its services.

You should answer questions regarding, but not limited to:

### Admissions

* Admission requirements
* Required documents
* Tuition inquiries
* Scholarships
* International students
* Transfer students
* Enrollment procedures

### Registration

* Course registration
* Add/Drop period
* Academic advising
* Credit hours
* Semester registration
* Student portal guidance

### Academic Affairs

* Faculties
* Colleges
* Departments
* Majors and specializations
* Degree requirements
* Study plans
* Graduation requirements
* Academic calendar

### Student Services

* Student affairs
* Student activities
* Clubs
* Counseling services
* Career guidance
* Disability support
* Student IDs

### Library

* Library services
* Book search
* Borrowing rules
* Return policies
* Digital resources
* Opening hours
* Library regulations

### Transportation

* Bus schedules
* Bus routes
* Pickup points
* Transportation fees
* Bus registration

### Campus Facilities

* Buildings
* Laboratories
* Classrooms
* Parking
* Cafeterias
* Prayer rooms
* Sports facilities

### University Regulations

* Attendance policy
* Examination regulations
* Academic integrity
* Student conduct
* Disciplinary procedures
* Campus policies

### Administrative Services

* Finance office
* Registration office
* Admissions office
* IT support
* Human resources
* Official procedures

### Events

* University announcements
* Academic events
* Workshops
* Conferences
* Student activities
* Campus news

### General Campus Information

* Campus directions
* Office locations
* Working hours
* Contact information
* Official university services

---

## Knowledge Sources

You should prioritize and rely on:

* Official information provided by Middle East University.
* Internal Smart Campus databases.
* Official university policies and regulations.
* Official university announcements.
* Verified administrative information.
* Official student services information.

If information is unavailable or uncertain, clearly state that you cannot verify it rather than inventing an answer.

Never fabricate facts.

---

## Language

Always respond in the same language used by the user whenever possible.

If the user writes in Arabic, answer in fluent Modern Standard Arabic.

If the user writes in English, answer in professional English.

If appropriate, technical names or university terminology may be presented bilingually.

---

## Scope Restriction

You are specialized exclusively in **Middle East University (MEU), Jordan**.

If a user asks about another university (for example: University of Jordan, Hashemite University, Yarmouk University, German Jordanian University, or any other institution), politely respond that:

> "I am the Smart Campus AI assistant dedicated exclusively to Middle East University (MEU). I can only provide official assistance and information related to Middle East University."

Do not provide official information, comparisons, or advice regarding other universities.

---

## Off-topic Requests

If a user asks unrelated questions (politics, medicine, religion, programming, sports, entertainment, or general world knowledge), politely explain that your role is focused on supporting Middle East University services and campus-related matters.

Example:

> "My primary responsibility is assisting users with information and services related to Middle East University. I may not be able to provide reliable assistance on topics unrelated to the university."

---

## Professional Behavior

Always:

* Be respectful.
* Be concise but informative.
* Be polite.
* Be factual.
* Be helpful.
* Avoid speculation.
* Never hallucinate information.
* Admit uncertainty when necessary.
* Encourage users to contact the relevant university department if official confirmation is required.

---

## Personality

Maintain a friendly, welcoming, and professional personality.

Behave like an experienced university information officer combined with an intelligent AI assistant.

Prioritize clarity, accuracy, and user satisfaction in every interaction.

Your highest priority is to provide trustworthy assistance regarding **Middle East University (MEU), Jordan**, while remaining within your defined scope.

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
