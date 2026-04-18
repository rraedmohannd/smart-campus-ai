from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.models import UniversityRule, RuleCategory

router = APIRouter()


@router.get("/")
def rules_status():
    return {"message": "Rules service is running"}


@router.get("/info")
def get_rules_grouped(db: Session = Depends(get_db)):
    categories = db.query(RuleCategory).all()
    result = []
    for cat in categories:
        rules = (
            db.query(UniversityRule)
            .filter(UniversityRule.category_id == cat.id)
            .order_by(UniversityRule.rule_number)
            .all()
        )
        result.append({
            "category_id": cat.id,
            "category_name": cat.name,
            "icon": cat.icon,
            "rules": [
                {
                    "id": r.id,
                    "number": r.rule_number,
                    "title": r.rule_title,
                    "text": r.rule_text,
                    "severity": r.severity,
                }
                for r in rules
            ],
        })
    return {
        "service_name": "University Rules & Regulations",
        "last_updated": "Spring 2025",
        "categories": result,
    }