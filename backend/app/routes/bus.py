from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from app.db import get_db
from app.models.models import Bus, BusRoute, BusStop, BusSchedule

router = APIRouter()


class GPSUpdate(BaseModel):
    bus_number: str
    latitude: float
    longitude: float
    status: Optional[str] = None


def _build_route_detail(route: BusRoute, db: Session) -> dict:
    stops = db.query(BusStop).filter(BusStop.route_id == route.id).order_by(BusStop.stop_order).all()
    schedules = db.query(BusSchedule).filter(BusSchedule.route_id == route.id).all()
    buses = db.query(Bus).filter(Bus.route_id == route.id).all()

    return {
        "route_id": route.id,
        "route_name": route.route_name,
        "working_days": route.working_days.split(",") if route.working_days else [],
        "stops": [
            {
                "order": s.stop_order,
                "name": s.stop_name,
                "latitude": s.latitude,
                "longitude": s.longitude,
            }
            for s in stops
        ],
        "schedules": [
            {"departure": s.departure_time, "return": s.return_time}
            for s in schedules
        ],
        "buses": [
            {
                "bus_number": b.bus_number,
                "plate_number": b.plate_number,
                "capacity": b.capacity,
                "status": b.status,
                "driver_name": b.driver_name,
                "current_lat": b.current_lat,
                "current_lng": b.current_lng,
                "last_updated": b.last_updated.isoformat() if b.last_updated else None,
            }
            for b in buses
        ],
    }


@router.get("/")
def bus_status():
    return {"message": "Bus service is running", "version": "2.0"}


@router.get("/routes")
def get_all_routes(db: Session = Depends(get_db)):
    routes = db.query(BusRoute).all()
    return [_build_route_detail(r, db) for r in routes]


@router.get("/routes/{route_id}")
def get_route(route_id: int, db: Session = Depends(get_db)):
    route = db.query(BusRoute).filter(BusRoute.id == route_id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Route not found")
    return _build_route_detail(route, db)


@router.get("/live")
def get_live_buses(db: Session = Depends(get_db)):
    buses = db.query(Bus).all()
    return [
        {
            "bus_number": b.bus_number,
            "plate_number": b.plate_number,
            "route_id": b.route_id,
            "status": b.status,
            "driver_name": b.driver_name,
            "current_lat": b.current_lat,
            "current_lng": b.current_lng,
            "last_updated": b.last_updated.isoformat() if b.last_updated else None,
        }
        for b in buses
    ]


@router.post("/gps/update")
def update_gps(payload: GPSUpdate, db: Session = Depends(get_db)):
    bus = db.query(Bus).filter(Bus.bus_number == payload.bus_number).first()
    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")
    bus.current_lat = payload.latitude
    bus.current_lng = payload.longitude
    if payload.status:
        bus.status = payload.status
    db.commit()
    return {"message": f"GPS updated for {payload.bus_number}"}


@router.get("/info")
def get_bus_info_legacy(db: Session = Depends(get_db)):
    routes = db.query(BusRoute).all()
    result = {}
    for route in routes:
        stops = db.query(BusStop).filter(BusStop.route_id == route.id).order_by(BusStop.stop_order).all()
        scheds = db.query(BusSchedule).filter(BusSchedule.route_id == route.id).all()
        if route.route_name not in result:
            result[route.route_name] = {
                "route_id": route.id,
                "route_name": route.route_name,
                "pickup_points": [s.stop_name for s in stops],
                "departure_times": [sc.departure_time for sc in scheds],
                "return_times": [sc.return_time for sc in scheds],
            }
    return {
        "service_name": "University Bus System",
        "working_days": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday"],
        "routes": list(result.values()),
    }