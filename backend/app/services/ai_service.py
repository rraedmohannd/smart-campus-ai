from openai import OpenAI
from app.config import OPENAI_API_KEY

client = OpenAI(api_key=OPENAI_API_KEY)
session_memory: dict = {}

SYSTEM_PROMPT = """
You are the Smart Campus AI Assistant for Middle East University (MEU), Amman, Jordan.
You help students with questions about:
- Campus services (admissions, registration, student affairs)
- Bus transportation schedules and routes
- Library services, book availability, borrowing rules
- University rules, academic regulations, attendance policies
- General campus information

Always be helpful, concise, and professional.
Working hours: Sunday–Thursday, 8:00 AM – 4:00 PM.
"""


def get_ai_response(message: str, session_id: str = "default") -> str:
    if session_id not in session_memory:
        session_memory[session_id] = []

    conversation = session_memory[session_id]
    conversation.append({"role": "user", "content": message})

    messages = [{"role": "system", "content": SYSTEM_PROMPT}] + conversation[-20:]

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=messages,
        temperature=0.7,
    )

    reply = response.choices[0].message.content
    conversation.append({"role": "assistant", "content": reply})
    return reply