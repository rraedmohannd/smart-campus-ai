# backend/app/config.py

from pathlib import Path
from dotenv import load_dotenv
import os

# تحديد مسار ملف .env داخل مجلد backend
env_path = Path(__file__).resolve().parents[1] / ".env"

# تحميل المتغيرات من ملف .env
load_dotenv(dotenv_path=env_path)

# قراءة المتغيرات
DATABASE_URL = os.getenv("DATABASE_URL")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
SECRET_KEY = os.getenv("SECRET_KEY")

# للتأكد أثناء التطوير: اطبع القيم (اختياري)
if __name__ == "__main__":
    print("DATABASE_URL =", DATABASE_URL)
    print("OPENAI_API_KEY =", OPENAI_API_KEY)
    print("SECRET_KEY =", SECRET_KEY)
