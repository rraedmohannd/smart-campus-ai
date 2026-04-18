from fastapi import APIRouter
from app.demo_data import demo_rules

router = APIRouter()

@router.get("/info")
def get_rules():
    return demo_rules
