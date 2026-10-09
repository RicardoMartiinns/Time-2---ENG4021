-- =========================================================================
-- Populando banco de dados
-- =========================================================================

-- 1. Usuários
INSERT INTO usuario (nome, email, senha, telefone, teste) VALUES 
('Loja Craque FC', 'contato@craquefc.com', '$2y$10$hashsenha1', '(11) 98765-4321', 1),
('Carlos Silva', 'carlos.silva@email.com', '$2y$10$hashsenha3', '(31) 99887-7665', 1),
('QA Tester Vendedor', 'tester.vendedor@camisa12.com', '$2y$10$hashtest1', '(11) 90000-0001', 1),
('QA Tester Cliente', 'tester.cliente@camisa12.com', '$2y$10$hashtest2', '(11) 90000-0002', 1);


-- 2. Vendedores (1, 3)
INSERT INTO vendedor (id, nome_loja, cnpj_ou_cpf, dados_bancarios, teste) VALUES 
(1, 'Craque FC Store', '12.345.678/0001-90', 'Banco 001, Ag 1234, CC 56789-0', 1),
(3, 'Loja de Teste Automatizado', '00.000.000/0001-00', 'Banco Fictício, Ag 0000, CC 00000-0', 1);


-- 3. Clientes (Vinculados aos IDs 2 e 4)
INSERT INTO cliente (id, endereco_entrega, teste) VALUES 
(2, 'Rua das Flores, 123, Apto 42 - São Paulo, SP', 1),
(4, 'Rua de Teste do Sistema, 999 - São Paulo, SP', 1);


-- 4. Inserir Categorias
INSERT INTO categoria (nome, descricao, teste) VALUES 
('Clubes Nacionais', 'Camisas de times do futebol brasileiro', 1),
('Categoria Mock / Teste', 'Categoria usada exclusivamente para testes de unidade', 1);


-- 5. Inserir Produtos
INSERT INTO produto (vendedor_id, categoria_id, nome, descricao, tipo_esporte, liga_ou_time, preco_base, teste) VALUES 
(1, 1, 'Camisa Flamengo I 2026/27', 'Camisa titular rubro-negra oficial', 'Futebol', 'Flamengo', 299.99, 1),
(3, 2, 'Produto Fictício', 'Produto gerado testes', 'Futebol', 'Time Falso', 10.00, 1);


-- 6. Inserir Carrinhos
INSERT INTO carrinho (cliente_id, teste) VALUES 
(2, 0), -- Carrinho do cliente real
(4, 1); -- Carrinho do cliente de teste


-- 7. Adicionar Produtos ao Carrinho
INSERT INTO carrinho_produto (carrinho_id, produto_id, teste) VALUES 
(1, 1, 0), -- Carrinho contendo a camisa do Flamengo
(2, 2, 1); -- Carrinho contendo o produto teste


-- 8. Registrar Pedidos
INSERT INTO pedido (cliente_id, data_pedido, status, valor_total, endereco_entrega, teste) VALUES 
(2, NOW(), 'PAGO', 299.99, 'Rua das Flores, 123, Apto 42 - São Paulo, SP', 1),
(4, NOW(), 'AGUARDANDO_PAGAMENTO', 10.00, 'Rua de Teste do Sistema, 999 - São Paulo, SP', 1);


-- 9. Registrar Pagamentos
INSERT INTO pagamento (pedido_id, valor, metodo_pagamento, status, teste) VALUES 
(1, 299.99, 'PIX', 'APROVADO', 1),
(2, 10.00, 'BOLETO', 'PENDENTE', 1);


-- 10. Inserir Avaliações
INSERT INTO avaliacao (cliente_id, produto_id, nota, comentario, teste) VALUES 
(2, 1, 5, 'Produto excelente, entrega rápida!', 1),
(4, 2, 1, 'Avaliação gerada por robô de teste', 1);