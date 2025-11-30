
USE `agro_app`;

-- Limpeza inicial para evitar erros de versão antiga
DROP FUNCTION IF EXISTS fn_status_ph_solo;
DROP FUNCTION IF EXISTS fn_dias_desde_recomendacao;
DROP FUNCTION IF EXISTS fn_formatar_cpf;
DROP FUNCTION IF EXISTS fn_media_chuva_area;
DROP FUNCTION IF EXISTS fn_contar_aulas;
DROP FUNCTION IF EXISTS fn_precisa_irrigacao;
DROP PROCEDURE IF EXISTS sp_novo_agricultor;
DROP PROCEDURE IF EXISTS sp_atualizar_recomendacao;
DROP PROCEDURE IF EXISTS sp_nova_area;
DROP PROCEDURE IF EXISTS sp_feedback_aula;
DROP PROCEDURE IF EXISTS sp_excluir_recomendacao_segura;
DROP PROCEDURE IF EXISTS sp_clonar_recomendacao;
DROP PROCEDURE IF EXISTS sp_nova_leitura_clima;
DROP PROCEDURE IF EXISTS sp_relatorio_agricultor;

DELIMITER $$


-- 1. Função: Status pH
CREATE FUNCTION fn_status_ph_solo(ph_valor DECIMAL(4,2)) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE status_solo VARCHAR(20);
    IF ph_valor < 6.0 THEN
        SET status_solo = 'Ácido (Precisa Cal)';
    ELSEIF ph_valor BETWEEN 6.0 AND 7.0 THEN
        SET status_solo = 'Neutro (Ideal)';
    ELSE
        SET status_solo = 'Alcalino';
    END IF;
    RETURN status_solo;
END$$

-- 2. Função: Dias desde recomendação
CREATE FUNCTION fn_dias_desde_recomendacao(data_rec DATETIME) 
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(NOW(), data_rec);
END$$

-- 3. Função: Formatar CPF
CREATE FUNCTION fn_formatar_cpf(cpf_raw VARCHAR(14)) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    RETURN CONCAT(SUBSTR(cpf_raw, 1, 3), '.', SUBSTR(cpf_raw, 4, 3), '.', SUBSTR(cpf_raw, 7, 3), '-', SUBSTR(cpf_raw, 10, 2));
END$$

-- 4. Função: Média de Chuva
CREATE FUNCTION fn_media_chuva_area(id_area_input INT) 
RETURNS DECIMAL(8,3)
READS SQL DATA
BEGIN
    DECLARE media DECIMAL(8,3);
    SELECT AVG(chuva_mm) INTO media FROM clima_leitura WHERE id_area = id_area_input;
    RETURN IFNULL(media, 0.0);
END$$

-- 5. Função: Contar Aulas
CREATE FUNCTION fn_contar_aulas(id_semente_input INT) 
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM aula WHERE id_semente = id_semente_input;
    RETURN total;
END$$

-- 6. Função: Precisa Irrigação
CREATE FUNCTION fn_precisa_irrigacao(id_area_input INT) 
RETURNS VARCHAR(3)
READS SQL DATA
BEGIN
    DECLARE umidade_atual DECIMAL(5,2);
    SELECT umidade_pct INTO umidade_atual 
    FROM clima_leitura 
    WHERE id_area = id_area_input 
    ORDER BY data_observacao DESC LIMIT 1;
    
    IF umidade_atual < 30.0 THEN
        RETURN 'SIM';
    ELSE
        RETURN 'NAO';
    END IF;
END$$


-- 7. Procedure: Cadastro Rápido de Agricultor (Compatível com NOT NULL)
CREATE PROCEDURE sp_novo_agricultor(
    IN p_nome VARCHAR(150),
    IN p_cpf VARCHAR(14),
    IN p_data_nascimento DATE, -- Obrigatório agora
    IN p_email VARCHAR(255),
    IN p_cidade VARCHAR(100)
)
BEGIN
    INSERT INTO agricultor (nome, cpf, data_nascimento, email, cidade, created_at)
    VALUES (p_nome, p_cpf, p_data_nascimento, p_email, p_cidade, NOW());
