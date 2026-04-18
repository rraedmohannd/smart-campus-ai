from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import auth, chat, buses, library, rules

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
app.include_router(buses.router, prefix="/buses", tags=["buses"])
app.include_router(library.router, prefix="/library", tags=["library"])
app.include_router(rules.router, prefix="/rules", tags=["rules"])

@app.get("/")
def root():
    return {"message": "Smart Campus AI Demo Backend is running"}

@app.get("/health")
def health():
    return {"status": "ok"}
