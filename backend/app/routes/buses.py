from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from app.demo_data import demo_buses

router = APIRouter()


class BusLocationUpdate(BaseModel):
    bus_id: str
    latitude: float
    longitude: float


class BusOccupancyUpdate(BaseModel):
    bus_id: str
    current_passengers: int
    capacity: Optional[int] = None


class BusStatusUpdate(BaseModel):
    bus_id: str
    status: str


def find_bus(bus_id: str):
    for bus in demo_buses:
        if (
            str(bus.get("id")) == str(bus_id)
            or str(bus.get("bus_id")) == str(bus_id)
            or str(bus.get("bus_number")) == str(bus_id)
        ):
            return bus
    return None


def recalculate_bus_status(bus: dict):
    capacity = bus.get("capacity", 0)
    current_passengers = bus.get("current_passengers", 0)

    available_seats = max(capacity - current_passengers, 0)
    bus["available_seats"] = available_seats

    if capacity > 0 and current_passengers >= capacity:
        bus["status"] = "full"
    else:
        if bus.get("status") not in ["offline", "maintenance"]:
            bus["status"] = "active"


@router.get("/routes")
def get_routes():
    return demo_buses


@router.get("/live")
def get_live():
    return demo_buses


@router.post("/bus/update")
def update_bus_location(payload: BusLocationUpdate):
    bus = find_bus(payload.bus_id)
    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")

    bus["latitude"] = payload.latitude
    bus["longitude"] = payload.longitude

    return {
        "message": "Bus location updated successfully",
        "bus": bus
    }


@router.post("/occupancy")
def update_occupancy(payload: BusOccupancyUpdate):
    bus = find_bus(payload.bus_id)
    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")

    if payload.current_passengers < 0:
        raise HTTPException(status_code=400, detail="current_passengers cannot be negative")

    bus["current_passengers"] = payload.current_passengers

    if payload.capacity is not None:
        if payload.capacity < 0:
            raise HTTPException(status_code=400, detail="capacity cannot be negative")
        bus["capacity"] = payload.capacity

    recalculate_bus_status(bus)

    return {
        "message": "Bus occupancy updated successfully",
        "bus": bus
    }


@router.post("/bus-status")
def update_bus_status(payload: BusStatusUpdate):
    bus = find_bus(payload.bus_id)
    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")

    allowed_statuses = ["active", "full", "offline", "maintenance"]
    if payload.status not in allowed_statuses:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status. Allowed values: {allowed_statuses}"
        )

    bus["status"] = payload.status

    return {
        "message": "Bus status updated successfully",
        "bus": bus
    }