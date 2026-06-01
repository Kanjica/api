USE mydb;

-- Empresas
INSERT INTO Empresa (nome, cnpj, telefone) VALUES
('OTT Transportes',     '12.345.678/0001-01', '71900000001'),
('Integra Bus',         '23.456.789/0001-02', '71900000002'),
('TransSalvador',       '34.567.890/0001-03', '71900000003');

-- Linhas
INSERT INTO LInha_Onibus (codigo, nome, Empresa_idEmpresa) VALUES
(101, 'Cajazeiras - Centro',     1),
(202, 'Pau da Lima - Lapa',      2),
(303, 'Fazenda Grande - Iguatemi', 3),
(404, 'Mussurunga - Comércio',   1),
(505, 'Periperi - Barroquinha',  2);

-- Veículos
INSERT INTO Veiculo (placa, capacidade, LInha_Onibus_idLInha_Onibus) VALUES
('ABC1D23', 80, 1),
('DEF2E34', 80, 2),
('GHI3F45', 60, 3),
('JKL4G56', 60, 4),
('MNO5H67', 80, 5);

-- Bairros
INSERT INTO Bairro (nome, populacao, renda_media) VALUES
('Cajazeiras',     120000, 1200.00),
('Pau da Lima',     95000,  980.00),
('Fazenda Grande',  85000,  850.00),
('Mussurunga',      70000, 1100.00),
('Periperi',        90000,  750.00);

-- Pontos de Parada
INSERT INTO Ponto_Parada (nome, latitude, longitude, Bairro_idBairro) VALUES
('Terminal Cajazeiras',  -12.9500, -38.4200, 1),
('Praça Pau da Lima',    -12.9300, -38.4100, 2),
('Faz. Grande Terminal', -12.9100, -38.3900, 3),
('Mussurunga Centro',    -12.8900, -38.3300, 4),
('Periperi Terminal',    -12.8700, -38.5100, 5);

-- Tempo de Deslocamento
INSERT INTO Tempo_Deslocamento (tempo) VALUES (10),(15),(20),(25),(30);

-- Rotas
INSERT INTO Rota (sentido, LInha_Onibus_idLInha_Onibus) VALUES
('IDA',   1), ('VOLTA', 1),
('IDA',   2), ('VOLTA', 2),
('IDA',   3);

-- Horários Esperados
INSERT INTO HorarioEsperadoViagem (horario_esperado_chegada, horario_esperado_saida) VALUES
('07:30', '06:00'), ('08:30', '07:00'), ('09:30', '08:00'),
('10:30', '09:00'), ('11:30', '10:00'), ('12:30', '11:00'),
('13:30', '12:00'), ('14:30', '13:00'), ('15:30', '14:00'),
('16:30', '15:00');

-- Viagens
INSERT INTO Viagem (horario_saida, horario_chegada, Veiculo_idVeiculo, Rota_idRota, HorarioEsperadoViagem_idHorarioEsperadoViagem) VALUES
('2025-06-01 06:05:00', '2025-06-01 07:35:00', 1, 1, 1),
('2025-06-01 07:10:00', '2025-06-01 08:40:00', 2, 3, 2),
('2025-06-01 08:00:00', '2025-06-01 09:25:00', 3, 5, 3),
('2025-06-01 09:05:00', NULL,                  4, 2, 4),
('2025-06-01 10:00:00', NULL,                  5, 4, 5),
('2025-06-01 06:00:00', '2025-06-01 07:30:00', 1, 1, 6),
('2025-06-01 07:00:00', '2025-06-01 08:35:00', 2, 3, 7),
('2025-06-01 08:05:00', NULL,                  3, 5, 8),
('2025-06-01 09:00:00', '2025-06-01 10:28:00', 4, 2, 9),
('2025-06-01 10:10:00', NULL,                  5, 4, 10);

-- Lotação
INSERT INTO Lotacao (qtd_passageiros, Viagem_idViagem) VALUES
(65, 1),(72, 2),(45, 3),(30, 4),(55, 5),
(70, 6),(68, 7),(40, 8),(58, 9),(50, 10);

-- GPS
INSERT INTO Gps_Veiculo (latitude, longitude, Veiculo_idVeiculo) VALUES
(-12.9500, -38.4200, 1),(-12.9300, -38.4100, 2),
(-12.9100, -38.3900, 3),(-12.8900, -38.3300, 4),
(-12.8700, -38.5100, 5);

-- Rota_has_Ponto_Parada
INSERT INTO Rota_has_Ponto_Parada (Rota_idRota, Ponto_Parada_idPonto_Parada, ordem, Tempo_Deslocamento_idTempo_Deslocamento) VALUES
(1,1,1,1),(1,2,2,2),(1,3,3,3),
(2,3,1,1),(2,2,2,2),(2,1,3,3),
(3,2,1,2),(3,4,2,3),(4,4,1,2),
(5,3,1,1),(5,5,2,4);
