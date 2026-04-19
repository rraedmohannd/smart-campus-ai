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




demo_rules = {
    "service_name": "University Rules",
    "categories": [
        {
            "category_name": "Academic Rules",
            "rules": [
                {
                    "title": "Minimum GPA",
                    "text": "Students must maintain the minimum GPA required by the university.",
                    "severity": "warning"
                },
                {
                    "title": "Course Registration",
                    "text": "Students must register only during the official registration period.",
                    "severity": "info"
                },
                {
                    "title": "Prerequisite Requirement",
                    "text": "Students cannot register for a course without completing its prerequisites.",
                    "severity": "warning"
                },
                {
                    "title": "Academic Integrity",
                    "text": "Any form of plagiarism or academic dishonesty is strictly prohibited.",
                    "severity": "danger"
                },
                {
                    "title": "Project Submission",
                    "text": "Assignments and graduation projects must be submitted before the announced deadline.",
                    "severity": "info"
                }
            ]
        },
        {
            "category_name": "Attendance Rules",
            "rules": [
                {
                    "title": "Attendance Threshold",
                    "text": "Students must attend at least 75% of lectures in each course.",
                    "severity": "warning"
                },
                {
                    "title": "Absence Consequences",
                    "text": "Exceeding the allowed absence limit may lead to course denial.",
                    "severity": "danger"
                },
                {
                    "title": "Late Arrival",
                    "text": "Repeated late arrival may be counted as absence according to course policy.",
                    "severity": "warning"
                },
                {
                    "title": "Excused Absence",
                    "text": "Official excuses must be submitted within the approved university time frame.",
                    "severity": "info"
                }
            ]
        },
        {
            "category_name": "Exam Rules",
            "rules": [
                {
                    "title": "Exam Honesty",
                    "text": "Cheating during exams is strictly prohibited and subject to disciplinary action.",
                    "severity": "danger"
                },
                {
                    "title": "Student ID",
                    "text": "Students must bring their university ID to all exams.",
                    "severity": "info"
                },
                {
                    "title": "No Electronic Devices",
                    "text": "Mobile phones, smart watches, and unauthorized devices are not allowed during exams.",
                    "severity": "danger"
                },
                {
                    "title": "Late Entry to Exams",
                    "text": "Students arriving late may not be allowed to enter the examination hall.",
                    "severity": "warning"
                },
                {
                    "title": "Silence in Exam Hall",
                    "text": "Students must remain silent and follow invigilator instructions during exams.",
                    "severity": "info"
                }
            ]
        },
        {
            "category_name": "Library Rules",
            "rules": [
                {
                    "title": "Borrowing Period",
                    "text": "Books can be borrowed for up to 14 days unless otherwise stated.",
                    "severity": "info"
                },
                {
                    "title": "Late Return",
                    "text": "Late returns may result in temporary suspension of borrowing privileges.",
                    "severity": "warning"
                },
                {
                    "title": "Book Condition",
                    "text": "Students are responsible for returning borrowed books in good condition.",
                    "severity": "warning"
                },
                {
                    "title": "Library Silence",
                    "text": "Students must keep quiet inside reading halls and study areas.",
                    "severity": "info"
                },
                {
                    "title": "No Food or Drinks",
                    "text": "Food and beverages are not allowed near books, computers, or study tables.",
                    "severity": "warning"
                }
            ]
        },
        {
            "category_name": "Campus Behavior",
            "rules": [
                {
                    "title": "Respectful Conduct",
                    "text": "Students must behave respectfully toward staff, faculty, and peers.",
                    "severity": "info"
                },
                {
                    "title": "Property Protection",
                    "text": "Damaging university property is prohibited.",
                    "severity": "danger"
                },
                {
                    "title": "No Smoking in Restricted Areas",
                    "text": "Smoking is prohibited inside classrooms, laboratories, libraries, and closed campus facilities.",
                    "severity": "danger"
                },
                {
                    "title": "No Fighting or Verbal Abuse",
                    "text": "Any physical confrontation, threats, or verbal abuse is forbidden on campus.",
                    "severity": "danger"
                },
                {
                    "title": "Dress Code",
                    "text": "Students should follow respectful and appropriate university dress standards.",
                    "severity": "info"
                }
            ]
        },
        {
            "category_name": "Safety & Security",
            "rules": [
                {
                    "title": "University ID Visibility",
                    "text": "Students should carry and present their university ID when requested.",
                    "severity": "info"
                },
                {
                    "title": "Restricted Areas",
                    "text": "Entering restricted labs, offices, or technical rooms without permission is prohibited.",
                    "severity": "danger"
                },
                {
                    "title": "Emergency Instructions",
                    "text": "Students must follow evacuation and safety instructions during emergencies.",
                    "severity": "warning"
                },
                {
                    "title": "Reporting Suspicious Activity",
                    "text": "Any suspicious behavior or unattended dangerous items must be reported immediately.",
                    "severity": "warning"
                }
            ]
        },
        {
            "category_name": "Parking & Transportation",
            "rules": [
                {
                    "title": "Parking Regulations",
                    "text": "Students must park only in designated student parking areas.",
                    "severity": "info"
                },
                {
                    "title": "No Double Parking",
                    "text": "Blocking roads, gates, or other vehicles is not allowed inside campus.",
                    "severity": "warning"
                },
                {
                    "title": "Bus Discipline",
                    "text": "Students must queue respectfully and follow bus supervisor instructions.",
                    "severity": "info"
                },
                {
                    "title": "Bus Capacity",
                    "text": "Students should not board a bus that has reached full capacity.",
                    "severity": "warning"
                }
            ]
        }
    ]
}

demo_chat_fallbacks = {
    "library": "The library is open from 8:00 AM to 4:00 PM, Sunday to Thursday.",
    "bus": "University buses start operating in the morning, and route details are available in the bus section.",
    "rules": "Please check the rules section for academic, attendance, exam, and library policies.",
    "admission": "For admission details, please contact student affairs or visit the admissions office.",
    "default": "Welcome to Smart Campus AI. How can I help you today?"
}
demo_buses = [
    {
        "bus_number": "1",
        "route_name": "Route 1",
        "driver_name": "Ahmad Khaled",
        "pickup_area": "Tabarbour",
        "destination": "MEU",
        "estimated_time_minutes": 35,
        "capacity": 22,
        "current_passengers": 8,
        "available_seats": 14,
        "status": "active"
    },
    {
        "bus_number": "2",
        "route_name": "Route 2",
        "driver_name": "Omar Ali",
        "pickup_area": "Sweileh",
        "destination": "MEU",
        "estimated_time_minutes": 20,
        "capacity": 30,
        "current_passengers": 25,
        "available_seats": 5,
        "status": "active"
    },
    {
        "bus_number": "3",
        "route_name": "Route 3",
        "driver_name": "Yasser Ahmad",
        "pickup_area": "Khalda",
        "destination": "MEU",
        "estimated_time_minutes": 15,
        "capacity": 25,
        "current_passengers": 25,
        "available_seats": 0,
        "status": "full"
    },
    {
        "bus_number": "4",
        "route_name": "Route 4",
        "driver_name": "Yousef Sami",
        "pickup_area": "Jubeiha",
        "destination": "MEU",
        "estimated_time_minutes": 10,
        "capacity": 20,
        "current_passengers": 5,
        "available_seats": 15,
        "status": "active"
    }
]