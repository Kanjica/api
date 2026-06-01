-- ============================================================
--  MOBILIDADE PERIFÉRICA — VIEWS GERENCIAIS  (Seção 23)
-- ============================================================
USE mydb;

-- ------------------------------------------------------------
-- 1. vw_situacao_frota_tempo_real
--    Exibe os veículos em viagem no momento, com lotação atual
--    e percentual de ocupação calculado pela function.
--    Atende ao RF de Rastreamento em Tempo Real.
-- ------------------------------------------------------------
--DROP VIEW IF EXISTS mydb.vw_situacao_frota_tempo_real;

CREATE OR REPLACE VIEW mydb.vw_situacao_frota_tempo_real AS
SELECT
    v.placa                                       AS placa_veiculo,
    l.codigo                                      AS codigo_linha,
    l.nome                                        AS nome_linha,
    vg.idViagem,
    lo.qtd_passageiros,
    v.capacidade,
    fn_percentual_ocupacao(vg.idViagem)           AS percentual_lotacao
FROM mydb.Veiculo      v
JOIN mydb.LInha_Onibus l   ON v.LInha_Onibus_idLInha_Onibus = l.idLInha_Onibus
JOIN mydb.Viagem       vg  ON vg.Veiculo_idVeiculo           = v.idVeiculo
LEFT JOIN mydb.Lotacao lo  ON lo.Viagem_idViagem             = vg.idViagem
WHERE vg.horario_chegada IS NULL;   -- viagens ainda sem registro de chegada = em andamento


-- ------------------------------------------------------------
-- 2. vw_performance_pontualidade_empresas
--    Compara horários reais de saída com o planejamento,
--    expondo o atraso em minutos por viagem e empresa.
--    Subsidia auditorias de contratos públicos.
-- ------------------------------------------------------------
--DROP VIEW IF EXISTS mydb.vw_performance_pontualidade_empresas;

CREATE OR REPLACE VIEW mydb.vw_performance_pontualidade_empresas AS
SELECT
    e.nome                                                AS empresa_operadora,
    l.codigo                                              AS linha,
    h.horario_esperado_saida,
    v.horario_saida                                       AS horario_real_saida,
    TIMESTAMPDIFF(
        MINUTE,
        h.horario_esperado_saida,
        v.horario_saida
    )                                                     AS minutos_atraso
FROM mydb.Empresa              e
JOIN mydb.LInha_Onibus         l   ON l.Empresa_idEmpresa                               = e.idEmpresa
JOIN mydb.Rota                 r   ON r.LInha_Onibus_idLInha_Onibus                     = l.idLInha_Onibus
JOIN mydb.Viagem               v   ON v.Rota_idRota                                     = r.idRota
JOIN mydb.HorarioEsperadoViagem h  ON v.HorarioEsperadoViagem_idHorarioEsperadoViagem   = h.idHorarioEsperadoViagem;


-- ------------------------------------------------------------
-- 3. vw_deficit_infraestrutura_periferica
--    Cruza pontos de parada com dados socioeconômicos dos bairros,
--    calculando a densidade de habitantes por ponto.
--    Identifica áreas com cobertura insuficiente (ODS 11).
-- ------------------------------------------------------------
--DROP VIEW IF EXISTS mydb.vw_deficit_infraestrutura_periferica;

CREATE OR REPLACE VIEW mydb.vw_deficit_infraestrutura_periferica AS
SELECT
    b.nome                                                        AS bairro,
    b.populacao,
    b.renda_media,
    COUNT(p.idPonto_Parada)                                       AS total_pontos_existentes,
    ROUND(
        b.populacao / NULLIF(COUNT(p.idPonto_Parada), 0),
        2
    )                                                             AS densidade_hab_por_ponto
FROM mydb.Bairro      b
LEFT JOIN mydb.Ponto_Parada p ON p.Bairro_idBairro = b.idBairro
GROUP BY b.idBairro, b.nome, b.populacao, b.renda_media;
