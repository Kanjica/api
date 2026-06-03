import logging
import pymysql
from pathlib import Path
from typing import Optional
from dbutils.pooled_db import PooledDB
from app.config import DB_HOST, DB_PORT, DB_NAME, DB_ADMIN_USER, DB_ADMIN_PASS, DB_USER, DB_PASS
import pymysql.err

logger = logging.getLogger(__name__)

SQL_DIR = Path(__file__).parent.parent / "sql"
STARTUP_SCRIPTS = [
    SQL_DIR / "01_create_tables.sql",
    SQL_DIR / "02_triggers.sql",
    SQL_DIR / "03_functions.sql",
    SQL_DIR / "04_views.sql",
    SQL_DIR / "06_inserts.sql"
]

_pool: Optional[PooledDB] = None


def _split_statements(sql: str) -> list[str]:
    """
    Divide o arquivo SQL em statements individuais respeitando blocos
    DELIMITER $$ (usados nas triggers e functions).

    Lógica:
      - Fora de um bloco $$: cada ';' termina um statement
      - Dentro de um bloco $$: apenas '$$' termina o statement
      - Linhas 'DELIMITER x' são consumidas e mudam o delimitador ativo
    """
    statements = []
    current: list[str] = []
    delimiter = ";"

    for line in sql.splitlines():
        stripped = line.strip()

        # troca de delimitador (ex: DELIMITER $$ ou DELIMITER ;)
        if stripped.upper().startswith("DELIMITER"):
            parts = stripped.split()
            if len(parts) >= 2:
                delimiter = parts[1]
            continue

        current.append(line)

        # verifica se a linha termina com o delimitador atual
        if stripped.endswith(delimiter):
            stmt = "\n".join(current).strip()
            # remove o delimitador do final antes de enviar ao MySQL
            if delimiter != ";":
                stmt = stmt[: -len(delimiter)].strip()
            if stmt:
                statements.append(stmt)
            current = []

    # qualquer sobra (sem delimitador final)
    remainder = "\n".join(current).strip()
    if remainder:
        statements.append(remainder)

    return statements


def run_startup_sql() -> None:
    """Executa os scripts DDL na ordem correta usando o usuário admin."""
    conn = pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_ADMIN_USER,
        password=DB_ADMIN_PASS,
        database=DB_NAME,
        charset="utf8mb4",
        autocommit=True,
    )
    try:
        with conn.cursor() as cursor:
            for script_path in STARTUP_SCRIPTS:
                if not script_path.exists():
                    logger.warning("Script não encontrado: %s — pulando.", script_path)
                    continue

                sql = script_path.read_text(encoding="utf-8")
                statements = _split_statements(sql)
                logger.info("Executando %s (%d statements)...", script_path.name, len(statements))

                for stmt in statements:
                    clean = "\n".join(
                        line for line in stmt.splitlines()
                        if not line.strip().startswith("--")
                    ).strip()
                    if clean:
                        try:
                            cursor.execute(clean)
                        except pymysql.err.OperationalError as e:
                            if e.args[0] in (1061, 1050, 1060, 1227, 1304, 1419, 1062):
                                pass
                            else:
                                raise
                        except pymysql.err.IntegrityError as e:
                            if e.args[0] == 1062:
                                pass
                            else:
                                raise

                logger.info("%s concluído.", script_path.name)
    finally:
        conn.close()


def init_pool() -> None:
    global _pool
    _pool = PooledDB(
        creator=pymysql,
        maxconnections=10,
        mincached=2,
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False,
    )
    logger.info("Pool de conexões inicializado (user=%s).", DB_USER)


def close_pool() -> None:
    global _pool
    if _pool:
        _pool.close()
        logger.info("Pool encerrado.")


def get_pool() -> PooledDB:
    if _pool is None:
        raise RuntimeError("Pool não inicializado.")
    return _pool