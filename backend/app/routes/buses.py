from fastapi import APIRouter
from app.demo_data import demo_buses

router = APIRouter()

@router.get("/routes")
def get_routes():
    return demo_buses

@router.get("/live")
def get_live():
    return demo_buses