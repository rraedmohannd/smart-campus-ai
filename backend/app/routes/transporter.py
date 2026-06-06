from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.models import Bus, BusLog
from app.routes.buses import bus_to_dict

router = APIRouter()


class BusPayload(BaseModel):
    bus_number: str | None = None
    route_name: str | None = None
    driver_name: str | None = None
    pickup_area: str | None = None
    destination: str | None = None
    estimated_time: str | None = None
    estimated_time_minutes: int | None = None
    capacity: int | None = Field(None, ge=1)
    current_passengers: int | None = Field(None, ge=0)
    available_seats: int | None = Field(None, ge=0)
    status: str | None = None
    latitude: float | None = None
    longitude: float | None = None


def _clean(value: str | None) -> str | None:
    if value is None:
        return None
    value = value.strip()
    return value or None


def _apply_bus_payload(bus: Bus, payload: BusPayload):
    updates = payload.model_dump(exclude_unset=True)
    for attr in [
        "bus_number",
        "route_name",
        "driver_name",
        "pickup_area",
        "destination",
        "estimated_time",
        "status",
    ]:
        if attr in updates:
            setattr(bus, attr, _clean(getattr(payload, attr)))

    if "estimated_time_minutes" in updates and payload.estimated_time_minutes is not None:
        bus.estimated_time = f"{payload.estimated_time_minutes} mins"
    if "capacity" in updates and payload.capacity is not None:
        bus.capacity = payload.capacity
    if "current_passengers" in updates and payload.current_passengers is not None:
        bus.current_passengers = min(payload.current_passengers, bus.capacity or payload.current_passengers)
    if "available_seats" in updates and payload.available_seats is not None:
        bus.available_seats = payload.available_seats
    else:
        bus.available_seats = max((bus.capacity or 0) - (bus.current_passengers or 0), 0)
    if "latitude" in updates:
        bus.latitude = payload.latitude
    if "longitude" in updates:
        bus.longitude = payload.longitude

    if not bus.status:
        bus.status = "full" if (bus.current_passengers or 0) >= (bus.capacity or 1) else "active"
    bus.last_updated = datetime.utcnow()


@router.get("/dashboard")
def dashboard(db: Session = Depends(get_db)):
    buses = db.query(Bus).all()
    return {
        "total_buses": len(buses),
        "active": sum(1 for bus in buses if (bus.status or "").lower() == "active"),
        "active_buses": sum(1 for bus in buses if (bus.status or "").lower() == "active"),
        "full": sum(1 for bus in buses if (bus.status or "").lower() == "full"),
        "full_buses": sum(1 for bus in buses if (bus.status or "").lower() == "full"),
    }


@router.get("/buses")
def list_buses(db: Session = Depends(get_db)):
    buses = db.query(Bus).order_by(Bus.id.asc()).all()
    return [bus_to_dict(bus) for bus in buses]


@router.post("/buses")
def create_bus(payload: BusPayload, db: Session = Depends(get_db)):
    bus_number = _clean(payload.bus_number)
    if not bus_number:
        raise HTTPException(status_code=422, detail="Bus number is required")
    if db.query(Bus).filter(Bus.bus_number == bus_number).first():
        raise HTTPException(status_code=409, detail="Bus number already exists")

    bus = Bus(
        bus_number=bus_number,
        route_name=_clean(payload.route_name) or "Campus Route",
        driver_name=_clean(payload.driver_name),
        pickup_area=_clean(payload.pickup_area),
        destination=_clean(payload.destination),
        estimated_time=_clean(payload.estimated_time),
        capacity=payload.capacity or 22,
        current_passengers=payload.current_passengers or 0,
        status=_clean(payload.status) or "active",
        latitude=payload.latitude,
        longitude=payload.longitude,
    )
    bus.available_seats = payload.available_seats or max(bus.capacity - bus.current_passengers, 0)
    db.add(bus)
    db.commit()
    db.refresh(bus)
    return bus_to_dict(bus)


@router.put("/buses/{bus_id}")
def update_bus(bus_id: int, payload: BusPayload, db: Session = Depends(get_db)):
    bus = db.query(Bus).filter(Bus.id == bus_id).first()
    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")
    _apply_bus_payload(bus, payload)
    db.commit()
    db.refresh(bus)
    return bus_to_dict(bus)


@router.delete("/buses/{bus_id}")
def delete_bus(bus_id: int, db: Session = Depends(get_db)):
    bus = db.query(Bus).filter(Bus.id == bus_id).first()
    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")
    db.delete(bus)
    db.commit()
    return {"message": "Bus deleted successfully"}


@router.get("/buses/{bus_id}/logs")
def bus_logs(bus_id: int, db: Session = Depends(get_db)):
    bus = db.query(Bus).filter(Bus.id == bus_id).first()
    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")

    logs = (
        db.query(BusLog)
        .filter(BusLog.bus_id == bus_id)
        .order_by(BusLog.created_at.desc())
        .limit(50)
        .all()
    )

    return [
        {
            "id": log.id,
            "bus_id": log.bus_id,
            "event": f"{log.current_passengers} passengers, {log.available_seats} seats available",
            "current_passengers": log.current_passengers,
            "available_seats": log.available_seats,
            "latitude": float(log.latitude) if log.latitude is not None else None,
            "longitude": float(log.longitude) if log.longitude is not None else None,
            "created_at": log.created_at,
        }
        for log in logs
    ]
