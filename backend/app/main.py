
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes import (
    admin,
    auth,
    chat,
    buses,
    librarian,
    library,
    notifications,
    robot,
    rules,
    transporter,
)

app = FastAPI(title="Smart Campus AI Demo")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(chat.router, prefix="/chat", tags=["chat"])
app.include_router(robot.router, prefix="/robot", tags=["robot"])
app.include_router(buses.router, prefix="/buses", tags=["buses"])
app.include_router(library.router, prefix="/library", tags=["library"])
app.include_router(rules.router, prefix="/rules", tags=["rules"])
app.include_router(notifications.router, prefix="/notifications", tags=["notifications"])
app.include_router(admin.router, prefix="/admin", tags=["admin"])
app.include_router(librarian.router, prefix="/librarian", tags=["librarian"])
app.include_router(transporter.router, prefix="/transporter", tags=["transporter"])


@app.get("/")
def root():
    return {"message": "Smart Campus AI Demo Backend is running"}


@app.get("/health")
def health():
    return {"status": "ok"}

