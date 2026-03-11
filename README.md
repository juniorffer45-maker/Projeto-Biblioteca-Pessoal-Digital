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
