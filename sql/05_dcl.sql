-- ============================================================
--  MOBILIDADE PERIFÉRICA — DCL (CONTROLE DE ACESSO)
--  Seção 24 do projeto
--  Execute conectado como root ou com GRANT OPTION
-- ============================================================
USE mydb;

-- ============================================================
--  CRIAÇÃO DOS USUÁRIOS
-- ============================================================

-- ------------------------------------------------------------
-- 1. admin_mobilidade
--    Acesso total ao banco. Usado no startup DDL da API.
--    Nunca exposto nos endpoints de runtime.
-- ------------------------------------------------------------
CREATE USER IF NOT EXISTS 'admin_mobilidade'@'localhost'
    IDENTIFIED BY 'senha_admin_segura';

GRANT ALL PRIVILEGES ON mydb.* TO 'admin_mobilidade'@'localhost';

-- ------------------------------------------------------------
-- 2. fiscal_operacional
--    Acesso DML nas tabelas operacionais.
--    É o usuário do pool de conexões da API em runtime.
--    Sem DELETE para preservar o log de auditoria.
-- ------------------------------------------------------------
CREATE USER IF NOT EXISTS 'fiscal_operacional'@'%'
    IDENTIFIED BY 'senha_fiscal_segura';

GRANT SELECT, INSERT, UPDATE ON mydb.Viagem                          TO 'fiscal_operacional'@'%';
GRANT SELECT, INSERT, UPDATE ON mydb.Lotacao                         TO 'fiscal_operacional'@'%';
GRANT SELECT, INSERT, UPDATE ON mydb.Gps_Veiculo                     TO 'fiscal_operacional'@'%';
GRANT SELECT, INSERT, UPDATE ON mydb.Viagem_has_Rota_has_Ponto_Parada TO 'fiscal_operacional'@'%';

-- Leitura das tabelas de referência (necessário para JOINs dentro das views e functions)
GRANT SELECT ON mydb.Veiculo          TO 'fiscal_operacional'@'%';
GRANT SELECT ON mydb.Rota             TO 'fiscal_operacional'@'%';
GRANT SELECT ON mydb.LInha_Onibus    TO 'fiscal_operacional'@'%';
GRANT SELECT ON mydb.Empresa          TO 'fiscal_operacional'@'%';
GRANT SELECT ON mydb.Ponto_Parada     TO 'fiscal_operacional'@'%';
GRANT SELECT ON mydb.Bairro           TO 'fiscal_operacional'@'%';
GRANT SELECT ON mydb.HorarioEsperadoViagem TO 'fiscal_operacional'@'%';
GRANT SELECT ON mydb.Rota_has_Ponto_Parada TO 'fiscal_operacional'@'%';
GRANT SELECT ON mydb.Tempo_Deslocamento    TO 'fiscal_operacional'@'%';

-- Acesso às views gerenciais (endpoints /analise/*)
GRANT SELECT ON mydb.vw_situacao_frota_tempo_real           TO 'fiscal_operacional'@'%';
GRANT SELECT ON mydb.vw_performance_pontualidade_empresas   TO 'fiscal_operacional'@'%';
GRANT SELECT ON mydb.vw_deficit_infraestrutura_periferica   TO 'fiscal_operacional'@'%';

-- Permissão para executar as functions da Seção 22
GRANT EXECUTE ON FUNCTION mydb.fn_percentual_ocupacao  TO 'fiscal_operacional'@'%';
GRANT EXECUTE ON FUNCTION mydb.fn_atraso_medio_rota    TO 'fiscal_operacional'@'%';

-- ------------------------------------------------------------
-- 3. analista_planejamento
--    Somente leitura. Acesso restrito às views e à tabela Bairro.
--    Não acessa dados brutos de veículos, placas ou GPS.
-- ------------------------------------------------------------
CREATE USER IF NOT EXISTS 'analista_planejamento'@'%'
    IDENTIFIED BY 'senha_analista_segura';

GRANT SELECT ON mydb.vw_deficit_infraestrutura_periferica  TO 'analista_planejamento'@'%';
GRANT SELECT ON mydb.vw_performance_pontualidade_empresas  TO 'analista_planejamento'@'%';
GRANT SELECT ON mydb.vw_situacao_frota_tempo_real          TO 'analista_planejamento'@'%';
GRANT SELECT ON mydb.Bairro                                TO 'analista_planejamento'@'%';

-- Pode consultar o atraso médio por rota para análise de planejamento
GRANT EXECUTE ON FUNCTION mydb.fn_atraso_medio_rota TO 'analista_planejamento'@'%';

-- ============================================================
--  APLICA AS PERMISSÕES IMEDIATAMENTE
-- ============================================================
FLUSH PRIVILEGES;


-- ============================================================
--  CONSULTAS ÚTEIS PARA AUDITORIA DE PERMISSÕES
-- ============================================================

-- Ver todas as permissões de um usuário específico:
-- SHOW GRANTS FOR 'fiscal_operacional'@'%';
-- SHOW GRANTS FOR 'analista_planejamento'@'%';
-- SHOW GRANTS FOR 'admin_mobilidade'@'localhost';

-- Listar todos os usuários do banco:
-- SELECT user, host FROM mysql.user WHERE user NOT LIKE 'mysql%';

-- Revogar uma permissão (exemplo):
-- REVOKE INSERT ON mydb.Viagem FROM 'fiscal_operacional'@'%';

-- Remover um usuário completamente (exemplo):
-- DROP USER IF EXISTS 'analista_planejamento'@'%';
