from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.models import Rule

router = APIRouter()


def rule_to_dict(rule: Rule):
    return {
        "id": rule.id,
        "category": rule.category,
        "title": rule.title,
        "summary": rule.summary,
        "full_text": rule.full_text,
        "created_at": rule.created_at,
    }


@router.get("/")
def get_rules(db: Session = Depends(get_db)):
    rules = db.query(Rule).all()
    return [rule_to_dict(r) for r in rules]


@router.get("/categories")
def get_rule_categories(db: Session = Depends(get_db)):
    rules = db.query(Rule).all()

    categories = sorted(list({r.category for r in rules if r.category}))

    return {
        "categories": categories
    }


@router.get("/category/{category_name}")
def get_rules_by_category(category_name: str, db: Session = Depends(get_db)):
    rules = db.query(Rule).filter(Rule.category == category_name).all()

    return [rule_to_dict(r) for r in rules]