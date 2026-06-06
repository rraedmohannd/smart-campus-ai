from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.models import Book, BookBorrowing, BookReservation, StudentProfile, User

router = APIRouter()


class BookPayload(BaseModel):
    title: str | None = None
    author: str | None = None
    category: str | None = None
    status: str | None = None
    available: bool | None = None
    cover_url: str | None = None


class ReservationPayload(BaseModel):
    status: str


def _clean(value: str | None) -> str | None:
    if value is None:
        return None
    value = value.strip()
    return value or None


def book_to_dict(book: Book):
    return {
        "id": book.id,
        "book_id": book.id,
        "title": book.title,
        "author": book.author,
        "category": book.category,
        "status": book.status,
        "available": book.status != "borrowed",
        "cover_url": book.cover_url,
        "created_at": book.created_at,
    }


def _student_name(db: Session, user_id: int):
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user_id).first()
    if profile:
        return profile.full_name
    user = db.query(User).filter(User.id == user_id).first()
    return user.email or user.university_id if user else "Student"


def reservation_to_dict(item: BookReservation, db: Session):
    book = db.query(Book).filter(Book.id == item.book_id).first()
    return {
        "id": item.id,
        "reservation_id": item.id,
        "user_id": item.user_id,
        "student_name": _student_name(db, item.user_id),
        "book_id": item.book_id,
        "book_title": book.title if book else "Reserved Book",
        "status": item.status,
        "pickup_time": item.pickup_time,
        "created_at": item.created_at,
    }


def borrowing_to_dict(item: BookBorrowing, db: Session):
    book = db.query(Book).filter(Book.id == item.book_id).first()
    return {
        "id": item.id,
        "borrowing_id": item.id,
        "user_id": item.user_id,
        "student_name": _student_name(db, item.user_id),
        "book_id": item.book_id,
        "book_title": book.title if book else "Borrowed Book",
        "status": item.status,
        "borrow_date": item.borrow_date,
        "due_date": item.due_date,
        "return_date": item.return_date,
    }


@router.get("/dashboard")
def dashboard(db: Session = Depends(get_db)):
    books = db.query(Book).all()
    borrowings = db.query(BookBorrowing).all()
    reservations = db.query(BookReservation).all()

    return {
        "total_books": len(books),
        "available_books": sum(1 for book in books if book.status != "borrowed"),
        "borrowed_books": sum(1 for item in borrowings if item.status == "borrowed"),
        "pending_reservations": sum(1 for item in reservations if item.status == "pending"),
        "overdue_books": 0,
    }


@router.get("/books")
def list_books(db: Session = Depends(get_db)):
    books = db.query(Book).order_by(Book.id.asc()).all()
    return [book_to_dict(book) for book in books]


@router.post("/books")
def create_book(payload: BookPayload, db: Session = Depends(get_db)):
    title = _clean(payload.title)
    if not title:
        raise HTTPException(status_code=422, detail="Book title is required")

    status = _clean(payload.status)
    if payload.available is False and not status:
        status = "borrowed"

    book = Book(
        title=title,
        author=_clean(payload.author),
        category=_clean(payload.category),
        status=status or "available",
        cover_url=_clean(payload.cover_url),
    )
    db.add(book)
    db.commit()
    db.refresh(book)
    return book_to_dict(book)


@router.put("/books/{book_id}")
def update_book(book_id: int, payload: BookPayload, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")

    updates = payload.model_dump(exclude_unset=True)
    if "title" in updates and _clean(payload.title):
        book.title = _clean(payload.title)
    if "author" in updates:
        book.author = _clean(payload.author)
    if "category" in updates:
        book.category = _clean(payload.category)
    if "cover_url" in updates:
        book.cover_url = _clean(payload.cover_url)
    if "status" in updates and _clean(payload.status):
        book.status = _clean(payload.status)
    elif "available" in updates and payload.available is not None:
        book.status = "available" if payload.available else "borrowed"

    db.commit()
    db.refresh(book)
    return book_to_dict(book)


@router.delete("/books/{book_id}")
def delete_book(book_id: int, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    db.delete(book)
    db.commit()
    return {"message": "Book deleted successfully"}


@router.get("/reservations")
def list_reservations(db: Session = Depends(get_db)):
    reservations = db.query(BookReservation).order_by(BookReservation.created_at.desc()).all()
    return [reservation_to_dict(item, db) for item in reservations]


@router.put("/reservations/{reservation_id}")
def update_reservation(
    reservation_id: int,
    payload: ReservationPayload,
    db: Session = Depends(get_db),
):
    reservation = db.query(BookReservation).filter(BookReservation.id == reservation_id).first()
    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")

    status = payload.status.strip().lower()
    if status not in {"pending", "approved", "rejected", "cancelled"}:
        raise HTTPException(status_code=422, detail="Unsupported reservation status")

    reservation.status = status
    book = db.query(Book).filter(Book.id == reservation.book_id).first()
    if book and status == "approved":
        book.status = "reserved"
    elif book and status in {"rejected", "cancelled"}:
        book.status = "available"

    db.commit()
    db.refresh(reservation)
    return reservation_to_dict(reservation, db)


@router.get("/borrowings")
def list_borrowings(db: Session = Depends(get_db)):
    borrowings = db.query(BookBorrowing).order_by(BookBorrowing.borrow_date.desc()).all()
    return [borrowing_to_dict(item, db) for item in borrowings]


@router.put("/borrowings/{borrowing_id}/return")
def return_borrowing(borrowing_id: int, db: Session = Depends(get_db)):
    borrowing = db.query(BookBorrowing).filter(BookBorrowing.id == borrowing_id).first()
    if not borrowing:
        raise HTTPException(status_code=404, detail="Borrowing not found")

    borrowing.status = "returned"
    borrowing.return_date = datetime.utcnow()
    book = db.query(Book).filter(Book.id == borrowing.book_id).first()
    if book:
        book.status = "available"

    db.commit()
    db.refresh(borrowing)
    return borrowing_to_dict(borrowing, db)
