from sqlalchemy import (
    Column, Integer, String, Boolean, Text,
    DateTime, ForeignKey, Numeric
)
from sqlalchemy.sql import func
from app.db import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    university_id = Column(String(50), unique=True, index=True, nullable=True)
    email = Column(String(120), unique=True, index=True, nullable=True)
    password_hash = Column(Text, nullable=False)
    role = Column(String(30), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, server_default=func.now())


class StudentProfile(Base):
    __tablename__ = "student_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    full_name = Column(String(120), nullable=False)
    department = Column(String(120))
    major = Column(String(120))
    gpa = Column(Numeric(3, 2))
    credits_completed = Column(Integer, default=0)
    total_credits = Column(Integer, default=120)
    class_rank = Column(String(50))
    academic_status = Column(String(30), default="ACTIVE")
    avatar_url = Column(Text)


class Bus(Base):
    __tablename__ = "buses"

    id = Column(Integer, primary_key=True, index=True)
    bus_number = Column(String(30), unique=True, nullable=False, index=True)
    route_name = Column(String(150), nullable=False)
    driver_name = Column(String(120))
    pickup_area = Column(String(120))
    destination = Column(String(120))
    estimated_time = Column(String(50))
    capacity = Column(Integer, default=22)
    current_passengers = Column(Integer, default=0)
    available_seats = Column(Integer, default=22)
    status = Column(String(30), default="active")
    latitude = Column(Numeric)
    longitude = Column(Numeric)
    last_updated = Column(DateTime, server_default=func.now(), onupdate=func.now())


class BusLog(Base):
    __tablename__ = "bus_logs"

    id = Column(Integer, primary_key=True, index=True)
    bus_id = Column(Integer, ForeignKey("buses.id", ondelete="CASCADE"), nullable=False)
    current_passengers = Column(Integer, nullable=False)
    available_seats = Column(Integer, nullable=False)
    latitude = Column(Numeric)
    longitude = Column(Numeric)
    created_at = Column(DateTime, server_default=func.now())


class Book(Base):
    __tablename__ = "books"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    author = Column(String(150))
    category = Column(String(100))
    status = Column(String(30), default="available")
    cover_url = Column(Text)
    created_at = Column(DateTime, server_default=func.now())


class BookReservation(Base):
    __tablename__ = "book_reservations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    book_id = Column(Integer, ForeignKey("books.id", ondelete="CASCADE"), nullable=False)
    status = Column(String(30), default="pending")
    pickup_time = Column(DateTime)
    created_at = Column(DateTime, server_default=func.now())


class BookBorrowing(Base):
    __tablename__ = "book_borrowings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    book_id = Column(Integer, ForeignKey("books.id", ondelete="CASCADE"), nullable=False)
    borrow_date = Column(DateTime, server_default=func.now())
    due_date = Column(DateTime)
    return_date = Column(DateTime)
    status = Column(String(30), default="borrowed")


class Rule(Base):
    __tablename__ = "rules"

    id = Column(Integer, primary_key=True, index=True)
    category = Column(String(80), nullable=False)
    title = Column(String(200), nullable=False)
    summary = Column(Text)
    full_text = Column(Text)
    created_at = Column(DateTime, server_default=func.now())


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True)
    title = Column(String(200), nullable=False)
    message = Column(Text, nullable=False)
    type = Column(String(50), default="general")
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())


class ChatSession(Base):
    __tablename__ = "chat_sessions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(150))
    created_at = Column(DateTime, server_default=func.now())


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("chat_sessions.id", ondelete="CASCADE"), nullable=False)
    sender = Column(String(20), nullable=False)
    message = Column(Text, nullable=False)
    created_at = Column(DateTime, server_default=func.now())