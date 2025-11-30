
USE `agro_app`;


-- TESTANDO AS 6 FUNÇÕES


-- Teste 1: Verificar status do pH do solo
SELECT fn_status_ph_solo(5.5) AS Resultado_Teste_1;

-- Teste 2: Formatação de CPF
SELECT fn_formatar_cpf('12345678900') AS Resultado_Teste_2;

-- Teste 3: Dias desde a recomendação (usando recomendação ID 1)
SELECT fn_dias_desde_recomendacao(data_recomendacao) AS Resultado_Teste_3 
FROM recomendacao WHERE id_recomendacao = 1;

-- Teste 4: Média de Chuva da Área 1
SELECT fn_media_chuva_area(1) AS Resultado_Teste_4;

-- Teste 5: Necessidade de Irrigação da Área 1
SELECT fn_precisa_irrigacao(1) AS Resultado_Teste_5;

-- Teste 6: Contar Aulas da Semente 1
SELECT fn_contar_aulas(1) AS Resultado_Teste_6;



-- TESTANDO AS 8 PROCEDURES

-- Teste 7: Cadastro Rápido de Agricultor (Enviando os 5 dados obrigatórios)
CALL sp_novo_agricultor('Agricultor Teste Final', '11122233344', '1990-01-01', 'teste14@email.com', 'Caruaru');
-- Verificação:
SELECT * FROM agricultor WHERE email = 'teste14@email.com';

-- Teste 8: Inserir Nova Área (Enviando lat/lon obrigatórios)
-- Captura o ID do agricultor criado acima
SET @id_agric = (SELECT id_agricultor FROM agricultor WHERE email = 'teste14@email.com');
CALL sp_nova_area(@id_agric, 'Area Teste 14', 50.0, -8.123, -35.123);
-- Verificação:
SELECT * FROM area WHERE id_agricultor = @id_agric;

-- Teste 9: Atualizar Status de Recomendação (ID 1)
CALL sp_atualizar_recomendacao(1, 'concluido', 'Tester');
-- Verificação:
SELECT * FROM recomendacao WHERE id_recomendacao = 1;

-- Teste 10: Registrar Feedback de Aula
CALL sp_feedback_aula(1, 1, 5, 'Teste de feedback OK');
-- Verificação:
SELECT * FROM feedback ORDER BY id_feedback DESC LIMIT 1;

-- Teste 11: Clonar Recomendação (ID 2)
CALL sp_clonar_recomendacao(2);
-- Verificação:
SELECT * FROM recomendacao ORDER BY id_recomendacao DESC LIMIT 2;

-- Teste 12: Inserir Leitura Climática
CALL sp_nova_leitura_clima(1, 25.5, 60.0);
-- Verificação:
SELECT * FROM clima_leitura WHERE id_area = 1 ORDER BY created_at DESC LIMIT 1;

-- Teste 13: Gerar Relatório de Produtividade (Agricultor 1)
CALL sp_relatorio_agricultor(1);

-- Teste 14: Excluir Recomendação Segura
-- Criamos uma recomendação temporária para poder excluir
INSERT INTO recomendacao (id_agricultor, id_area, id_semente, fonte, confianca_pct, status, justificativa) 
VALUES (1, 1, 1, 'interna', 50.0, 'pendente', 'Para Excluir');
-- Capturamos o ID dela
SET @id_del = (SELECT id_recomendacao FROM recomendacao WHERE justificativa = 'Para Excluir' LIMIT 1);
-- Executamos a exclusão
CALL sp_excluir_recomendacao_segura(@id_del);
-- Verificação (Deve retornar vazio):
SELECT * FROM recomendacao WHERE id_recomendacao = @id_del;