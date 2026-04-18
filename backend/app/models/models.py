from sqlalchemy import (
    Column, Integer, String, Boolean, Text,
    Date, DateTime, ForeignKey, Float, Numeric
)
from sqlalchemy.sql import func
from app.db import Base


class Student(Base):
    __tablename__ = "students"
    id          = Column(Integer, primary_key=True, index=True)
    student_id  = Column(String(50), unique=True, nullable=False, index=True)
    name        = Column(String(100), nullable=False)
    email       = Column(String(100), unique=True, nullable=False)
    password    = Column(String(255), nullable=False)
    department  = Column(String(100))
    created_at  = Column(DateTime, server_default=func.now())


class ChatSession(Base):
    __tablename__ = "chat_sessions"
    id          = Column(Integer, primary_key=True, index=True)
    student_id  = Column(String(50), ForeignKey("students.student_id", ondelete="CASCADE"))
    message     = Column(Text, nullable=False)
    response    = Column(Text, nullable=False)
    timestamp   = Column(DateTime, server_default=func.now())


class BusRoute(Base):
    __tablename__ = "bus_routes"
    id           = Column(Integer, primary_key=True, index=True)
    route_name   = Column(String(100), nullable=False)
    working_days = Column(Text, default="Sun,Mon,Tue,Wed,Thu")


class BusStop(Base):
    __tablename__ = "bus_stops"
    id          = Column(Integer, primary_key=True, index=True)
    route_id    = Column(Integer, ForeignKey("bus_routes.id", ondelete="CASCADE"))
    stop_name   = Column(String(100), nullable=False)
    stop_order  = Column(Integer, default=0)
    latitude    = Column(Float)
    longitude   = Column(Float)


class BusSchedule(Base):
    __tablename__ = "bus_schedules"
    id              = Column(Integer, primary_key=True, index=True)
    route_id        = Column(Integer, ForeignKey("bus_routes.id", ondelete="CASCADE"))
    departure_time  = Column(String(10), nullable=False)
    return_time     = Column(String(10), nullable=False)


class Bus(Base):
    __tablename__ = "buses"
    id            = Column(Integer, primary_key=True, index=True)
    bus_number    = Column(String(20), unique=True, nullable=False)
    plate_number  = Column(String(20))
    capacity      = Column(Integer, default=40)
    route_id      = Column(Integer, ForeignKey("bus_routes.id"))
    status        = Column(String(20), default="idle")   # idle | on_route | maintenance
    driver_name   = Column(String(100))
    current_lat   = Column(Float)
    current_lng   = Column(Float)
    last_updated  = Column(DateTime, server_default=func.now(), onupdate=func.now())


class LibraryCategory(Base):
    __tablename__ = "library_categories"
    id   = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    icon = Column(String(50), default="book")


class LibraryBook(Base):
    __tablename__ = "library_books"
    id          = Column(Integer, primary_key=True, index=True)
    title       = Column(String(200), nullable=False)
    author      = Column(String(100))
    category_id = Column(Integer, ForeignKey("library_categories.id"))
    price       = Column(Numeric(8, 2), default=0.00)
    available   = Column(Boolean, default=True)
    featured    = Column(Boolean, default=False)
    cover_color = Column(String(20), default="#9E1B22")
    description = Column(Text)
    isbn        = Column(String(50))
    added_at    = Column(DateTime, server_default=func.now())


class BorrowedBook(Base):
    __tablename__ = "borrowed_books"
    id          = Column(Integer, primary_key=True, index=True)
    student_id  = Column(String(50), ForeignKey("students.student_id", ondelete="CASCADE"))
    book_id     = Column(Integer, ForeignKey("library_books.id", ondelete="CASCADE"))
    borrow_date = Column(Date)
    due_date    = Column(Date)
    return_date = Column(Date)


class RuleCategory(Base):
    __tablename__ = "rule_categories"
    id   = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    icon = Column(String(50), default="gavel")


class UniversityRule(Base):
    __tablename__ = "university_rules"
    id          = Column(Integer, primary_key=True, index=True)
    category_id = Column(Integer, ForeignKey("rule_categories.id"))
    rule_number = Column(Integer)
    rule_title  = Column(String(200))
    rule_text   = Column(Text, nullable=False)
    severity    = Column(String(20), default="info")


class Notification(Base):
    __tablename__ = "notifications"
    id         = Column(Integer, primary_key=True, index=True)
    title      = Column(String(200), nullable=False)
    message    = Column(Text, nullable=False)
    type       = Column(String(20), default="info")
    created_at = Column(DateTime, server_default=func.now())