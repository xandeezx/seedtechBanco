USE `agro_app`;

CREATE OR REPLACE VIEW vw_agricultores_areas AS
SELECT ag.nome AS agricultor, ag.email, ar.nome_area, ar.tamanho_hectares, ag.cidade
FROM agricultor ag
INNER JOIN area ar ON ag.id_agricultor = ar.id_agricultor;

CREATE OR REPLACE VIEW vw_catalogo_condicoes AS
SELECT s.nome_comum, s.tipo_cultura, ci.temperatura_min_c, ci.temperatura_max_c, ci.tipo_solo_preferido
FROM semente s
LEFT JOIN condicao_ideal ci ON s.id_semente = ci.id_semente;

CREATE OR REPLACE VIEW vw_sucesso_recomendacoes AS
SELECT ag.nome AS agricultor, s.nome_comum AS semente, r.data_recomendacao, r.fonte
FROM recomendacao r
JOIN agricultor ag ON r.id_agricultor = ag.id_agricultor
JOIN semente s ON r.id_semente = s.id_semente
WHERE r.status = 'aceita';

CREATE OR REPLACE VIEW vw_ranking_sementes AS
SELECT s.nome_comum, ROUND(AVG(f.avaliacao), 2) AS media_avaliacao, COUNT(f.id_feedback) AS qtd_votos
FROM feedback f
JOIN recomendacao r ON f.id_recomendacao = r.id_recomendacao
JOIN semente s ON r.id_semente = s.id_semente
GROUP BY s.nome_comum
ORDER BY media_avaliacao DESC;

CREATE OR REPLACE VIEW vw_clima_atual_areas AS
SELECT ar.nome_area, cl.temperatura_c, cl.umidade_pct, cl.data_observacao
FROM clima_leitura cl
JOIN area ar ON cl.id_area = ar.id_area
WHERE cl.data_observacao = (
    SELECT MAX(data_observacao) 
    FROM clima_leitura 
    WHERE id_area = ar.id_area
);

CREATE OR REPLACE VIEW vw_alerta_solo_acido AS
SELECT ar.nome_area, sa.ph, sa.observacoes, ag.nome AS responsavel, ag.telefone
FROM solo_amostra sa
JOIN area ar ON sa.id_area = ar.id_area
JOIN agricultor ag ON ar.id_agricultor = ag.id_agricultor
WHERE sa.ph < 6.0;

CREATE OR REPLACE VIEW vw_stats_fontes AS
SELECT r.fonte, COUNT(r.id_recomendacao) AS total_gerado
FROM recomendacao r
GROUP BY r.fonte;

CREATE OR REPLACE VIEW vw_biblioteca_videos AS
SELECT s.nome_comum, a.titulo, a.link_conteudo, a.duracao_segundos
FROM aula a
JOIN semente s ON a.id_semente = s.id_semente
WHERE a.tipo_conteudo = 'video';

CREATE OR REPLACE VIEW vw_contato_whatsapp AS
SELECT DISTINCT ag.nome, ag.telefone, ag.cidade
FROM agricultor ag
JOIN recomendacao r ON ag.id_agricultor = r.id_agricultor
WHERE ag.preferencia_comunicacao = 'whatsapp';

CREATE OR REPLACE VIEW vw_monitoramento_plantio AS
SELECT 
    ar.nome_area, 
    s.nome_comum AS cultura_plantada, 
    cl.temperatura_c AS temperatura_atual, 
    ci.temperatura_min_c, 
    ci.temperatura_max_c,
    CASE 
        WHEN cl.temperatura_c < ci.temperatura_min_c THEN 'Muito Frio'
        WHEN cl.temperatura_c > ci.temperatura_max_c THEN 'Muito Quente'
        ELSE 'Ideal'
    END AS status_temperatura
FROM clima_leitura cl
JOIN area ar ON cl.id_area = ar.id_area
JOIN recomendacao r ON ar.id_area = r.id_area
JOIN semente s ON r.id_semente = s.id_semente
JOIN condicao_ideal ci ON s.id_semente = ci.id_semente
WHERE r.status = 'plantado' 
AND cl.data_observacao >= NOW() - INTERVAL 7 DAY;