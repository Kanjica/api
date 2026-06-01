-- ============================================================
--  MOBILIDADE PERIFÉRICA — SCRIPT DDL (CREATE TABLES)
--  SGBD: MySQL 8.0 | Engine: InnoDB | Charset: utf8mb4
-- ============================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
-- ------------------------------------------------------------
-- Schema
-- ------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS mydb DEFAULT CHARACTER SET utf8mb4;
USE mydb;

-- ------------------------------------------------------------
-- Tabela: Empresa
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Empresa (
    idEmpresa  INT          NOT NULL AUTO_INCREMENT,
    nome       VARCHAR(120) NOT NULL,
    cnpj       VARCHAR(18)  NULL,
    telefone   VARCHAR(15)  NULL,
    PRIMARY KEY (idEmpresa),
    UNIQUE INDEX idEmpresa_UNIQUE (idEmpresa ASC),
    UNIQUE INDEX nome_UNIQUE      (nome      ASC)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: LInha_Onibus
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.LInha_Onibus (
    idLInha_Onibus    INT          NOT NULL AUTO_INCREMENT,
    codigo            INT          NOT NULL,
    nome              VARCHAR(150) NULL,
    Empresa_idEmpresa INT          NOT NULL,
    PRIMARY KEY (idLInha_Onibus),
    UNIQUE INDEX idLInha_Onibus_UNIQUE (idLInha_Onibus    ASC),
    UNIQUE INDEX codigo_UNIQUE         (codigo            ASC),
    INDEX fk_LInha_Onibus_Empresa_idx  (Empresa_idEmpresa ASC),
    CONSTRAINT fk_LInha_Onibus_Empresa
        FOREIGN KEY (Empresa_idEmpresa)
        REFERENCES mydb.Empresa (idEmpresa)
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: Veiculo
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Veiculo (
    idVeiculo                    INT         NOT NULL AUTO_INCREMENT,
    placa                        VARCHAR(7)  NOT NULL,
    capacidade                   INT         NULL,
    LInha_Onibus_idLInha_Onibus  INT         NOT NULL,
    status                       ENUM('ATIVO','EXCLUIDO') NOT NULL DEFAULT 'ATIVO',
    PRIMARY KEY (idVeiculo),
    UNIQUE INDEX idVeiculo_UNIQUE (idVeiculo ASC),
    UNIQUE INDEX placa_UNIQUE     (placa     ASC),
    INDEX fk_Veiculo_LInha_Onibus1_idx (LInha_Onibus_idLInha_Onibus ASC),
    CONSTRAINT fk_Veiculo_LInha_Onibus1
        FOREIGN KEY (LInha_Onibus_idLInha_Onibus)
        REFERENCES mydb.LInha_Onibus (idLInha_Onibus)
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: Gps_Veiculo
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Gps_Veiculo (
    idGps_Veiculo     INT             NOT NULL AUTO_INCREMENT,
    latitude          DECIMAL(9,6)    NULL,
    longitude         DECIMAL(9,6)    NULL,
    data_hora         TIMESTAMP       NULL DEFAULT CURRENT_TIMESTAMP,
    Veiculo_idVeiculo INT             NOT NULL,
    PRIMARY KEY (idGps_Veiculo),
    UNIQUE INDEX idGps_Veiculo_UNIQUE  (idGps_Veiculo    ASC),
    INDEX fk_Gps_Veiculo_Veiculo1_idx  (Veiculo_idVeiculo ASC),
    CONSTRAINT fk_Gps_Veiculo_Veiculo1
        FOREIGN KEY (Veiculo_idVeiculo)
        REFERENCES mydb.Veiculo (idVeiculo)
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: Rota
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Rota (
    idRota                      INT                  NOT NULL AUTO_INCREMENT,
    sentido                     ENUM('IDA','VOLTA')  NULL,
    LInha_Onibus_idLInha_Onibus INT                  NOT NULL,
    PRIMARY KEY (idRota),
    UNIQUE INDEX idRota_UNIQUE             (idRota ASC),
    INDEX fk_Rota_LInha_Onibus1_idx        (LInha_Onibus_idLInha_Onibus ASC),
    CONSTRAINT fk_Rota_LInha_Onibus1
        FOREIGN KEY (LInha_Onibus_idLInha_Onibus)
        REFERENCES mydb.LInha_Onibus (idLInha_Onibus)
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: HorarioEsperadoViagem
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.HorarioEsperadoViagem (
    idHorarioEsperadoViagem    INT         NOT NULL AUTO_INCREMENT,
    horario_esperado_chegada   VARCHAR(45) NULL,
    horario_esperado_saida     VARCHAR(45) NULL,
    PRIMARY KEY (idHorarioEsperadoViagem),
    UNIQUE INDEX idHorarioEsperadoViagem_UNIQUE (idHorarioEsperadoViagem ASC)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: Viagem
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Viagem (
    idViagem                                      INT       NOT NULL AUTO_INCREMENT,
    horario_saida                                 TIMESTAMP NULL,
    horario_chegada                               TIMESTAMP NULL,
    Veiculo_idVeiculo                             INT       NOT NULL,
    Rota_idRota                                   INT       NOT NULL,
    HorarioEsperadoViagem_idHorarioEsperadoViagem INT       NOT NULL,
    PRIMARY KEY (idViagem),
    UNIQUE INDEX idViagem_UNIQUE                        (idViagem ASC),
    INDEX fk_Viagem_Veiculo1_idx                        (Veiculo_idVeiculo ASC),
    INDEX fk_Viagem_Rota1_idx                           (Rota_idRota ASC),
    INDEX fk_Viagem_HorarioEsperadoViagem1_idx          (HorarioEsperadoViagem_idHorarioEsperadoViagem ASC),
    CONSTRAINT fk_Viagem_Veiculo1
        FOREIGN KEY (Veiculo_idVeiculo)
        REFERENCES mydb.Veiculo (idVeiculo)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_Viagem_Rota1
        FOREIGN KEY (Rota_idRota)
        REFERENCES mydb.Rota (idRota)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_Viagem_HorarioEsperadoViagem1
        FOREIGN KEY (HorarioEsperadoViagem_idHorarioEsperadoViagem)
        REFERENCES mydb.HorarioEsperadoViagem (idHorarioEsperadoViagem)
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: Bairro
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Bairro (
    idBairro    INT            NOT NULL AUTO_INCREMENT,
    nome        VARCHAR(100)   NULL,
    populacao   INT            NULL,
    renda_media DECIMAL(9,2)   NULL,
    PRIMARY KEY (idBairro),
    UNIQUE INDEX idBairro_UNIQUE (idBairro ASC)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: Ponto_Parada
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Ponto_Parada (
    idPonto_Parada INT          NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(45)  NULL,
    latitude       DECIMAL(9,6) NULL,
    longitude      DECIMAL(9,6) NULL,
    Bairro_idBairro INT         NOT NULL,
    PRIMARY KEY (idPonto_Parada),
    UNIQUE INDEX idPonto_Parada_UNIQUE    (idPonto_Parada  ASC),
    INDEX fk_Ponto_Parada_Bairro1_idx     (Bairro_idBairro ASC),
    CONSTRAINT fk_Ponto_Parada_Bairro1
        FOREIGN KEY (Bairro_idBairro)
        REFERENCES mydb.Bairro (idBairro)
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: Tempo_Deslocamento
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Tempo_Deslocamento (
    idTempo_Deslocamento INT NOT NULL AUTO_INCREMENT,
    tempo                INT NULL,
    PRIMARY KEY (idTempo_Deslocamento),
    UNIQUE INDEX idTempo_Deslocamento_UNIQUE (idTempo_Deslocamento ASC)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: Lotacao
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Lotacao (
    idLotacao        INT       NOT NULL AUTO_INCREMENT,
    qtd_passageiros  INT       NULL,
    horario          TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    Viagem_idViagem  INT       NOT NULL,
    PRIMARY KEY (idLotacao),
    UNIQUE INDEX idLotacao_UNIQUE     (idLotacao       ASC),
    INDEX fk_Lotacao_Viagem1_idx      (Viagem_idViagem ASC),
    CONSTRAINT fk_Lotacao_Viagem1
        FOREIGN KEY (Viagem_idViagem)
        REFERENCES mydb.Viagem (idViagem)
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: Rota_has_Ponto_Parada  (associativa N:N com atributos)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Rota_has_Ponto_Parada (
    Rota_idRota                              INT         NOT NULL,
    Ponto_Parada_idPonto_Parada              INT         NOT NULL,
    ordem                                    INT         NOT NULL,
    Tempo_Deslocamento_idTempo_Deslocamento  INT         NOT NULL,
    previsao_chegada                         VARCHAR(45) NULL,
    PRIMARY KEY (Rota_idRota, ordem),
    INDEX fk_Rota_has_Ponto_Parada_Ponto_Parada1_idx        (Ponto_Parada_idPonto_Parada             ASC),
    INDEX fk_Rota_has_Ponto_Parada_Rota1_idx                (Rota_idRota                             ASC),
    INDEX fk_Rota_has_Ponto_Parada_Tempo_Deslocamento1_idx  (Tempo_Deslocamento_idTempo_Deslocamento ASC),
    CONSTRAINT fk_Rota_has_Ponto_Parada_Rota1
        FOREIGN KEY (Rota_idRota)
        REFERENCES mydb.Rota (idRota)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_Rota_has_Ponto_Parada_Ponto_Parada1
        FOREIGN KEY (Ponto_Parada_idPonto_Parada)
        REFERENCES mydb.Ponto_Parada (idPonto_Parada)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_Rota_has_Ponto_Parada_Tempo_Deslocamento1
        FOREIGN KEY (Tempo_Deslocamento_idTempo_Deslocamento)
        REFERENCES mydb.Tempo_Deslocamento (idTempo_Deslocamento)
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabela: Viagem_has_Rota_has_Ponto_Parada  (log de check-in)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Viagem_has_Rota_has_Ponto_Parada (
    Viagem_idViagem                      INT      NOT NULL,
    Rota_has_Ponto_Parada_Rota_idRota    INT      NOT NULL,
    Rota_has_Ponto_Parada_ordem          INT      NOT NULL,
    check_in                             DATETIME NULL,
    PRIMARY KEY (Viagem_idViagem, Rota_has_Ponto_Parada_Rota_idRota, Rota_has_Ponto_Parada_ordem),
    INDEX fk_Viagem_has_Rota_has_Ponto_Parada_Rota_has_Ponto_Parada1_idx
          (Rota_has_Ponto_Parada_Rota_idRota ASC, Rota_has_Ponto_Parada_ordem ASC),
    INDEX fk_Viagem_has_Rota_has_Ponto_Parada_Viagem1_idx
          (Viagem_idViagem ASC),
    CONSTRAINT fk_Viagem_has_Rota_has_Ponto_Parada_Viagem1
        FOREIGN KEY (Viagem_idViagem)
        REFERENCES mydb.Viagem (idViagem)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_Viagem_has_Rota_has_Ponto_Parada_Rota_has_Ponto_Parada1
        FOREIGN KEY (Rota_has_Ponto_Parada_Rota_idRota, Rota_has_Ponto_Parada_ordem)
        REFERENCES mydb.Rota_has_Ponto_Parada (Rota_idRota, ordem)
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Tabelas de Auditoria  (necessárias para os triggers da Seção 21)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mydb.Auditoria_Lotacao (
    idAuditoria  INT          NOT NULL AUTO_INCREMENT,
    idLotacao    INT          NULL,
    valor_antigo INT          NULL,
    valor_novo   INT          NULL,
    usuario      VARCHAR(100) NULL,
    data_evento  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idAuditoria)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS mydb.Auditoria_Viagem (
    idAuditoria   INT          NOT NULL AUTO_INCREMENT,
    idViagem      INT          NULL,
    saida_antiga  TIMESTAMP    NULL,
    saida_nova    TIMESTAMP    NULL,
    chegada_antiga TIMESTAMP   NULL,
    chegada_nova  TIMESTAMP    NULL,
    usuario       VARCHAR(100) NULL,
    data_evento   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idAuditoria)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Índices operacionais / táticos / estratégicos  (Seção 9)
-- ------------------------------------------------------------
CREATE INDEX idx_viagem_horario_saida  ON mydb.Viagem  (horario_saida);
CREATE INDEX idx_bairro_nome           ON mydb.Bairro  (nome);
CREATE INDEX idx_lotacao_viagem_qtd    ON mydb.Lotacao (Viagem_idViagem, qtd_passageiros);
CREATE INDEX idx_viagem_veiculo        ON mydb.Viagem  (Veiculo_idVeiculo);
CREATE INDEX idx_vrpp_rota_ordem       ON mydb.Viagem_has_Rota_has_Ponto_Parada
                                           (Rota_has_Ponto_Parada_Rota_idRota, Rota_has_Ponto_Parada_ordem);

-- ------------------------------------------------------------
-- Restaura configurações originais
-- ------------------------------------------------------------
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
