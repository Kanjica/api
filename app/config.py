import os
from pathlib import Path
from dotenv import load_dotenv

# Caminho absoluto até o .env na raiz do projeto,
# independente de onde o uvicorn é chamado
_env_path = Path(__file__).parent.parent / ".env"
load_dotenv(dotenv_path=_env_path)

DB_HOST       = os.getenv("DB_HOST", "localhost")
DB_PORT       = int(os.getenv("DB_PORT", "3306"))
DB_NAME       = os.getenv("DB_NAME", "mydb")

DB_ADMIN_USER = os.getenv("DB_ADMIN_USER", "admin_mobilidade")
DB_ADMIN_PASS = os.getenv("DB_ADMIN_PASS", "")

DB_USER       = os.getenv("DB_USER", "fiscal_operacional")
DB_PASS       = os.getenv("DB_PASS", "")