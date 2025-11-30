
USE `agro_app`;
SET SQL_SAFE_UPDATES = 0;

-- 1. Testando Tabela AGRICULTOR
-- INSERT: Agora enviamos data_nascimento e cpf válidos
INSERT INTO agricultor (nome, email, cpf, data_nascimento, cidade, preferencia_comunicacao) 
VALUES ('Agricultor Trigger', 'trigger@teste.com', '999.888.777-66', '1980-01-01', 'Caruaru', 'email');

-- UPDATE
UPDATE agricultor SET nome = 'Agricultor Trigger Editado' WHERE email = 'trigger@teste.com';

-- DELETE
DELETE FROM agricultor WHERE email = 'trigger@teste.com';


-- 2. Testando Tabela AREA
-- INSERT: Agora enviamos lat e lon
-- Usamos ID 1 (do primeiro agricultor da carga inicial) para não depender do insert acima que foi deletado
INSERT INTO area (id_agricultor, nome_area, tamanho_hectares, centro_lat, centro_lon) 
VALUES (1, 'Area Trigger Teste', 100.00, -8.111, -35.111);

-- UPDATE
UPDATE area SET tamanho_hectares = 150.00 WHERE nome_area = 'Area Trigger Teste';

-- DELETE
DELETE FROM area WHERE nome_area = 'Area Trigger Teste';


-- 3. Testando Tabela SEMENTE
-- INSERT
INSERT INTO semente (nome_comum, tipo_cultura, epoca_plantio, descricao) 
VALUES ('Semente Trigger', 'Teste', 'Todo ano', 'Teste de trigger');

-- UPDATE
UPDATE semente SET tipo_cultura = 'Editado' WHERE nome_comum = 'Semente Trigger';

-- DELETE
DELETE FROM semente WHERE nome_comum = 'Semente Trigger';


-- 4. Testando Tabela RECOMENDACAO
-- INSERT
INSERT INTO recomendacao (id_agricultor, id_area, id_semente, status, justificativa, confianca_pct) 
VALUES (1, 1, 1, 'pendente', 'Trigger Rec Teste', 99.9);

-- UPDATE
UPDATE recomendacao SET status = 'recusada' WHERE justificativa = 'Trigger Rec Teste';

-- DELETE
DELETE FROM recomendacao WHERE justificativa = 'Trigger Rec Teste';


-- RELATÓRIO FINAL
SELECT * FROM auditoria_geral ORDER BY id_log DESC;

SET SQL_SAFE_UPDATES = 1;