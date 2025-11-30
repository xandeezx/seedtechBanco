-- documentação do que foi pedido
USE `agro_app`;

-- 1. Relatório de Áreas por Agricultor
-- Lista o nome do agricultor, nome da área, tamanho em hectares e a cidade, usando INNER JOIN para trazer apenas quem tem área.
SELECT ag.nome AS agricultor, ar.nome_area, ar.tamanho_hectares, ag.cidade
FROM agricultor ag
INNER JOIN area ar ON ag.id_agricultor = ar.id_agricultor
ORDER BY ag.nome;

-- 2. Detalhes Completos das Sementes e suas Condições Ideais
-- Usa LEFT JOIN para listar todas as sementes, inclusive as que ainda não possuem condições ideais cadastradas.
SELECT s.nome_comum, ci.temperatura_min_c, ci.temperatura_max_c, ci.tipo_solo_preferido
FROM semente s
LEFT JOIN condicao_ideal ci ON s.id_semente = ci.id_semente;

-- 3. Histórico de Recomendações Aceitas
-- Consulta com JOIN triplo para mostrar o nome do agricultor, qual semente foi recomendada e a data, filtrando apenas as aceitas.
SELECT ag.nome, s.nome_comum AS semente_recomendada, r.data_recomendacao
FROM recomendacao r
JOIN agricultor ag ON r.id_agricultor = ag.id_agricultor
JOIN semente s ON r.id_semente = s.id_semente
WHERE r.status = 'aceita';

-- 4. Agricultores sem Áreas Cadastradas
-- Identifica agricultores que estão na base mas não têm nenhuma área vinculada (IS NULL), útil para o time comercial.
SELECT ag.nome, ag.email
FROM agricultor ag
LEFT JOIN area ar ON ag.id_agricultor = ar.id_agricultor
WHERE ar.id_area IS NULL;

-- 5. Média de Avaliação (Feedback) por Semente
-- Calcula a média das notas de feedback agrupadas por tipo de semente, ordenando pelas mais bem avaliadas.
SELECT s.nome_comum, ROUND(AVG(f.avaliacao), 2) AS media_avaliacao
FROM feedback f
JOIN recomendacao r ON f.id_recomendacao = r.id_recomendacao
JOIN semente s ON r.id_semente = s.id_semente
GROUP BY s.nome_comum
ORDER BY media_avaliacao DESC;

-- 6. Clima Recente nas Áreas de "Recife"
-- Filtra as leituras climáticas (temperatura e chuva) apenas das áreas pertencentes a agricultores da cidade de Recife.
SELECT ar.nome_area, cl.temperatura_c, cl.chuva_mm, cl.data_observacao
FROM clima_leitura cl
JOIN area ar ON cl.id_area = ar.id_area
JOIN agricultor ag ON ar.id_agricultor = ag.id_agricultor
WHERE ag.cidade = 'Recife'
ORDER BY cl.data_observacao DESC;

-- 7. Total de Hectares por Cidade
-- Realiza a soma total de hectares cultivados agrupando os resultados pela cidade dos agricultores.
SELECT ag.cidade, SUM(ar.tamanho_hectares) AS total_hectares
FROM area ar
JOIN agricultor ag ON ar.id_agricultor = ag.id_agricultor
GROUP BY ag.cidade;

-- 8. Sementes que possuem Aulas de Vídeo
-- Lista os nomes únicos das sementes que possuem material de apoio no formato de vídeo.
SELECT DISTINCT s.nome_comum
FROM semente s
JOIN aula a ON s.id_semente = a.id_semente
WHERE a.tipo_conteudo = 'video';

-- 9. Análise de Solo com pH Ácido
-- Relatório de alerta que busca amostras de solo com pH abaixo de 6.0, trazendo o nome da área e do dono.
SELECT sa.ph, sa.observacoes, ar.nome_area, ag.nome AS dono
FROM solo_amostra sa
JOIN area ar ON sa.id_area = ar.id_area
JOIN agricultor ag ON ar.id_agricultor = ag.id_agricultor
WHERE sa.ph < 6.0;

-- 10. Ranking de Fontes de Recomendação
-- Conta quantas recomendações foram geradas por cada fonte (NASA, INMET, Interna), ordenando da maior para a menor.
SELECT r.fonte, COUNT(r.id_recomendacao) AS total_recomendacoes
FROM recomendacao r
JOIN agricultor ag ON r.id_agricultor = ag.id_agricultor
GROUP BY r.fonte
ORDER BY total_recomendacoes DESC;

