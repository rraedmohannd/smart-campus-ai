from fastapi import APIRouter
from app.demo_data import demo_books

router = APIRouter()

@router.get("/books")
def get_books():
    return demo_books

@router.get("/info")
def get_info():
    categories = sorted(list(set(book["category"] for book in demo_books)))
    return {
        "categories": categories,
        "total_books": len(demo_books),
        "featured_books": len([b for b in demo_books if b["featured"]])
    }
