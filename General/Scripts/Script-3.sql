-- =========================================================
-- Sistema_Express - Distribuição de Bebidas
-- Script de criação das tabelas (PostgreSQL / compatível com DBeaver)
-- =========================================================
-- Obs: crie/selecione o banco "Sistema_Express" pela conexão do DBeaver
-- antes de rodar este script (o PostgreSQL não permite criar e usar
-- um banco na mesma sessão/transação).

-- Remove tabelas antigas (se existirem), na ordem inversa das
-- dependências, para permitir rodar o script novamente do zero.
DROP TABLE IF EXISTS Table_Comercio CASCADE;
DROP TABLE IF EXISTS Table_Valor CASCADE;
DROP TABLE IF EXISTS Table_Bebidas CASCADE;
DROP TABLE IF EXISTS Table_Clientes CASCADE;

-- ---------------------------------------------------------
-- 1. Table_Bebidas - catálogo de produtos (bebidas)
-- ---------------------------------------------------------
CREATE TABLE Table_Bebidas (
    id_bebida       SERIAL PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    categoria       VARCHAR(50)  NOT NULL,   -- Ex: Refrigerante, Cerveja, Água, Suco, Energético
    marca           VARCHAR(50),
    embalagem       VARCHAR(30),             -- Ex: Lata, Garrafa PET, Garrafa de Vidro, Fardo
    volume_ml       INT,                     -- Ex: 350, 600, 1000, 2000
    estoque_atual   INT NOT NULL DEFAULT 0,
    estoque_minimo  INT NOT NULL DEFAULT 0,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    data_cadastro   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------
-- 2. Table_Clientes - cadastro de clientes
-- ---------------------------------------------------------
CREATE TABLE Table_Clientes (
    id_cliente      SERIAL PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL,
    tipo_pessoa     VARCHAR(10) NOT NULL DEFAULT 'Fisica'
                        CHECK (tipo_pessoa IN ('Fisica', 'Juridica')),
    cpf_cnpj        VARCHAR(20) NOT NULL UNIQUE,
    telefone        VARCHAR(20),
    email           VARCHAR(100),
    endereco        VARCHAR(150),
    numero          VARCHAR(10),
    bairro          VARCHAR(80),
    cidade          VARCHAR(80),
    estado          CHAR(2),
    cep             VARCHAR(10),
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    data_cadastro   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    abastecido_mes  BOOLEAN NOT NULL DEFAULT FALSE  -- indica se o cliente já recebeu entrega no mês atual
);

-- ---------------------------------------------------------
-- 3. Table_Valor - tabela de preços das bebidas
-- ---------------------------------------------------------
CREATE TABLE Table_Valor (
    id_valor             SERIAL PRIMARY KEY,
    id_bebida            INT NOT NULL,
    preco_custo          DECIMAL(10,2) NOT NULL,
    preco_venda          DECIMAL(10,2) NOT NULL,
    data_vigencia_inicio DATE NOT NULL,
    data_vigencia_fim    DATE,
    ativo                BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_valor_bebida FOREIGN KEY (id_bebida)
        REFERENCES Table_Bebidas(id_bebida)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- 4. Table_Comercio - pedidos / vendas
-- ---------------------------------------------------------
CREATE TABLE Table_Comercio (
    id_pedido       SERIAL PRIMARY KEY,
    id_cliente      INT NOT NULL,
    id_bebida       INT NOT NULL,
    id_valor        INT NOT NULL,     -- preço aplicado no momento da venda
    quantidade      INT NOT NULL,
    valor_total     DECIMAL(10,2) NOT NULL,
    forma_pagamento VARCHAR(30),      -- Ex: Dinheiro, Pix, Cartao, Boleto
    status_entrega  VARCHAR(30) NOT NULL DEFAULT 'Pendente', -- Pendente, Em rota, Entregue, Cancelado
    data_pedido     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_entrega    TIMESTAMP,
    CONSTRAINT fk_comercio_cliente FOREIGN KEY (id_cliente)
        REFERENCES Table_Clientes(id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_comercio_bebida FOREIGN KEY (id_bebida)
        REFERENCES Table_Bebidas(id_bebida)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_comercio_valor FOREIGN KEY (id_valor)
        REFERENCES Table_Valor(id_valor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ---------------------------------------------------------
-- Alternativa: se as tabelas JÁ existem e você não quer apagar
-- os dados, rode apenas este comando para adicionar a coluna:
-- ---------------------------------------------------------
-- ALTER TABLE Table_Clientes
--     ADD COLUMN abastecido_mes BOOLEAN NOT NULL DEFAULT FALSE;

-- ---------------------------------------------------------
-- Query para atualizar "abastecido_mes" com base nas entregas
-- já registradas em Table_Comercio no mês atual. Rode isso
-- periodicamente (ex: 1x por dia) para manter a coluna em dia.
-- ---------------------------------------------------------
-- Marca como TRUE quem recebeu entrega este mês:
-- UPDATE Table_Clientes c
-- SET abastecido_mes = TRUE
-- WHERE EXISTS (
--     SELECT 1 FROM Table_Comercio p
--     WHERE p.id_cliente = c.id_cliente
--       AND p.status_entrega = 'Entregue'
--       AND date_trunc('month', p.data_entrega) = date_trunc('month', CURRENT_DATE)
-- );

-- Marca como FALSE quem NÃO recebeu entrega este mês
-- (rode isso no início de cada mês, para "zerar" o indicador):
-- UPDATE Table_Clientes
-- SET abastecido_mes = FALSE
-- WHERE id_cliente NOT IN (
--     SELECT p.id_cliente FROM Table_Comercio p
--     WHERE p.status_entrega = 'Entregue'
--       AND date_trunc('month', p.data_entrega) = date_trunc('month', CURRENT_DATE)
-- );
