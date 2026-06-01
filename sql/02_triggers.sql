-- ============================================================
--  MOBILIDADE PERIFÉRICA — TRIGGERS
--  Seções 20 (validação) e 21 (auditoria)
-- ============================================================
USE mydb;

-- ============================================================
--  TRIGGERS DE VALIDAÇÃO  (Seção 20)
-- ============================================================

-- ------------------------------------------------------------
-- 1. trg_valida_lotacao
--    Impede inserção de lotação que exceda a capacidade do veículo.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_valida_lotacao;
DELIMITER $$

CREATE TRIGGER trg_valida_lotacao
BEFORE INSERT ON mydb.Lotacao
FOR EACH ROW
BEGIN
    DECLARE v_capacidade INT;

    SELECT v.capacidade
      INTO v_capacidade
      FROM mydb.Viagem  vg
      JOIN mydb.Veiculo v  ON vg.Veiculo_idVeiculo = v.idVeiculo
     WHERE vg.idViagem = NEW.Viagem_idViagem;

    IF NEW.qtd_passageiros > v_capacidade THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lotacao excede a capacidade do veiculo';
    END IF;
END$$

DELIMITER ;

-- Exemplo de teste:
-- INSERT INTO Lotacao (qtd_passageiros, horario, Viagem_idViagem)
-- VALUES (70, NOW(), 5);   -- deve falhar se capacidade < 70


-- ------------------------------------------------------------
-- 2. trg_valida_horario_viagem
--    Garante que o horário de chegada seja posterior ao de saída.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_valida_horario_viagem;
DELIMITER $$

CREATE TRIGGER trg_valida_horario_viagem
BEFORE INSERT ON mydb.Viagem
FOR EACH ROW
BEGIN
    IF NEW.horario_chegada <= NEW.horario_saida THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Horario de chegada deve ser posterior ao de saida';
    END IF;
END$$

DELIMITER ;

-- Exemplo de teste (deve falhar — chegada antes da saída):
-- INSERT INTO Viagem (horario_saida, horario_chegada,
--                     Veiculo_idVeiculo, Rota_idRota,
--                     HorarioEsperadoViagem_idHorarioEsperadoViagem)
-- VALUES ('2026-05-30 09:00:00', '2026-05-30 08:00:00', 1, 1, 1);


-- ------------------------------------------------------------
-- 3. trg_valida_gps
--    Valida que latitude e longitude estejam dentro dos limites geográficos.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_valida_gps;
DELIMITER $$

CREATE TRIGGER trg_valida_gps
BEFORE INSERT ON mydb.Gps_Veiculo
FOR EACH ROW
BEGIN
    IF NEW.latitude < -90 OR NEW.latitude > 90 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Latitude invalida';
    END IF;

    IF NEW.longitude < -180 OR NEW.longitude > 180 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Longitude invalida';
    END IF;
END$$

DELIMITER ;

-- Exemplo de teste (deve falhar — latitude 200 é inválida):
-- INSERT INTO Gps_Veiculo (latitude, longitude, data_hora, Veiculo_idVeiculo)
-- VALUES (200, -38.5014, NOW(), 1);


-- ------------------------------------------------------------
-- 4. trg_valida_checkin
--    Impede que o check-in em uma parada seja anterior ao da parada anterior.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_valida_checkin;
DELIMITER $$

CREATE TRIGGER trg_valida_checkin
BEFORE INSERT ON mydb.Viagem_has_Rota_has_Ponto_Parada
FOR EACH ROW
BEGIN
    DECLARE v_checkin_anterior DATETIME;

    SELECT check_in
      INTO v_checkin_anterior
      FROM mydb.Viagem_has_Rota_has_Ponto_Parada
     WHERE Viagem_idViagem            = NEW.Viagem_idViagem
       AND Rota_has_Ponto_Parada_ordem = NEW.Rota_has_Ponto_Parada_ordem - 1;

    IF v_checkin_anterior IS NOT NULL
       AND NEW.check_in < v_checkin_anterior THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Check-in anterior ao da parada anterior';
    END IF;
END$$

DELIMITER ;

-- Exemplo de teste (deve falhar se parada 2 tiver check-in posterior):
-- INSERT INTO Viagem_has_Rota_has_Ponto_Parada
--        (Viagem_idViagem, Rota_has_Ponto_Parada_Rota_idRota,
--         Rota_has_Ponto_Parada_ordem, check_in)
-- VALUES (1, 1, 3, '2026-05-20 07:20:00');


-- ============================================================
--  TRIGGERS DE AUDITORIA  (Seção 21)
-- ============================================================

-- ------------------------------------------------------------
-- 5. trg_auditoria_lotacao
--    Registra alterações na quantidade de passageiros da tabela Lotacao.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_auditoria_lotacao;
DELIMITER $$

CREATE TRIGGER trg_auditoria_lotacao
AFTER UPDATE ON mydb.Lotacao
FOR EACH ROW
BEGIN
    IF OLD.qtd_passageiros <> NEW.qtd_passageiros THEN
        INSERT INTO mydb.Auditoria_Lotacao
               (idLotacao, valor_antigo, valor_novo, usuario)
        VALUES (OLD.idLotacao,
                OLD.qtd_passageiros,
                NEW.qtd_passageiros,
                CURRENT_USER());
    END IF;
END$$

DELIMITER ;


-- ------------------------------------------------------------
-- 6. trg_auditoria_viagem
--    Registra alterações nos horários de saída/chegada da tabela Viagem.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_auditoria_viagem;
DELIMITER $$

CREATE TRIGGER trg_auditoria_viagem
AFTER UPDATE ON mydb.Viagem
FOR EACH ROW
BEGIN
    IF OLD.horario_saida   <> NEW.horario_saida
    OR OLD.horario_chegada <> NEW.horario_chegada THEN
        INSERT INTO mydb.Auditoria_Viagem
               (idViagem,
                saida_antiga,   saida_nova,
                chegada_antiga, chegada_nova,
                usuario)
        VALUES (OLD.idViagem,
                OLD.horario_saida,   NEW.horario_saida,
                OLD.horario_chegada, NEW.horario_chegada,
                CURRENT_USER());
    END IF;
END$$

DELIMITER ;
