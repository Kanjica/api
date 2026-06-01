import pymysql
from datetime import datetime
from fastapi import APIRouter, HTTPException, status
from app.database import get_pool
from app.schemas import GPSUpdate, LotacaoEntry, ViagemCreate

router = APIRouter(prefix="/api/v1", tags=["Operacional"])


@router.post("/viagens", status_code=status.HTTP_201_CREATED)
async def criar_viagem(viagem: ViagemCreate):
    """Inicia uma nova viagem. Validada por trg_valida_horario_viagem."""
    conn = get_pool().connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """INSERT INTO Viagem
                       (horario_saida, Veiculo_idVeiculo, Rota_idRota,
                        HorarioEsperadoViagem_idHorarioEsperadoViagem)
                   VALUES (%s, %s, %s, %s)""",
                (viagem.horario_saida, viagem.idVeiculo,
                 viagem.idRota, viagem.idHorarioEsperado),
            )
        conn.commit()
        return {"id": cursor.lastrowid, "mensagem": "Viagem iniciada com sucesso"}
    except pymysql.MySQLError as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=f"Erro de validação: {e.args[1]}")
    finally:
        conn.close()


@router.post("/telemetria/gps", status_code=status.HTTP_201_CREATED)
async def atualizar_posicao(dados: GPSUpdate):
    """Registra coordenadas GPS do veículo em tempo real."""
    conn = get_pool().connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """INSERT INTO Gps_Veiculo (latitude, longitude, data_hora, Veiculo_idVeiculo)
                   VALUES (%s, %s, %s, %s)""",
                (dados.latitude, dados.longitude, datetime.now(), dados.idVeiculo),
            )
        conn.commit()
        return {"status": "ok"}
    except pymysql.MySQLError as e:
        conn.rollback()
        raise HTTPException(status_code=422, detail=f"Erro GPS: {e.args[1]}")
    finally:
        conn.close()


@router.post("/operacao/lotacao", status_code=status.HTTP_201_CREATED)
async def registrar_lotacao(entrada: LotacaoEntry):
    """
    Registra lotação e retorna percentual de ocupação via fn_percentual_ocupacao.
    O trigger trg_valida_lotacao bloqueia inserções acima da capacidade.
    """
    conn = get_pool().connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "INSERT INTO Lotacao (qtd_passageiros, horario, Viagem_idViagem) VALUES (%s, %s, %s)",
                (entrada.qtd_passageiros, datetime.now(), entrada.idViagem),
            )
            cursor.execute(
                "SELECT fn_percentual_ocupacao(%s) AS ocupacao", (entrada.idViagem,)
            )
            row = cursor.fetchone()
            percentual = float(row["ocupacao"]) if row and row["ocupacao"] is not None else 0.0
        conn.commit()
        return {
            "mensagem": "Lotação registrada",
            "percentual_ocupacao": f"{percentual:.1f}%",
            "alerta_superlotacao": percentual > 100,
        }
    except pymysql.MySQLError as e:
        conn.rollback()
        raise HTTPException(status_code=403, detail=e.args[1])
    finally:
        conn.close()
