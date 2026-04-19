from fastapi import APIRouter

router = APIRouter(prefix="/library", tags=["Library"])

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
    {
        "id": 2,
        "title": "Machine Learning Basics",
        "author": "Andrew Ng",
        "category": "AI",
        "price": 15.0,
        "available": True,
        "featured": True,
        "description": "Fundamentals of machine learning and practical use cases."
    },
    {
        "id": 3,
        "title": "Deep Learning Guide",
        "author": "Ian Goodfellow",
        "category": "AI",
        "price": 18.0,
        "available": True,
        "featured": False,
        "description": "Advanced deep learning techniques and neural networks."
    },
    {
        "id": 4,
        "title": "Computer Networks",
        "author": "Andrew Tanenbaum",
        "category": "Networking",
        "price": 14.0,
        "available": True,
        "featured": False,
        "description": "Comprehensive guide to computer networking."
    },
    {
        "id": 5,
        "title": "Operating Systems Concepts",
        "author": "Abraham Silberschatz",
        "category": "Systems",
        "price": 16.0,
        "available": True,
        "featured": True,
        "description": "Core concepts of operating systems design and implementation."
    },
    {
        "id": 6,
        "title": "Data Structures in Python",
        "author": "Mark Allen Weiss",
        "category": "Programming",
        "price": 11.0,
        "available": True,
        "featured": False,
        "description": "Understanding data structures using Python."
    },
    {
        "id": 7,
        "title": "Database System Design",
        "author": "Raghu Ramakrishnan",
        "category": "Database",
        "price": 13.5,
        "available": True,
        "featured": False,
        "description": "Design and implementation of database systems."
    },
    {
        "id": 8,
        "title": "Flutter Development Guide",
        "author": "Google Dev Team",
        "category": "Mobile",
        "price": 10.0,
        "available": True,
        "featured": True,
        "description": "Build cross-platform apps using Flutter."
    },
    {
        "id": 9,
        "title": "Cybersecurity Essentials",
        "author": "William Stallings",
        "category": "Security",
        "price": 17.0,
        "available": True,
        "featured": False,
        "description": "Key principles of cybersecurity and protection systems."
    },
    {
        "id": 10,
        "title": "Embedded Systems Design",
        "author": "Peter Marwedel",
        "category": "Embedded",
        "price": 14.5,
        "available": True,
        "featured": False,
        "description": "Designing embedded systems with real-world examples."
    },
    {
        "id": 11,
        "title": "Digital Signal Processing",
        "author": "Alan Oppenheim",
        "category": "DSP",
        "price": 19.0,
        "available": True,
        "featured": True,
        "description": "Fundamentals of signal processing and analysis."
    },
    {
        "id": 12,
        "title": "Robotics Engineering",
        "author": "Bruno Siciliano",
        "category": "Robotics",
        "price": 20.0,
        "available": True,
        "featured": False,
        "description": "Introduction to robotics and intelligent systems."
    },
    {
        "id": 13,
        "title": "Cloud Computing Basics",
        "author": "Rajkumar Buyya",
        "category": "Cloud",
        "price": 13.0,
        "available": True,
        "featured": False,
        "description": "Concepts of cloud computing and distributed systems."
    },
    {
        "id": 14,
        "title": "Software Engineering Principles",
        "author": "Ian Sommerville",
        "category": "Software",
        "price": 15.5,
        "available": True,
        "featured": True,
        "description": "Best practices in software development and project management."
    },
    {
        "id": 15,
        "title": "Computer Vision Basics",
        "author": "Richard Szeliski",
        "category": "AI",
        "price": 18.5,
        "available": True,
        "featured": False,
        "description": "Introduction to computer vision and image processing."
    }
]


@router.get("/")
def get_library_info():
    featured_books = [book for book in demo_books if book.get("featured")]

    categories = sorted(
        list({book.get("category", "General") for book in demo_books})
    )

    return {
        "service_name": "University Library",
        "working_hours": "Sunday to Thursday, 8:00 AM to 4:00 PM",
        "total_books": len(demo_books),
        "featured_books_count": len(featured_books),
        "services": [
            "Book borrowing",
            "Book return",
            "Reading hall",
            "Research support",
            "Digital resources",
        ],
        "categories": categories,
    }


@router.get("/books")
def get_books():
    return demo_books


@router.get("/featured")
def get_featured_books():
    return [book for book in demo_books if book.get("featured")]


@router.get("/categories")
def get_categories():
    return {
        "categories": sorted(
            list({book.get("category", "General") for book in demo_books})
        )
    }