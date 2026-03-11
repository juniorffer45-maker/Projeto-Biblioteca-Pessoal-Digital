DROP TABLE IF EXISTS anotacao CASCADE;
DROP TABLE IF EXISTS publicacao CASCADE;
DROP TABLE IF EXISTS colecao CASCADE;

-- 1. TABELA COLECAO
CREATE TABLE colecao (
    id_colecao SERIAL PRIMARY KEY,
    nome_usuario VARCHAR(100) NOT NULL,
    limite_leitura_simultanea INTEGER DEFAULT 3,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABELA PUBLICACAO
CREATE TABLE publicacao (
    id_publicacao SERIAL PRIMARY KEY,
    id_colecao INTEGER NOT NULL, 
    tipo_item CHAR(1) NOT NULL CHECK (tipo_item IN ('L', 'R')), 
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(255) NOT NULL,
    ano INTEGER NOT NULL CHECK (ano >= 1500),
    genero VARCHAR(100),
    num_paginas INTEGER,
    status_leitura VARCHAR(20) DEFAULT 'NÃO LIDO' CHECK (status_leitura IN ('NÃO LIDO', 'LENDO', 'LIDO')),
    avaliacao DECIMAL(3,1) CHECK (avaliacao >= 0 AND avaliacao <= 10),
    data_inclusao DATE DEFAULT CURRENT_DATE,
    data_inicio DATE,
    data_termino DATE,
    
    -- Sub Classes Livro e Revista
    id_livro VARCHAR(20),
    editora VARCHAR(100),
    edicao INTEGER,
    
    id_revista VARCHAR(20),
    volume INTEGER,
    mes_publicacao VARCHAR(20),

    -- Foreign Key referenciando Coleção 
    -- Garante que id_colecao aponte para colecao.id_colecao (PK)
    CONSTRAINT fk_colecao_item 
        FOREIGN KEY (id_colecao) 
        REFERENCES colecao(id_colecao) 
        ON DELETE CASCADE,

    CONSTRAINT uc_titulo_autor_colecao UNIQUE (id_colecao, titulo, autor)
);

-- 3. TABELA ANOTACAO
CREATE TABLE anotacao (
    id_anotacao SERIAL PRIMARY KEY,
    id_publicacao INTEGER NOT NULL,
    texto TEXT NOT NULL,
    trecho_citado TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key referenciando Publicação 	
    -- FK Garante que id_publicacao aponte para publicacao.id_publicacao (PK)
    CONSTRAINT fk_publicacao_nota 
        FOREIGN KEY (id_publicacao) 
        REFERENCES publicacao(id_publicacao) 
        ON DELETE CASCADE
);


-- ETAPA 3 - PROJETO FINAL


-- Carga de dados (INSERTs)

-- 1. Populando a tabela COLECAO
-- Criamos 3 usuários para gerenciar suas bibliotecas pessoais.
INSERT INTO colecao (nome_usuario, limite_leitura_simultanea) VALUES
('Jose', 4),
('Maria', 4),
('Lazaro', 3);

-- 2. Populando a tabela PUBLICACAO
-- Inserindo Livros (tipo 'L') e Revistas (tipo 'R') para diferentes coleções.
INSERT INTO publicacao (id_colecao, tipo_item, titulo, autor, ano, genero, num_paginas, status_leitura, avaliacao, id_livro, editora) VALUES
(1, 'L', 'Senhor dos Aneis', 'J.R.R. Tolkien', 1899, 'Fantasia', 256, 'LIDO', 9.5, 'livro-001', 'Editora A'),
(1, 'L', 'O Hobbit', 'J.R.R. Tolkien', 1937, 'Fantasia', 310, 'LENDO', 10.0, 'livro-002', 'Editora B'),
(2, 'L', 'Clean Code', 'Robert C. Martin', 2008, 'Tecnologia', 464, 'NAO LIDO', NULL, 'livro-003', 'Editora C');

INSERT INTO publicacao (id_colecao, tipo_item, titulo, autor, ano, genero, status_leitura, id_revista, volume, mes_publicacao) VALUES 
(1, 'R', 'National Geographic', 'Vários', 2023, 'Ciência', 'LIDO', 'rev-01', 50, 'Outubro'),
(2, 'R', 'Scientific American', 'Vários', 2024, 'Ciência', 'LENDO', 'rev-02', 12, 'Janeiro');

-- 3. Populando a tabela ANOTACAO
-- Criando reflexões sobre as publicações existentes.
INSERT INTO anotacao (id_publicacao, texto, trecho_citado) VALUES 
(1, 'Anotacao - Livro 001', 'Gandalf enfrenta Orcs'),
(1, 'Anotacao - Livro 001', 'Frodo esconde o anel'),
(2, 'Anotacao - Livro 002', 'Numa toca no chão vivia um hobbit.'),
(4, 'Anotacao - Revista 02', 'As águas do oceano estão aquecendo.');

-- Consultas (SELECT)

-- Consulta 1: Listar todas as publicações e o nome do seu respectivo dono (JOIN + WHERE)
-- Objetivo: Identificar quem é o proprietário de cada livro/revista na base de dados.
SELECT 
    c.nome_usuario AS "Proprietario",
    p.titulo AS "Titulo da Obra",
    p.tipo_item AS "Tipo"
FROM publicacao AS p
INNER JOIN colecao AS c ON p.id_colecao = c.id_colecao
WHERE p.tipo_item = 'L';


-- Consulta 2: Listar todas as anotações feitas, exibindo o título do livro correspondente (JOIN)
-- Objetivo: Relacionar os pensamentos anotados com o título da obra original.
SELECT 
    p.titulo AS "Obra",
    a.texto AS "Minha Anotação",
    a.trecho_citado AS "Trecho do Livro"
FROM anotacao AS a
INNER JOIN publicacao AS p ON a.id_publicacao = p.id_publicacao;


-- Consulta 3: Relatório completo de usuários e quantidade de itens na coleção (LEFT JOIN + WHERE)
-- Objetivo: Mostrar todos os usuários, mesmo aqueles que ainda não cadastraram nenhuma publicação.
SELECT 
    c.nome_usuario AS "Usuário",
    p.titulo AS "Item na Coleção",
    p.status_leitura AS "Status"
FROM colecao AS c
LEFT JOIN publicacao AS p ON c.id_colecao = p.id_colecao
ORDER BY c.nome_usuario;


-- Consulta 4: Detalhamento de Anotações por Usuário (Múltiplos JOINs)
-- Objetivo: Demonstrar a relação tripla entre o usuário, a obra e as notas feitas.
SELECT 
    c.nome_usuario AS "Leitor",
    p.titulo AS "Obra Comentada",
    a.texto AS "Comentario"
FROM colecao AS c
INNER JOIN publicacao AS p ON c.id_colecao = p.id_colecao
INNER JOIN anotacao AS a ON p.id_publicacao = a.id_publicacao;


-- Consulta 5: Busca de publicações bem avaliadas e suas editoras (JOIN + WHERE)
-- Objetivo: Filtrar obras de alta qualidade e identificar de onde vieram.
SELECT 
    p.titulo AS "Destaque",
    p.avaliacao AS "Nota",
    p.editora AS "Publicado por"
FROM publicacao AS p
JOIN colecao AS c ON p.id_colecao = c.id_colecao

WHERE p.avaliacao >= 9.0;

-- ETAPA 5 - PROJETO FINAL

-- ===============================
-- VIEW
-- ===============================

-- Facilita a consulta diária, unindo os dados da coleção com os da publicaçao, filtrando apenas o que é relevante para o usuário

CREATE VIEW v_resumo_leituras AS
SELECT 
    c.nome_usuario,
    p.titulo,
    p.autor,
    p.tipo_item,
    p.status_leitura,
    p.avaliacao
FROM colecao c
JOIN publicacao p ON c.id_colecao = p.id_colecao
ORDER BY c.nome_usuario, p.status_leitura;

-- ===============================
-- VIEW MATERIALIZADA
-- ===============================

-- Calcula a média de páginas lidas e o total de itens por usuário

CREATE MATERIALIZED VIEW mv_estatisticas_colecao AS
SELECT 
    c.nome_usuario,
    COUNT(p.id_publicacao) AS total_itens,
    ROUND(AVG(p.avaliacao), 2) AS media_notas,
    SUM(CASE WHEN p.status_leitura = 'LIDO' THEN p.num_paginas ELSE 0 END) AS total_paginas_lidas
FROM colecao c
LEFT JOIN publicacao p ON c.id_colecao = p.id_colecao
GROUP BY c.nome_usuario;

-- Para atualizar os dados: REFRESH MATERIALIZED VIEW mv_estatisticas_colecao;

-- ===============================
-- TRIGGERS
-- ===============================

-- Trigger BEFORE

-- Este Trigger impede que o usuário adicione uma nova leitura como "LENDO" se ele já tiver atingido o limite_leitura_simultanea definido na tabela Colecao

CREATE FUNCTION fn_checar_limite_leitura()
RETURNS TRIGGER AS $$
DECLARE
    v_limite INTEGER;
    v_atual INTEGER;
BEGIN
    -- Busca o limite da coleção
    SELECT limite_leitura_simultanea INTO v_limite FROM colecao WHERE id_colecao = NEW.id_colecao;
    
    -- Conta quantos itens já estão com status 'LENDO'
    SELECT COUNT(*) INTO v_atual FROM publicacao 
    WHERE id_colecao = NEW.id_colecao AND status_leitura = 'LENDO';

    IF (NEW.status_leitura = 'LENDO' AND v_atual >= v_limite) THEN
        RAISE EXCEPTION 'Limite de leitura simultânea atingido para esta coleção (%)!', v_limite;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_limite_leitura
BEFORE INSERT OR UPDATE OF status_leitura ON publicacao
FOR EACH ROW EXECUTE FUNCTION fn_checar_limite_leitura();

-- Trigger AFTER

-- Sempre que uma anotação é criada, o sistema imprimi uma confirmação no console

CREATE OR REPLACE FUNCTION fn_log_anotacao()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Nova anotação registrada para a publicação ID % em %', NEW.id_publicacao, NOW();
    RETURN AFTER;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_depois_anotacao
AFTER INSERT ON anotacao
FOR EACH ROW EXECUTE FUNCTION fn_log_anotacao();


-- ===============================
-- PROCEDURE
-- ===============================

-- Automatiza o encerramento de uma leitura, atualizando o status, a data de término e a nota de uma só vez

CREATE OR REPLACE PROCEDURE pr_finalizar_leitura(
    p_id_publicacao INTEGER,
    p_nota DECIMAL)
    
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE publicacao
    SET status_leitura = 'LIDO',
        data_termino = CURRENT_DATE,
        avaliacao = p_nota
    WHERE id_publicacao = p_id_publicacao;

    COMMIT;
    RAISE NOTICE 'Publicação % finalizada com sucesso com nota %!', p_id_publicacao, p_nota;
END;
$$;

-- Exemplo de uso:
-- CALL pr_finalizar_leitura(1, 9.5);
