```
/*1 – Selecionar o nome do cliente e quantidade de produtos comprados, somente para 
clientes que compraram Coca Cola.*/

SELECT 
    c.cliente, 
    itensTmp.qtde
FROM cliente c
JOIN (
    SELECT codcliente, nnf, dtvenda 
    FROM venda
) vendaTmp ON c.codcliente = vendaTmp.codcliente
JOIN (
    SELECT nnf, dtvenda, codproduto, qtde
    FROM itensvenda
) itensTmp ON (itensTmp.nnf = vendaTmp.nnf AND itensTmp.dtvenda = vendaTmp.dtvenda)
JOIN (
    SELECT codproduto, descricaoproduto
    FROM produto
) prodTmp ON itensTmp.codproduto = prodTmp.codproduto
WHERE prodTmp.descricaoproduto = 'Coca Cola'
```

```
--2 – Selecionar o nome do cliente e o valor total comprado por ele. 

SELECT 
    c.cliente,
    vendas.total
FROM cliente c
JOIN (
    SELECT
    codcliente, SUM(vlvenda) AS total
    FROM venda
    GROUP BY codcliente
) vendas on vendas.codcliente = c.codcliente
```

```
--3 – Selecionar a descrição e o maior preço de produto vendido.

SELECT
    produto.descricaoproduto,
    produto.preco
FROM venda 
JOIN (
    SELECT nnf, dtvenda, codproduto
    FROM itensvenda 
) itens ON (venda.nnf = itens.nnf AND venda.dtvenda = itens.dtvenda)
JOIN (
    SELECT codproduto, descricaoproduto, preco
    FROM produto
) produto ON itens.codproduto = produto.codproduto
WHERE produto.preco = (
    SELECT
        MAX(produto.preco)
    FROM venda 
    JOIN itensvenda itens ON (venda.nnf = itens.nnf AND venda.dtvenda = itens.dtvenda)
    JOIN produto ON itens.codproduto = produto.codproduto
)
```

```
/*5 – Selecionar o nome do cliente, nnf, data da venda, descrição do tipo de pagamento,
descrição do produto e quantidade vendida dos itens vendidos.*/

SELECT 
    c.cliente,
    v.nnf,
    v.dtvenda,
    t.descricaotppagamento,
    p.descricaoproduto,
    i.qtde
FROM CLIENTE c
JOIN venda v ON v.codcliente = c.codcliente
JOIN tipospagamento t ON t.codtppagamento = v.codtppagamento
JOIN itensvenda i ON (i.nnf = v.nnf AND i.dtvenda = v.dtvenda)
JOIN produto p ON i.codproduto = p.codproduto
```

```
--6 – Selecionar a média de preço dos produtos vendidos.

SELECT
    AVG(p.preco) AS media
FROM itensvenda i
JOIN (
    SELECT preco, codproduto
    FROM produto
) p ON p.codproduto = i.codproduto
```

```
/*7 – Selecionar o nome do cliente e a descrição dos produtos comprados por ele. Não repetir
os dados (distinct)
*/

SELECT DISTINCT
    c.cliente,
    p.descricaoproduto    
FROM cliente c
JOIN venda v ON v.codcliente = c.codcliente
JOIN itensvenda i ON (i.nnf = v.nnf AND i.dtvenda = v.dtvenda)
JOIN produto p ON p.codproduto = i.codproduto
```

```
/*8 – Selecionar a descrição do tipo de pagamento, e a maior data de venda que utilizou esse
tipo de pagamento. Ordenar a consulta pela descrição do tipo de pagamento.*/

SELECT 
    t.descricaotppagamento,
    MAX(v.dtvenda) AS maiordt
FROM tipospagamento t
JOIN venda v ON v.codtppagamento = t.codtppagamento
GROUP BY t.descricaotppagamento
ORDER BY t.descricaotppagamento
```

```
-- 9 – Selecionar a data da venda e a média da quantidade de produtos vendidos. Ordenar pela data da venda decrescente.

SELECT 
v.dtvenda, AVG(i.qtde) AS media
FROM venda v
JOIN itensvenda i ON (i.nnf = v.nnf AND i.dtvenda = v.dtvenda)
GROUP BY v.dtvenda
ORDER BY v.dtvenda DESC
```

```
/*10 – Selecionar a descrição do produto e a média de quantidades vendidas do produto.
Somente se a média for superior a 4.*/

SELECT
    p.descricaoproduto,
    AVG(i.qtde) AS m
FROM produto p
JOIN itensvenda i
    ON p.codproduto = i.codproduto
GROUP BY p.descricaoproduto
HAVING AVG(i.qtde) > 4
```