-- Script DDL para o Banco de Dados do Camisa 12


CREATE DATABASE IF NOT EXISTS camisa12_db;
USE camisa12_db;



-- 1. Tabela Usuario
CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    teste TINYINT DEFAULT 0 CHECK (teste IN (0, 1))
);

-- 2. Tabela Cliente
CREATE TABLE cliente (
    id INT PRIMARY KEY,
    endereco_entrega TEXT NOT NULL,
    teste TINYINT DEFAULT 0 CHECK (teste IN (0, 1)),
    FOREIGN KEY (id) REFERENCES usuario(id) ON DELETE CASCADE
);

-- 3. Tabela Vendedor
CREATE TABLE vendedor (
    id INT PRIMARY KEY,
    nome_loja VARCHAR(150) NOT NULL,
    cnpj_ou_cpf VARCHAR(20) UNIQUE NOT NULL,
    dados_bancarios TEXT NOT NULL,
    teste TINYINT DEFAULT 0 CHECK (teste IN (0, 1)),
    FOREIGN KEY (id) REFERENCES usuario(id) ON DELETE CASCADE
);

-- 4. Tabela Categoria
CREATE TABLE categoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    teste TINYINT DEFAULT 0 CHECK (teste IN (0, 1))
);

-- 5. Tabela Produto
CREATE TABLE produto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vendedor_id INT NOT NULL,
    categoria_id INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    tipo_esporte VARCHAR(100) NOT NULL,
    liga_ou_time VARCHAR(100) NOT NULL,
    preco_base DECIMAL(10, 2) NOT NULL,
    teste TINYINT DEFAULT 0 CHECK (teste IN (0, 1)),
    FOREIGN KEY (vendedor_id) REFERENCES vendedor(id),
    FOREIGN KEY (categoria_id) REFERENCES categoria(id)
);

-- 6. Tabela Carrinho
CREATE TABLE carrinho (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    teste TINYINT DEFAULT 0 CHECK (teste IN (0, 1)),
    FOREIGN KEY (cliente_id) REFERENCES cliente(id) ON DELETE CASCADE
);

-- 7. Tabela de Ligação: Carrinho <-> Produto
CREATE TABLE carrinho_produto (
    carrinho_id INT NOT NULL,
    produto_id INT NOT NULL,
    teste TINYINT DEFAULT 0 CHECK (teste IN (0, 1)),
    PRIMARY KEY (carrinho_id, produto_id),
    FOREIGN KEY (carrinho_id) REFERENCES carrinho(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produto(id) ON DELETE CASCADE
);

-- 8. Tabela Pedido
CREATE TABLE pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    endereco_entrega TEXT NOT NULL,
    teste TINYINT DEFAULT 0 CHECK (teste IN (0, 1)),
    FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

-- 9. Tabela Pagamento
CREATE TABLE pagamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    metodo_pagamento VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    teste TINYINT DEFAULT 0 CHECK (teste IN (0, 1)),
    FOREIGN KEY (pedido_id) REFERENCES pedido(id) ON DELETE CASCADE
);

-- 10. Tabela Avaliacao
CREATE TABLE avaliacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    produto_id INT NOT NULL,
    nota INT NOT NULL,
    comentario TEXT,
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    teste TINYINT DEFAULT 0 CHECK (teste IN (0, 1)),
    FOREIGN KEY (cliente_id) REFERENCES cliente(id),
    FOREIGN KEY (produto_id) REFERENCES produto(id) ON DELETE CASCADE
);



