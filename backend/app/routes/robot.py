
from io import BytesIO
from typing import Optional

from fastapi import APIRouter, File, HTTPException, UploadFile
from fastapi.responses import JSONResponse, StreamingResponse
from pydantic import BaseModel

from app.config import OPENAI_API_KEY

try:
    from openai import OpenAI
except Exception:
    OpenAI = None


router = APIRouter()

client = OpenAI(api_key=OPENAI_API_KEY) if OpenAI and OPENAI_API_KEY else None


# =====================================================
# Models
# =====================================================

class TTSRequest(BaseModel):
    text: str
    voice: Optional[str] = "alloy"


# =====================================================
# Health Check
# =====================================================

@router.get("/")
def robot_status():
    return {
        "status": "ok",
        "service": "Smart Campus Robot API",
    }


# =====================================================
# Speech To Text (OpenAI Whisper)
# =====================================================

@router.post("/stt")
async def speech_to_text(file: UploadFile = File(...)):
    if client is None:
        raise HTTPException(
            status_code=500,
            detail="OPENAI_API_KEY is not configured.",
        )

    allowed_types = {
        "audio/wav",
        "audio/x-wav",
        "audio/mpeg",
        "audio/mp3",
        "audio/mp4",
        "audio/x-m4a",
        "audio/webm",
        "audio/ogg",
        "audio/flac",
        "audio/aac",
        "application/octet-stream",
    }

    if (
        file.content_type is not None
        and file.content_type not in allowed_types
    ):
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported audio format: {file.content_type}",
        )

    try:
        audio_bytes = await file.read()

        if not audio_bytes:
            raise HTTPException(
                status_code=400,
                detail="Uploaded file is empty.",
            )

        audio_file = BytesIO(audio_bytes)
        audio_file.name = file.filename or "audio.wav"
        audio_file.seek(0)

        transcript = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file,
            response_format="text",
        )

        return JSONResponse(
            content={
                "success": True,
                "text": transcript,
            }
        )

    except HTTPException:
        raise

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )


# =====================================================
# Text To Speech (OpenAI TTS)
# =====================================================

@router.post("/tts")
async def text_to_speech(request: TTSRequest):
    if client is None:
        raise HTTPException(
            status_code=500,
            detail="OPENAI_API_KEY is not configured.",
        )

    text = request.text.strip()

    if not text:
        raise HTTPException(
            status_code=400,
            detail="Text cannot be empty.",
        )

    try:
        response = client.audio.speech.create(
            model="gpt-4o-mini-tts",
            voice=request.voice,
            input=text,
            response_format="mp3",
        )

        audio_bytes = response.read()

        if not audio_bytes:
            raise HTTPException(
                status_code=500,
                detail="OpenAI returned empty audio.",
            )

        return StreamingResponse(
            BytesIO(audio_bytes),
            media_type="audio/mpeg",
            headers={
                "Content-Disposition": "inline; filename=robot_response.mp3",
                "Cache-Control": "no-cache",
            },
        )

    except HTTPException:
        raise

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

