from pydantic import BaseModel, Field
from datetime import datetime


class GPSUpdate(BaseModel):
    latitude:  float = Field(..., ge=-90,  le=90)
    longitude: float = Field(..., ge=-180, le=180)
    idVeiculo: int


class LotacaoEntry(BaseModel):
    qtd_passageiros: int = Field(..., gt=0)
    idViagem: int


class ViagemCreate(BaseModel):
    horario_saida:     datetime
    idVeiculo:         int
    idRota:            int
    idHorarioEsperado: int
