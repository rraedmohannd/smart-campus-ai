from app.knowledge.bus_data import bus_data
from app.knowledge.library_data import library_data
from app.knowledge.rules_data import university_rules_data


def get_bus_info() -> dict:
    return bus_data


def get_library_info() -> dict:
    return library_data


def get_rules_info() -> dict:
    return university_rules_data
