DROP SCHEMA IF EXISTS `agro_app`;
CREATE SCHEMA IF NOT EXISTS `agro_app` DEFAULT CHARACTER SET utf8mb4;
USE `agro_app`;

CREATE TABLE IF NOT EXISTS `agricultor` (
  `id_agricultor` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(150) NOT NULL,
  `cpf` VARCHAR(14) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `telefone` VARCHAR(30) NULL DEFAULT NULL,
  `endereco` VARCHAR(255) NULL DEFAULT NULL,
  `cidade` VARCHAR(100) NOT NULL,
  `estado` CHAR(2) NOT NULL DEFAULT 'PE',
  `preferencia_comunicacao` ENUM('email', 'telefone', 'whatsapp', 'none') NOT NULL DEFAULT 'email',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_agricultor`),
  UNIQUE INDEX `uq_agricultor_email` (`email` ASC),
  UNIQUE INDEX `uq_agricultor_cpf` (`cpf` ASC)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `area` (
  `id_area` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_agricultor` INT UNSIGNED NOT NULL,
  `nome_area` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(255) NULL DEFAULT NULL,
  `tamanho_hectares` DECIMAL(10,3) NOT NULL,
  `centro_lat` DECIMAL(10,7) NOT NULL,
  `centro_lon` DECIMAL(10,7) NOT NULL,
  `geometry_geojson` JSON NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_area`),
  CONSTRAINT `fk_area_agricultor`
    FOREIGN KEY (`id_agricultor`)
    REFERENCES `agricultor` (`id_agricultor`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `semente` (
  `id_semente` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome_comum` VARCHAR(150) NOT NULL,
  `nome_cientifico` VARCHAR(150) NULL DEFAULT NULL,
  `tipo_cultura` VARCHAR(80) NOT NULL,
  `variedade` VARCHAR(150) NULL DEFAULT NULL,
  `epoca_plantio` VARCHAR(100) NOT NULL,
  `descricao` TEXT NULL DEFAULT NULL,
  `imagem_url` VARCHAR(512) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_semente`),
  UNIQUE INDEX `uq_semente_nome` (`nome_comum` ASC)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `aula` (
  `id_aula` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_semente` INT UNSIGNED NULL DEFAULT NULL,
  `titulo` VARCHAR(200) NOT NULL,
  `tipo_conteudo` ENUM('video', 'texto', 'pdf', 'imagem') NOT NULL,
  `link_conteudo` VARCHAR(512) NOT NULL,
  `duracao_segundos` INT UNSIGNED NULL DEFAULT 0,
  `descricao` TEXT NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_aula`),
  CONSTRAINT `fk_aula_semente`
    FOREIGN KEY (`id_semente`)
    REFERENCES `semente` (`id_semente`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clima_leitura` (
  `id_clima` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_area` INT UNSIGNED NULL DEFAULT NULL,
  `source` VARCHAR(80) NOT NULL,
  `data_observacao` DATETIME NOT NULL,
  `temperatura_c` DECIMAL(5,2) NOT NULL,
  `umidade_pct` DECIMAL(5,2) NOT NULL,
  `chuva_mm` DECIMAL(8,3) DEFAULT 0.000,
  `velocidade_vento_mps` DECIMAL(6,3) NULL,
  `pressao_hpa` DECIMAL(7,2) NULL,
  `raw_response` JSON NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_clima`),
  INDEX `idx_data_observacao` (`data_observacao`),
  CONSTRAINT `fk_clima_area`
    FOREIGN KEY (`id_area`)
    REFERENCES `area` (`id_area`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `condicao_ideal` (
  `id_condicao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_semente` INT UNSIGNED NOT NULL,
  `temperatura_min_c` DECIMAL(5,2) NOT NULL,
  `temperatura_max_c` DECIMAL(5,2) NOT NULL,
  `umidade_min_pct` DECIMAL(5,2) NOT NULL,
  `umidade_max_pct` DECIMAL(5,2) NOT NULL,
  `ph_min` DECIMAL(4,2) NOT NULL,
  `ph_max` DECIMAL(4,2) NOT NULL,
  `tipo_solo_preferido` VARCHAR(80) NULL,
  `obs` TEXT NULL,
  PRIMARY KEY (`id_condicao`),
  CONSTRAINT `fk_condicao_semente`
    FOREIGN KEY (`id_semente`)
    REFERENCES `semente` (`id_semente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `recomendacao` (
  `id_recomendacao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_agricultor` INT UNSIGNED NOT NULL,
  `id_area` INT UNSIGNED NOT NULL,
  `id_semente` INT UNSIGNED NOT NULL,
  `data_recomendacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fonte` ENUM('interna', 'openweathermap', 'inmet', 'nasa', 'manual') NOT NULL DEFAULT 'interna',
  `confianca_pct` DECIMAL(5,2) NOT NULL,
  `status` ENUM('pendente', 'aceita', 'recusada', 'plantado', 'concluido') NOT NULL DEFAULT 'pendente',
  `justificativa` TEXT NULL,
  `detalhes_json` JSON NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_recomendacao`),
  CONSTRAINT `fk_recomendacao_agricultor`
    FOREIGN KEY (`id_agricultor`)
    REFERENCES `agricultor` (`id_agricultor`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_recomendacao_area`
    FOREIGN KEY (`id_area`)
    REFERENCES `area` (`id_area`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_recomendacao_semente`
    FOREIGN KEY (`id_semente`)
    REFERENCES `semente` (`id_semente`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `feedback` (
  `id_feedback` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_agricultor` INT UNSIGNED NOT NULL,
  `id_recomendacao` INT UNSIGNED NULL,
  `id_aula` INT UNSIGNED NULL,
  `avaliacao` TINYINT UNSIGNED NOT NULL,
  `sucesso` TINYINT(1) NOT NULL DEFAULT 0,
  `comentario` TEXT NULL,
  `data_feedback` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_feedback`),
  CONSTRAINT `fk_feedback_agricultor`
    FOREIGN KEY (`id_agricultor`)
    REFERENCES `agricultor` (`id_agricultor`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_feedback_aula`
    FOREIGN KEY (`id_aula`)
    REFERENCES `aula` (`id_aula`)
    ON DELETE SET NULL,
  CONSTRAINT `fk_feedback_recomendacao`
    FOREIGN KEY (`id_recomendacao`)
    REFERENCES `recomendacao` (`id_recomendacao`)
    ON DELETE SET NULL
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `recomendacao_historico` (
  `id_historico` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_recomendacao` INT UNSIGNED NOT NULL,
  `acao` VARCHAR(80) NOT NULL,
  `detalhes` TEXT NULL,
  `actor` VARCHAR(120) NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_historico`),
  CONSTRAINT `fk_hist_recom`
    FOREIGN KEY (`id_recomendacao`)
    REFERENCES `recomendacao` (`id_recomendacao`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `solo_amostra` (
  `id_solo` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_area` INT UNSIGNED NOT NULL,
  `data_amostragem` DATE NOT NULL,
  `profundidade_cm` DECIMAL(6,2) NULL,
  `ph` DECIMAL(4,2) NOT NULL,
  `umidade_pct` DECIMAL(5,2) NULL,
  `materia_organica_pct` DECIMAL(5,2) NULL,
  `nitrogenio_mgkg` DECIMAL(10,3) NULL,
  `fosforo_mgkg` DECIMAL(10,3) NULL,
  `potassio_mgkg` DECIMAL(10,3) NULL,
  `textura` ENUM('arenoso', 'argiloso', 'silto-arenoso', 'franco') NULL,
  `observacoes` TEXT NULL,
  `lab_report_url` VARCHAR(512) NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_solo`),
  CONSTRAINT `fk_solo_area`
    FOREIGN KEY (`id_area`)
    REFERENCES `area` (`id_area`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

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