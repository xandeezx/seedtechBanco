
USE `agro_app`;

-- 1. Criação da Tabela Auxiliar de Auditoria
CREATE TABLE IF NOT EXISTS `auditoria_geral` (
  `id_log` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tabela_afetada` VARCHAR(50) NOT NULL,
  `acao` VARCHAR(20) NOT NULL,
  `chave_primaria` VARCHAR(100) NULL,
  `dados_antigos` JSON NULL,
  `dados_novos` JSON NULL,
  `usuario` VARCHAR(100) DEFAULT NULL,
  `data_hora` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_log`)
) ENGINE = InnoDB;

DELIMITER $$


-- BLOCO 1: TRIGGERS DA TABELA AGRICULTOR


-- 1. Trigger INSERT
CREATE TRIGGER `trg_agricultor_insert` AFTER INSERT ON `agricultor`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_novos, usuario)
    VALUES ('agricultor', 'INSERT', CAST(NEW.id_agricultor AS CHAR), 
            JSON_OBJECT('nome', NEW.nome, 'cpf', NEW.cpf, 'nasc', NEW.data_nascimento), CURRENT_USER());
END$$

-- 2. Trigger UPDATE
CREATE TRIGGER `trg_agricultor_update` AFTER UPDATE ON `agricultor`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_antigos, dados_novos, usuario)
    VALUES ('agricultor', 'UPDATE', CAST(OLD.id_agricultor AS CHAR), 
            JSON_OBJECT('nome', OLD.nome, 'email', OLD.email),
            JSON_OBJECT('nome', NEW.nome, 'email', NEW.email), CURRENT_USER());
END$$

-- 3. Trigger DELETE
CREATE TRIGGER `trg_agricultor_delete` BEFORE DELETE ON `agricultor`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_antigos, usuario)
    VALUES ('agricultor', 'DELETE', CAST(OLD.id_agricultor AS CHAR), 
            JSON_OBJECT('nome', OLD.nome, 'cpf', OLD.cpf), CURRENT_USER());
END$$

-- BLOCO 2: TRIGGERS DA TABELA AREA


-- 4. Trigger INSERT Area
CREATE TRIGGER `trg_area_insert` AFTER INSERT ON `area`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_novos, usuario)
    VALUES ('area', 'INSERT', CAST(NEW.id_area AS CHAR), 
            JSON_OBJECT('nome', NEW.nome_area, 'ha', NEW.tamanho_hectares, 'lat', NEW.centro_lat, 'lon', NEW.centro_lon), CURRENT_USER());
END$$

-- 5. Trigger UPDATE Area
CREATE TRIGGER `trg_area_update` AFTER UPDATE ON `area`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_antigos, dados_novos, usuario)
    VALUES ('area', 'UPDATE', CAST(OLD.id_area AS CHAR), 
            JSON_OBJECT('ha_old', OLD.tamanho_hectares),
            JSON_OBJECT('ha_new', NEW.tamanho_hectares), CURRENT_USER());
END$$

-- 6. Trigger DELETE Area
CREATE TRIGGER `trg_area_delete` BEFORE DELETE ON `area`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_antigos, usuario)
    VALUES ('area', 'DELETE', CAST(OLD.id_area AS CHAR), 
            JSON_OBJECT('nome_area', OLD.nome_area), CURRENT_USER());
END$$


-- BLOCO 3: TRIGGERS DA TABELA SEMENTE


-- 7. Trigger INSERT Semente
CREATE TRIGGER `trg_semente_insert` AFTER INSERT ON `semente`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_novos, usuario)
    VALUES ('semente', 'INSERT', CAST(NEW.id_semente AS CHAR), 
            JSON_OBJECT('nome', NEW.nome_comum), CURRENT_USER());
END$$

-- 8. Trigger UPDATE Semente
CREATE TRIGGER `trg_semente_update` AFTER UPDATE ON `semente`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_antigos, dados_novos, usuario)
    VALUES ('semente', 'UPDATE', CAST(OLD.id_semente AS CHAR), 
            JSON_OBJECT('cultura', OLD.tipo_cultura),
            JSON_OBJECT('cultura', NEW.tipo_cultura), CURRENT_USER());
END$$

-- 9. Trigger DELETE Semente
CREATE TRIGGER `trg_semente_delete` BEFORE DELETE ON `semente`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_antigos, usuario)
    VALUES ('semente', 'DELETE', CAST(OLD.id_semente AS CHAR), 
            JSON_OBJECT('nome', OLD.nome_comum), CURRENT_USER());
END$$


-- BLOCO 4: TRIGGERS DA TABELA RECOMENDACAO


-- 10. Trigger INSERT Recomendacao
CREATE TRIGGER `trg_recomendacao_insert` AFTER INSERT ON `recomendacao`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_novos, usuario)
    VALUES ('recomendacao', 'INSERT', CAST(NEW.id_recomendacao AS CHAR), 
            JSON_OBJECT('status', NEW.status, 'agric_id', NEW.id_agricultor), CURRENT_USER());
END$$

-- 11. Trigger UPDATE Recomendacao
CREATE TRIGGER `trg_recomendacao_update` AFTER UPDATE ON `recomendacao`
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_antigos, dados_novos, usuario)
        VALUES ('recomendacao', 'UPDATE_STATUS', CAST(OLD.id_recomendacao AS CHAR), 
                JSON_OBJECT('status_old', OLD.status),
                JSON_OBJECT('status_new', NEW.status), CURRENT_USER());
    END IF;
END$$

-- 12. Trigger DELETE Recomendacao
CREATE TRIGGER `trg_recomendacao_delete` BEFORE DELETE ON `recomendacao`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_geral` (tabela_afetada, acao, chave_primaria, dados_antigos, usuario)
    VALUES ('recomendacao', 'DELETE', CAST(OLD.id_recomendacao AS CHAR), 
            JSON_OBJECT('status', OLD.status), CURRENT_USER());
END$$

DELIMITER ;