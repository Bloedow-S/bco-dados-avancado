
/*1 – Selecionar o nome do produto e preço dos produtos que não foram vendidos.*/
SELECT
    p.descricaoproduto,
    p.preco
FROM produto p
WHERE p.codproduto NOT IN (
    SELECT codproduto
    FROM itensvenda
)

/*2 – Selecionar o nome do cliente que fez compra com valor maior que a média das vendas.*/
SELECT 
    c.cliente
FROM cliente c
JOIN venda v ON v.codcliente = c.codcliente
WHERE v.vlvenda > (
    SELECT AVG(vlvenda) AS media
    FROM venda
)

/*3 – Selecionar o código e a descrição do tipo de pagamento que não foi utilizado nas
vendas.*/

SELECT 
    tp.codtppagamento,
    tp.descricaotppagamento
FROM tipospagamento tp
WHERE tp.codtppagamento NOT IN (
    SELECT codtppagamento
    FROM venda
)

/*4 – Selecionar o nf, data da venda, nome do cliente e descrição do tipo de pagamento para
as vendas com valor maior que o menor valor de venda.*/

SELECT 
    v.nnf,
    v.dtvenda,
    c.cliente,
    tp.descricaotppagamento AS PAGAMENTO    
FROM cliente c
JOIN venda v ON c.codcliente = v.codcliente
JOIN tipospagamento tp ON tp.codtppagamento = v.codtppagamento
WHERE v.vlvenda > (
    SELECT MIN(vlvenda)
    FROM venda
)

/*5 – Selecionar o código e descrição do produto vendido onde a quantidade é maior que a
média das quantidades vendidas.*/

SELECT 
    p.codproduto,
    p.descricaoproduto
FROM produto p
JOIN (     
    SELECT 
        codproduto,    
        SUM(qtde) as q
    FROM itensvenda
    GROUP BY codproduto
) i ON p.codproduto = i.codproduto
WHERE i.q > (
    SELECT AVG(qtde)
    FROM itensvenda
)

/*6 – Selecionar o nome do cliente, descrição do produto para as vendas com valor maior que
o menor valor de venda.*/

SELECT DISTINCT
    c.cliente,
    p.descricaoproduto
FROM cliente c
JOIN venda v ON v.codcliente = c.codcliente
JOIN itensvenda i ON i.nnf = v.nnf AND i.dtvenda = v.dtvenda
JOIN produto p ON p.codproduto = i.codproduto
WHERE v.vlvenda > (
    SELECT MIN(vlvenda)
    FROM venda
)

/*7 – Selecionar a descrição do produto e preço para os produtos com preço maios que o
valor médio dos produtos.*/

SELECT
    p.descricaoproduto,
    p.preco
FROM produto p
WHERE p.preco > (
    SELECT AVG(preco)
    FROM produto
)

/*8 – Selecionar o nome do cliente que fez compras (venda) com a mesma forma de
pagamento do cliente João da Silva.*/

SELECT
    c.cliente
FROM cliente c
JOIN venda v ON v.codcliente = c.codcliente
JOIN tipospagamento tp ON tp.codtppagamento = v.codtppagamento
WHERE tp.codtppagamento IN (
    SELECT tp.codtppagamento
    FROM tipospagamento tp
    JOIN venda v ON v.codtppagamento = tp.codtppagamento
    JOIN cliente c ON c.codcliente = v.codcliente
    WHERE c.cliente = 'Joao da Silva'
) AND c.cliente <> 'Joao da Silva'