-- 11. Feedbacks de Sucesso com Comentários
-- Traz o nome do agricultor e seu comentário apenas para os casos onde o plantio foi marcado como sucesso.
SELECT ag.nome, f.comentario, s.nome_comum AS cultura
FROM feedback f
JOIN agricultor ag ON f.id_agricultor = ag.id_agricultor
JOIN recomendacao r ON f.id_recomendacao = r.id_recomendacao
JOIN semente s ON r.id_semente = s.id_semente
WHERE f.sucesso = 1;

-- 12. Aulas sem Vínculo com Sementes
-- Busca conteúdos educativos genéricos (que não estão ligados a uma semente específica) usando LEFT JOIN e IS NULL.
SELECT a.titulo, a.tipo_conteudo
FROM aula a
LEFT JOIN semente s ON a.id_semente = s.id_semente
WHERE s.id_semente IS NULL;

-- 13. Última Leitura Climática de cada Área
-- Usa um SUBSELECT para garantir que o retorno seja apenas o registro mais recente (MAX data) de cada área.
SELECT ar.nome_area, cl.temperatura_c, cl.data_observacao
FROM clima_leitura cl
JOIN area ar ON cl.id_area = ar.id_area
WHERE cl.data_observacao = (
    SELECT MAX(data_observacao)
    FROM clima_leitura
    WHERE id_area = ar.id_area
);

-- 14. Agricultores no WhatsApp com Recomendações
-- Filtra agricultores que preferem contato via WhatsApp e já receberam alguma recomendação no sistema.
SELECT DISTINCT ag.nome, ag.telefone
FROM agricultor ag
JOIN recomendacao r ON ag.id_agricultor = r.id_agricultor
WHERE ag.preferencia_comunicacao = 'whatsapp';

-- 15. Comparativo: Temperatura Atual vs Ideal
-- Cruza a leitura climática atual com a faixa de temperatura ideal da semente plantada naquela área.
SELECT 
    ar.nome_area, 
    s.nome_comum, 
    cl.temperatura_c AS temp_atual, 
    ci.temperatura_min_c AS temp_ideal_min, 
    ci.temperatura_max_c AS temp_ideal_max
FROM clima_leitura cl
JOIN area ar ON cl.id_area = ar.id_area
JOIN recomendacao r ON ar.id_area = r.id_area
JOIN semente s ON r.id_semente = s.id_semente
JOIN condicao_ideal ci ON s.id_semente = ci.id_semente
WHERE r.status = 'plantado' 
AND cl.data_observacao >= NOW() - INTERVAL 7 DAY;

-- 16. Quantidade de Aulas por Tipo de Conteúdo
-- Agrupa e conta quantos materiais existem de cada formato (vídeo, pdf, texto), filtrando apenas aulas válidas.
SELECT tipo_conteudo, COUNT(*) as qtd
FROM aula
WHERE id_semente IS NOT NULL
GROUP BY tipo_conteudo;

-- 17. Recomendações Pendentes com Atraso
-- Lista recomendações que estão com status 'pendente' há mais de 30 dias, calculando os dias de atraso.
SELECT ag.nome, r.data_recomendacao, DATEDIFF(NOW(), r.data_recomendacao) AS dias_atraso
FROM recomendacao r
JOIN agricultor ag ON r.id_agricultor = ag.id_agricultor
WHERE r.status = 'pendente' 
AND r.data_recomendacao < NOW() - INTERVAL 30 DAY;

-- 18. Histórico de Ações por Ator
-- Relatório de auditoria mostrando quem (actor) realizou qual ação em qual recomendação, ordenado por data.
SELECT rh.actor, rh.acao, r.id_recomendacao, rh.created_at
FROM recomendacao_historico rh
JOIN recomendacao r ON rh.id_recomendacao = r.id_recomendacao
ORDER BY rh.created_at DESC;

-- 19. Sementes para Solo Argiloso
-- Lista quais sementes têm preferência cadastrada especificamente para o tipo de solo 'argiloso'.
SELECT DISTINCT s.nome_comum
FROM semente s
JOIN condicao_ideal ci ON s.id_semente = ci.id_semente
WHERE ci.tipo_solo_preferido = 'argiloso';

-- 20. Relatório Geral 360º (Área, Solo e Recomendação)
-- Visão geral cruzando área, análise de solo e recomendações feitas, usando múltiplos LEFT JOINs.
SELECT ar.nome_area, sa.ph, s.nome_comum AS semente_recomendada
FROM area ar
LEFT JOIN solo_amostra sa ON ar.id_area = sa.id_area
LEFT JOIN recomendacao r ON ar.id_area = r.id_area
LEFT JOIN semente s ON r.id_semente = s.id_semente;