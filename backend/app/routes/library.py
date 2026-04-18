from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from datetime import date, timedelta
from app.db import get_db
from app.models.models import LibraryBook, LibraryCategory, BorrowedBook

router = APIRouter()

OVERDUE_FINE_PER_DAY = 0.50  # JOD


class BorrowRequest(BaseModel):
    student_id: str
    book_id: int


class ReturnRequest(BaseModel):
    borrow_id: int


def _book_to_dict(book: LibraryBook, category_name: str) -> dict:
    return {
        "id": book.id,
        "title": book.title,
        "author": book.author,
        "category": category_name,
        "category_id": book.category_id,
        "price": float(book.price) if book.price else 0.0,
        "available": book.available,
        "featured": book.featured,
        "cover_color": book.cover_color,
        "description": book.description,
        "isbn": book.isbn,
    }


@router.get("/info")
def get_library_info():
    return {
        "service_name": "University Library",
        "working_days": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday"],
        "working_hours": "8:00 AM – 5:00 PM",
        "services": [
            "Book Borrowing (14-day loan period)",
            "Reading Halls & Study Rooms",
            "Research Support & Databases",
            "Internet Access",
            "Printing & Copying",
            "Digital Resources",
        ],
    }


@router.get("/categories")
def get_categories(db: Session = Depends(get_db)):
    cats = db.query(LibraryCategory).all()
    return [{"id": c.id, "name": c.name, "icon": c.icon} for c in cats]


@router.get("/books")
def get_books(
    category_id: Optional[int] = None,
    featured: Optional[bool] = None,
    available: Optional[bool] = None,
    db: Session = Depends(get_db),
):
    query = db.query(LibraryBook)
    if category_id:
        query = query.filter(LibraryBook.category_id == category_id)
    if featured is not None:
        query = query.filter(LibraryBook.featured == featured)
    if available is not None:
        query = query.filter(LibraryBook.available == available)

    books = query.all()
    result = []
    for b in books:
        cat = db.query(LibraryCategory).filter(LibraryCategory.id == b.category_id).first()
        result.append(_book_to_dict(b, cat.name if cat else "General"))
    return result


@router.get("/books/featured")
def get_featured_books(db: Session = Depends(get_db)):
    books = db.query(LibraryBook).filter(LibraryBook.featured == True).all()
    result = []
    for b in books:
        cat = db.query(LibraryCategory).filter(LibraryCategory.id == b.category_id).first()
        result.append(_book_to_dict(b, cat.name if cat else "General"))
    return result


@router.get("/books/{book_id}")
def get_book(book_id: int, db: Session = Depends(get_db)):
    book = db.query(LibraryBook).filter(LibraryBook.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    cat = db.query(LibraryCategory).filter(LibraryCategory.id == book.category_id).first()
    return _book_to_dict(book, cat.name if cat else "General")


@router.post("/borrow")
def borrow_book(request: BorrowRequest, db: Session = Depends(get_db)):
    book = db.query(LibraryBook).filter(LibraryBook.id == request.book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    if not book.available:
        raise HTTPException(status_code=400, detail="Book is currently not available")

    book.available = False
    borrow = BorrowedBook(
        student_id=request.student_id,
        book_id=request.book_id,
        borrow_date=date.today(),
        due_date=date.today() + timedelta(days=14),
    )
    db.add(borrow)
    db.commit()
    return {
        "message": f"'{book.title}' borrowed successfully",
        "due_date": borrow.due_date.isoformat(),
        "fine_rate": f"{OVERDUE_FINE_PER_DAY} JOD/day if overdue",
    }


@router.post("/return")
def return_book(request: ReturnRequest, db: Session = Depends(get_db)):
    record = db.query(BorrowedBook).filter(BorrowedBook.id == request.borrow_id).first()
    if not record:
        raise HTTPException(status_code=404, detail="Borrow record not found")

    today = date.today()
    record.return_date = today

    fine = 0.0
    if today > record.due_date:
        overdue_days = (today - record.due_date).days
        fine = overdue_days * OVERDUE_FINE_PER_DAY

    book = db.query(LibraryBook).filter(LibraryBook.id == record.book_id).first()
    if book:
        book.available = True

    db.commit()
    return {
        "message": "Book returned successfully",
        "fine": f"{fine:.2f} JOD" if fine > 0 else "No fine",
    }


@router.get("/borrowed/{student_id}")
def get_borrowed_books(student_id: str, db: Session = Depends(get_db)):
    records = (
        db.query(BorrowedBook)
        .filter(BorrowedBook.student_id == student_id, BorrowedBook.return_date == None)
        .all()
    )
    result = []
    today = date.today()
    for r in records:
        book = db.query(LibraryBook).filter(LibraryBook.id == r.book_id).first()
        overdue = today > r.due_date if r.due_date else False
        fine = (today - r.due_date).days * OVERDUE_FINE_PER_DAY if overdue else 0
        result.append({
            "borrow_id": r.id,
            "book_id": r.book_id,
            "book_title": book.title if book else "Unknown",
            "book_author": book.author if book else "",
            "borrow_date": r.borrow_date.isoformat() if r.borrow_date else None,
            "due_date": r.due_date.isoformat() if r.due_date else None,
            "overdue": overdue,
            "fine": round(fine, 2),
        })
    return result