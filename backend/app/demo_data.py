# backend/app/demo_data.py

demo_users = [
    {"student_id": "STU001", "name": "Ahmad Ali", "email": "ahmad.ali@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU002", "name": "Sara Khaled", "email": "sara.khaled@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU003", "name": "Omar Nasser", "email": "omar.nasser@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU004", "name": "Lina Sameer", "email": "lina.sameer@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU005", "name": "Yousef Adel", "email": "yousef.adel@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU006", "name": "Maya Hassan", "email": "maya.hassan@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU007", "name": "Khaled Jamal", "email": "khaled.jamal@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU008", "name": "Noor Ibrahim", "email": "noor.ibrahim@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU009", "name": "Hussein Rami", "email": "hussein.rami@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU010", "name": "Razan Tareq", "email": "razan.tareq@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU011", "name": "Zaid Munther", "email": "zaid.munther@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU012", "name": "Dana Fadi", "email": "dana.fadi@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU013", "name": "Laith Bashar", "email": "laith.bashar@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU014", "name": "Alaa Noor", "email": "alaa.noor@meu.edu.jo", "password": "pass123"},
    {"student_id": "STU015", "name": "Farah Sami", "email": "farah.sami@meu.edu.jo", "password": "pass123"},
]

demo_books = [
    {
        "id": 1,
        "title": "Introduction to Artificial Intelligence",
        "author": "John McCarthy",
        "category": "AI",
        "price": 12.0,
        "available": True,
        "featured": True,
        "description": "A beginner-friendly introduction to AI concepts and applications."
    },
    # ... (books 2–15 exactly as in your spec)
]

demo_rules = {
    "service_name": "University Rules",
    "categories": [
        {
            "category_name": "Academic Rules",
            "rules": [
                {"title": "Minimum GPA", "text": "Students must maintain the minimum GPA required by the university.", "severity": "warning"},
                {"title": "Course Registration", "text": "Students must register only during the official registration period.", "severity": "info"},
                {"title": "Prerequisite Requirement", "text": "Students cannot register for a course without completing its prerequisites.", "severity": "warning"}
            ]
        },
        # ... (other categories exactly as in your spec)
    ]
}

demo_chat_fallbacks = {
    "library": "The library is open from 8:00 AM to 4:00 PM, Sunday to Thursday.",
    "bus": "University buses start operating in the morning, and route details are available in the bus section.",
    "rules": "Please check the rules section for academic, attendance, exam, and library policies.",
    "admission": "For admission details, please contact student affairs or visit the admissions office.",
    "default": "Welcome to Smart Campus AI. How can I help you today?"
}
