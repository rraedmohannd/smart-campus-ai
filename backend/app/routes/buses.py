from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.models import Bus, BusLog

router = APIRouter()


class IoTBusUpdate(BaseModel):
    bus_number: str = Field(..., example="Bus 01")
    current_passengers: int = Field(..., ge=0, example=12)
    latitude: float | None = Field(None, example=31.95)
    longitude: float | None = Field(None, example=35.91)


def bus_to_dict(bus: Bus):
    capacity = bus.capacity or 0
    current = bus.current_passengers or 0
    available = (
        bus.available_seats
        if bus.available_seats is not None
        else max(capacity - current, 0)
    )
    occupancy = round((current / capacity) * 100) if capacity else 0

    return {
        "id": bus.id,
        "bus_number": bus.bus_number,
        "route_name": bus.route_name,
        "driver_name": bus.driver_name,
        "pickup_area": bus.pickup_area,
        "destination": bus.destination,
        "estimated_time": bus.estimated_time,
        "capacity": capacity,
        "current_passengers": current,
        "available_seats": available,
        "occupancy_percent": occupancy,
        "status": bus.status,
        "latitude": float(bus.latitude) if bus.latitude is not None else None,
        "longitude": float(bus.longitude) if bus.longitude is not None else None,
        "last_updated": bus.last_updated,
    }


@router.get("/")
def get_buses(db: Session = Depends(get_db)):
    buses = db.query(Bus).order_by(Bus.id.asc()).all()
    return [bus_to_dict(bus) for bus in buses]


@router.get("/routes")
def get_bus_routes(db: Session = Depends(get_db)):
    buses = db.query(Bus).order_by(Bus.id.asc()).all()
    return [bus_to_dict(bus) for bus in buses]


@router.get("/live")
def get_live_buses(db: Session = Depends(get_db)):
    buses = db.query(Bus).order_by(Bus.id.asc()).all()
    return [bus_to_dict(bus) for bus in buses]


@router.post("/iot/bus-update")
def iot_bus_update(payload: IoTBusUpdate, db: Session = Depends(get_db)):
    bus = db.query(Bus).filter(Bus.bus_number == payload.bus_number).first()

    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")

    if payload.current_passengers > bus.capacity:
        raise HTTPException(
            status_code=400,
            detail=f"current_passengers cannot exceed capacity ({bus.capacity})"
        )

    available_seats = max(bus.capacity - payload.current_passengers, 0)
    status = "full" if payload.current_passengers >= bus.capacity else "active"

    bus.current_passengers = payload.current_passengers
    bus.available_seats = available_seats
    bus.status = status
    bus.latitude = payload.latitude
    bus.longitude = payload.longitude
    bus.last_updated = datetime.utcnow()

    log = BusLog(
        bus_id=bus.id,
        current_passengers=payload.current_passengers,
        available_seats=available_seats,
        latitude=payload.latitude,
        longitude=payload.longitude,
    )

    db.add(log)
    db.commit()
    db.refresh(bus)

    return {
        "message": "IoT bus update received successfully",
        "bus": bus_to_dict(bus),
    }


@router.post("/bus/update")
def old_bus_update_alias(payload: IoTBusUpdate, db: Session = Depends(get_db)):
    return iot_bus_update(payload, db)


@router.get("/{bus_id}")
def get_bus(bus_id: int, db: Session = Depends(get_db)):
    bus = db.query(Bus).filter(Bus.id == bus_id).first()

    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")

    return bus_to_dict(bus)


@router.get("/{bus_id}/logs")
def get_bus_logs(bus_id: int, db: Session = Depends(get_db)):
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

    return {
        "bus_id": bus.id,
        "bus_number": bus.bus_number,
        "logs": [
            {
                "id": log.id,
                "current_passengers": log.current_passengers,
                "available_seats": log.available_seats,
                "latitude": float(log.latitude) if log.latitude is not None else None,
                "longitude": float(log.longitude) if log.longitude is not None else None,
                "created_at": log.created_at,
            }
            for log in logs
        ],
    }
