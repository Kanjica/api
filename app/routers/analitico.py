from typing import Optional
from fastapi import APIRouter
from app.database import get_pool

router = APIRouter(prefix="/api/v1/analise", tags=["Analítico"])


@router.get("/deficit-bairros")
async def relatorio_infraestrutura():
    """Consome vw_deficit_infraestrutura_periferica (ODS 11)."""
    conn = get_pool().connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT * FROM vw_deficit_infraestrutura_periferica ORDER BY populacao DESC"
            )
            return cursor.fetchall()
    finally:
        conn.close()


@router.get("/pontualidade")
async def relatorio_atrasos(linha_codigo: Optional[int] = None):
    """Analisa atrasos por linha usando vw_performance_pontualidade_empresas."""
    conn = get_pool().connection()
    try:
        with conn.cursor() as cursor:
            if linha_codigo is not None:
                cursor.execute(
                    "SELECT * FROM vw_performance_pontualidade_empresas WHERE linha = %s",
                    (linha_codigo,),
                )
            else:
                cursor.execute("SELECT * FROM vw_performance_pontualidade_empresas")
            return cursor.fetchall()
    finally:
        conn.close()
