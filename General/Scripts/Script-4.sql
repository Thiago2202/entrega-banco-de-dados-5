CREATE TABLE Table_ebidas (
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