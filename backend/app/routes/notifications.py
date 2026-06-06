from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.models import Notification

router = APIRouter()


def notification_to_dict(n: Notification):
    return {
        "id": n.id,
        "user_id": n.user_id,
        "title": n.title,
        "message": n.message,
        "type": n.type,
        "is_read": n.is_read,
        "created_at": n.created_at,
    }


# 🔹 كل الإشعارات
@router.get("/")
def get_notifications(db: Session = Depends(get_db)):
    notes = db.query(Notification).order_by(Notification.created_at.desc()).all()
    return [notification_to_dict(n) for n in notes]


# 🔹 إشعارات مستخدم معين
@router.get("/user/{user_id}")
def get_user_notifications(user_id: int, db: Session = Depends(get_db)):
    notes = (
        db.query(Notification)
        .filter((Notification.user_id == user_id) | (Notification.user_id.is_(None)))
        .order_by(Notification.created_at.desc())
        .all()
    )

    return [notification_to_dict(n) for n in notes]


# 🔹 تعليم إشعار كمقروء
@router.put("/{notification_id}/read")
def mark_as_read(notification_id: int, db: Session = Depends(get_db)):
    note = db.query(Notification).filter(Notification.id == notification_id).first()

    if not note:
        raise HTTPException(status_code=404, detail="Notification not found")

    note.is_read = True
    db.commit()
    db.refresh(note)

    return {
        "message": "Notification marked as read",
        "notification": notification_to_dict(note)
    }


# 🔹 حذف إشعار
@router.delete("/{notification_id}")
def delete_notification(notification_id: int, db: Session = Depends(get_db)):
    note = db.query(Notification).filter(Notification.id == notification_id).first()

    if not note:
        raise HTTPException(status_code=404, detail="Notification not found")

    db.delete(note)
    db.commit()

    return {
        "message": "Notification deleted successfully"
    }
