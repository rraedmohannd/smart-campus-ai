from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.models import Book

router = APIRouter()


def book_to_dict(book: Book):
    return {
        "id": book.id,
        "title": book.title,
        "author": book.author,
        "category": book.category,
        "status": book.status,
        "cover_url": book.cover_url,
        "created_at": book.created_at,
    }


@router.get("/")
def get_library_info(db: Session = Depends(get_db)):
    books = db.query(Book).all()

    categories = sorted(list({b.category for b in books if b.category}))

    return {
        "service_name": "University Library",
        "working_hours": "Sunday to Thursday, 8:00 AM to 4:00 PM",
        "total_books": len(books),
        "categories": categories,
    }


@router.get("/books")
def get_books(db: Session = Depends(get_db)):
    books = db.query(Book).all()
    return [book_to_dict(book) for book in books]


@router.get("/featured")
def get_featured_books(db: Session = Depends(get_db)):
    # مؤقتًا نخلي أول 5 كتب Featured
    books = db.query(Book).limit(5).all()
    return [book_to_dict(book) for book in books]


@router.get("/categories")
def get_categories(db: Session = Depends(get_db)):
    books = db.query(Book).all()

    categories = sorted(list({b.category for b in books if b.category}))

    return {
        "categories": categories
    }