# Instala o servidor PostgreSQL
!apt-get -y -qq update
!apt-get -y -qq install postgresql
!service postgresql start

# Configura o usuário e o banco de dados
!sudo -u postgres psql -c "CREATE USER aluno WITH PASSWORD 'senha123';"
!sudo -u postgres psql -c "CREATE DATABASE biblioteca;"
!sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE biblioteca TO aluno;"

# Instala as bibliotecas Python necessárias
!pip install sqlalchemy psycopg2-binary

from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, TIMESTAMP, Date, Text, Numeric, CheckConstraint
from sqlalchemy.orm import declarative_base, relationship, sessionmaker
import datetime

# Configuração da Conexão
DATABASE_URL = "postgresql://aluno:senha123@localhost:5432/biblioteca"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()
Base = declarative_base()

# --- MAPEAMENTO DAS ENTIDADES (Parte 2) ---

class Colecao(Base):
    __tablename__ = 'colecao'
    id_colecao = Column(Integer, primary_key=True)
    nome_usuario = Column(String(100), nullable=False)
    limite_leitura_simultanea = Column(Integer, default=3)
    data_criacao = Column(TIMESTAMP, default=datetime.datetime.now)

    publicacoes = relationship("Publicacao", back_populates="colecao", cascade="all, delete-orphan")

class Publicacao(Base):
    __tablename__ = 'publicacao'
    id_publicacao = Column(Integer, primary_key=True)
    id_colecao = Column(Integer, ForeignKey('colecao.id_colecao', ondelete="CASCADE"), nullable=False)
    tipo_item = Column(String(1), nullable=False) # 'L' ou 'R'
    titulo = Column(String(255), nullable=False)
    autor = Column(String(255), nullable=False)
    status_leitura = Column(String(20), default='NÃO LIDO')
    avaliacao = Column(Numeric(3,1))
    num_paginas = Column(Integer)

    colecao = relationship("Colecao", back_populates="publicacoes")
    anotacoes = relationship("Anotacao", back_populates="publicacao", cascade="all, delete-orphan")

class Anotacao(Base):
    __tablename__ = 'anotacao'
    id_anotacao = Column(Integer, primary_key=True)
    id_publicacao = Column(Integer, ForeignKey('publicacao.id_publicacao', ondelete="CASCADE"), nullable=False)
    texto = Column(Text, nullable=False)

    publicacao = relationship("Publicacao", back_populates="anotacoes")

# Cria as tabelas no banco (caso não tenha rodado o script DDL manual)
Base.metadata.create_all(engine)
print("Tabelas mapeadas e criadas com sucesso!")

# 1. CREATE (Inserção)
minha_colecao = Colecao(nome_usuario="Seu Nome")
p1 = Publicacao(titulo="O Senhor dos Anéis", autor="Tolkien", tipo_item="L", num_paginas=1200, colecao=minha_colecao)
p2 = Publicacao(titulo="National Geographic", autor="Diversos", tipo_item="R", num_paginas=50, colecao=minha_colecao)
p3 = Publicacao(titulo="Clean Code", autor="Robert Martin", tipo_item="L", num_paginas=464, colecao=minha_colecao)

session.add_all([minha_colecao, p1, p2, p3])
session.commit()

# 2. UPDATE (Atualização)
livro = session.query(Publicacao).filter_by(titulo="Clean Code").first()
livro.status_leitura = "LENDO"
session.commit()

# 3. DELETE (Remoção)
# Removendo a revista para testar
revista = session.query(Publicacao).filter_by(tipo_item="R").first()
session.delete(revista)
session.commit()

print("Operações CRUD finalizadas!")

# Consulta 1: Listar livros e o nome do dono (JOIN)
print("\n--- Listagem com Join ---")
leituras = session.query(Publicacao).join(Colecao).all()
for p in leituras:
    print(f"Usuário: {p.colecao.nome_usuario} | Obra: {p.titulo}")

# Consulta 2: Filtro por atributo da tabela relacionada e Ordenação
print("\n--- Filtro + Ordenação ---")
top_livros = session.query(Publicacao)\
    .filter(Publicacao.num_paginas > 100)\
    .order_by(Publicacao.num_paginas.desc()).all()
for p in top_livros:
    print(f"{p.titulo} - {p.num_paginas} páginas")
