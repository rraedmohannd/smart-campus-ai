from fastapi import APIRouter

router = APIRouter()

demo_buses = [
    {
        "bus_number": 1,
        "driver_name": "Ahmad Khaled",
        "route_name": "Route 1",
        "pickup_area": "Tabarbour",
        "destination": "MEU",
        "estimated_time_minutes": 35,
        "departure_time": "07:10:00",
        "arrival_time": "07:45:00",
        "trip_day": "Sunday",
        "capacity": 22,
        "current_passengers": 8,
        "available_seats": 14,
        "status": "Active",
        "marker_color": "green",
        "latitude": 31.9455,
        "longitude": 35.9284
    },
    # buses 2–5 exactly as in your spec
]

@router.get("/routes")
def get_routes():
    return demo_buses

@router.get("/live")
def get_live():
    return demo_buses