END$$

-- 8. Procedure: Atualizar Status da Recomendação
CREATE PROCEDURE sp_atualizar_recomendacao(
    IN p_id_recomendacao INT,
    IN p_novo_status VARCHAR(50),
    IN p_ator VARCHAR(120)
)
BEGIN
    UPDATE recomendacao 
    SET status = p_novo_status 
    WHERE id_recomendacao = p_id_recomendacao;
    
    INSERT INTO recomendacao_historico (id_recomendacao, acao, detalhes, actor, created_at)
    VALUES (p_id_recomendacao, p_novo_status, 'Status atualizado via Procedure', p_ator, NOW());
END$$

-- 9. Procedure: Inserir Nova Área (Compatível com Lat/Lon NOT NULL)
CREATE PROCEDURE sp_nova_area(
    IN p_id_agricultor INT,
    IN p_nome_area VARCHAR(120),
    IN p_hectares DECIMAL(10,3),
    IN p_lat DECIMAL(10,7), -- Obrigatório agora
    IN p_lon DECIMAL(10,7)  -- Obrigatório agora
)
BEGIN
    INSERT INTO area (id_agricultor, nome_area, tamanho_hectares, centro_lat, centro_lon, created_at)
    VALUES (p_id_agricultor, p_nome_area, p_hectares, p_lat, p_lon, NOW());
END$$

-- 10. Procedure: Registrar Feedback de Aula
CREATE PROCEDURE sp_feedback_aula(
    IN p_id_agricultor INT,
    IN p_id_aula INT,
    IN p_nota TINYINT,
    IN p_comentario TEXT
)
BEGIN
    INSERT INTO feedback (id_agricultor, id_aula, avaliacao, comentario, data_feedback)
    VALUES (p_id_agricultor, p_id_aula, p_nota, p_comentario, NOW());
END$$

-- 11. Procedure: Excluir Recomendação (Com segurança)
CREATE PROCEDURE sp_excluir_recomendacao_segura(IN p_id_rec INT)
BEGIN
    DECLARE v_status VARCHAR(50);
    SELECT status INTO v_status FROM recomendacao WHERE id_recomendacao = p_id_rec;
    
    IF v_status IN ('pendente', 'recusada') THEN
        DELETE FROM recomendacao WHERE id_recomendacao = p_id_rec;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Não pode excluir recomendações ativas.';
    END IF;
END$$

-- 12. Procedure: Clonar Recomendação
CREATE PROCEDURE sp_clonar_recomendacao(IN p_id_origem INT)
BEGIN
    INSERT INTO recomendacao (id_agricultor, id_area, id_semente, fonte, confianca_pct, status, justificativa)
    SELECT id_agricultor, id_area, id_semente, 'interna', confianca_pct, 'pendente', 'Recomendação clonada'
    FROM recomendacao
    WHERE id_recomendacao = p_id_origem;
END$$

-- 13. Procedure: Inserir Leitura Climática Simplificada
CREATE PROCEDURE sp_nova_leitura_clima(
    IN p_id_area INT,
    IN p_temp DECIMAL(5,2),
    IN p_umidade DECIMAL(5,2)
)
BEGIN
    INSERT INTO clima_leitura (id_area, source, data_observacao, temperatura_c, umidade_pct, chuva_mm)
    VALUES (p_id_area, 'manual', NOW(), p_temp, p_umidade, 0.0);
END$$

-- 14. Procedure: Relatório de Produtividade
CREATE PROCEDURE sp_relatorio_agricultor(IN p_id_agric INT)
BEGIN
    SELECT ar.nome_area, s.nome_comum, r.status, r.data_recomendacao
    FROM area ar
    JOIN recomendacao r ON ar.id_area = r.id_area
    JOIN semente s ON r.id_semente = s.id_semente
    WHERE ar.id_agricultor = p_id_agric;
END$$

DELIMITER ;