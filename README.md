# Projeto-Biblioteca-Pessoal-Digital
Projeto Biblioteca Pessoal Digital - Criação de uma Sistema de Biblioteca para gerenciamento pessoal de Livros e Revistas feito no âmbito da disciplina de Projeto de Banco de Dados


# 📚 Sistema de Gerenciamento de Coleções de Leitura

Este projeto é uma aplicação de gerenciamento de bibliotecas pessoais, permitindo que usuários organizem seus livros e revistas, controlem o status de leitura e façam anotações. A aplicação utiliza o **SQLAlchemy (ORM)** para interagir com um banco de dados **PostgreSQL**.

## 🚀 Tecnologias Utilizadas

* **Linguagem:** Python 3.x
* **Banco de Dados:** PostgreSQL
* **ORM:** SQLAlchemy
* **Ambiente:** Google Colab / Local

---

## 🛠️ Configuração do Banco de Dados

O projeto foi configurado para rodar no ambiente do Google Colab, instalando o servidor PostgreSQL diretamente na máquina virtual.

### Variáveis de Conexão:
* **Host:** `localhost`
* **Porta:** `5432`
* **Usuário:** `aluno`
* **Senha:** `senha123`
* **Banco:** `biblioteca`

---

## 📂 Estrutura do Projeto

O mapeamento ORM segue a estrutura definida no modelo relacional:

1.  **Colecao**: Representa o dono da biblioteca e seus limites de leitura.
2.  **Publicacao**: Classe base para Livros e Revistas (armazena títulos, autores e status).
3.  **Anotacao**: Notas e citações vinculadas a uma publicação específica.

### Relacionamentos Implementados:
* **Um-para-Muitos (1:N)**: Uma `Colecao` possui várias `Publicacoes`.
* **Um-para-Muitos (1:N)**: Uma `Publicacao` possui várias `Anotacoes`.
* **Delete Cascade**: Ao remover uma Coleção, todas as suas publicações e anotações são removidas automaticamente.

---

## 💻 Como Executar

1.  Abra o arquivo `.ipynb` no **Google Colab**.
2.  Execute a **primeira célula** para instalar e iniciar o serviço do PostgreSQL.
3.  Execute a célula de **Mapeamento ORM** para criar as tabelas automaticamente.
4.  Execute as células de **CRUD** para inserir, atualizar e consultar os dados.

---

## 🔍 Exemplos de Uso e Testes

### 1. Inserção (Create)
Foram inseridos registros de teste incluindo uma coleção de usuário e três publicações (Livros e Revistas).

### 2. Consultas Relacionadas (Join)
O sistema realiza buscas que cruzam dados entre tabelas:
* Listagem de títulos trazendo o nome do proprietário da coleção.
* Filtros baseados em atributos de tabelas relacionadas.

### 3. Filtros e Ordenação
Consultas que buscam livros com mais de 100 páginas, ordenados de forma decrescente por tamanho.

---

## 💾 Dados de Teste (DML)

Para validar as funcionalidades de busca, filtros e os gatilhos (triggers) de limite de leitura, utilize o script de inserção abaixo. Estes dados cobrem diferentes perfis de usuários e tipos de publicações.

```sql
-- 1. Inserindo Coleções (Usuários com diferentes limites)
INSERT INTO colecao (nome_usuario, limite_leitura_simultanea) VALUES 
('Lucas Tech', 4),
('Mariana Historiadora', 2),
('Roberto Designer', 3);

-- 2. Inserindo Publicações (Livros 'L' e Revistas 'R')
-- Associadas ao Lucas (ID 1), Mariana (ID 2) e Roberto (ID 3)
INSERT INTO publicacao (id_colecao, tipo_item, titulo, autor, ano, genero, num_paginas, status_leitura, avaliacao) VALUES 
(1, 'L', 'O Guia do Mochileiro das Galáxias', 'Douglas Adams', 1979, 'Ficção Científica', 208, 'LIDO', 10.0),
(1, 'L', 'Arquitetura Limpa', 'Robert C. Martin', 2017, 'Tecnologia', 432, 'LENDO', 9.5),
(1, 'R', 'Revista Wired', 'Condé Nast', 2024, 'Tecnologia', 90, 'NÃO LIDO', NULL),
(2, 'L', 'A República', 'Platão', 1500, 'Filosofia', 320, 'LIDO', 8.5),
(2, 'L', 'Guerra e Paz', 'Liev Tolstói', 1869, 'Romance Histórico', 1224, 'LENDO', 9.0),
(3, 'R', 'Architectural Digest', 'Condé Nast', 2023, 'Arquitetura', 150, 'LIDO', 10.0),
(3, 'L', 'Design for the Real World', 'Victor Papanek', 1971, 'Design', 384, 'NÃO LIDO', NULL);

-- 3. Inserindo Anotações vinculadas às obras
INSERT INTO anotacao (id_publicacao, texto, trecho_citado) VALUES 
(1, 'Humor britânico excelente sobre o sentido da vida.', 'A resposta é 42.'),
(2, 'Princípios fundamentais para código de qualidade.', 'O custo da bagunça é sempre maior.'),
(4, 'Leitura densa, mas necessária para entender política.', 'A justiça consiste em cada um fazer o que lhe compete.'); 

```
---

## 📝 Script SQL (DDL)

Caso deseje criar o banco manualmente fora do ORM, utilize o script abaixo:

```sql
CREATE TABLE colecao (
    id_colecao SERIAL PRIMARY KEY,
    nome_usuario VARCHAR(100) NOT NULL,
    limite_leitura_simultanea INTEGER DEFAULT 3
);

CREATE TABLE publicacao (
    id_publicacao SERIAL PRIMARY KEY,
    id_colecao INTEGER REFERENCES colecao(id_colecao) ON DELETE CASCADE,
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(255) NOT NULL,
    status_leitura VARCHAR(20) DEFAULT 'NÃO LIDO'
);


