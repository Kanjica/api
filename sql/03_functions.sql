-- ============================================================
--  MOBILIDADE PERIFÉRICA — FUNCTIONS  (Seção 22)
-- ============================================================
USE mydb;

-- ------------------------------------------------------------
-- 1. fn_percentual_ocupacao
--    Retorna o percentual de ocupação (lotação / capacidade × 100)
--    de uma viagem específica.
--
--    Parâmetro : p_idViagem INT  — ID da viagem a consultar
--    Retorno   : DECIMAL(5,2)   — percentual de ocupação
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_percentual_ocupacao;
DELIMITER $$

CREATE FUNCTION fn_percentual_ocupacao(p_idViagem INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_passageiros INT;
    DECLARE v_capacidade  INT;

    SELECT l.qtd_passageiros,
           v.capacidade
      INTO v_passageiros,
           v_capacidade
      FROM mydb.Viagem  vg
      JOIN mydb.Veiculo v  ON vg.Veiculo_idVeiculo = v.idVeiculo
      JOIN mydb.Lotacao l  ON l.Viagem_idViagem     = vg.idViagem
     WHERE vg.idViagem = p_idViagem
     LIMIT 1;

    RETURN (v_passageiros * 100.0) / v_capacidade;
END$$

DELIMITER ;

-- Exemplo de uso:
-- SELECT fn_percentual_ocupacao(2);


-- ------------------------------------------------------------
-- 2. fn_atraso_medio_rota
--    Retorna a média de atraso em minutos (horário real de saída
--    versus horário planejado) para todas as viagens de uma rota.
--    Retorna 0 quando não há dados.
--
--    Parâmetro : p_idRota INT   — ID da rota a analisar
--    Retorno   : DECIMAL(10,2) — média de atraso em minutos
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_atraso_medio_rota;
DELIMITER $$

CREATE FUNCTION fn_atraso_medio_rota(p_idRota INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_media DECIMAL(10,2);

    SELECT AVG(
               TIMESTAMPDIFF(
                   MINUTE,
                   h.horario_esperado_saida,
                   v.horario_saida
               )
           )
      INTO v_media
      FROM mydb.Viagem v
      JOIN mydb.HorarioEsperadoViagem h
        ON v.HorarioEsperadoViagem_idHorarioEsperadoViagem = h.idHorarioEsperadoViagem
     WHERE v.Rota_idRota = p_idRota;

    RETURN IFNULL(v_media, 0);
END$$

DELIMITER ;

-- Exemplo de uso:
-- SELECT fn_atraso_medio_rota(1);
