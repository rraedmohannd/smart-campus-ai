from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.db import engine
from app.models import models
from app.routes import auth, chat, bus, library, rules, notifications

models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Smart Campus AI",
    description="MEU Smart Campus — FastAPI backend v2.0",
    version="2.0.0",
)
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # مهم جدًا للتجربة
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router,          prefix="/auth",          tags=["Authentication"])
app.include_router(chat.router,          prefix="/chat",          tags=["AI Chatbot"])
app.include_router(bus.router,           prefix="/buses",         tags=["Bus System"])
app.include_router(library.router,       prefix="/library",       tags=["Library"])
app.include_router(rules.router,         prefix="/rules",         tags=["University Rules"])
app.include_router(notifications.router, prefix="/notifications", tags=["Notifications"])


@app.get("/", tags=["Root"])
def root():
    return {
        "project": "Smart Campus AI",
        "version": "2.0.0",
        "university": "Middle East University",
        "docs": "/docs",
    }
