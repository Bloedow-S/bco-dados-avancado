/*
1– Criar uma procedure Aumenta_Produto:
Esta procedure recebe como parâmetro o percentual de aumento dos produtos. Essa procedure deve
atualizar os preços dos produtos no percentual informado.
*/

CREATE OR REPLACE PROCEDURE Aumenta_Produto (
    perc IN NUMBER
)
IS
BEGIN
    UPDATE produto p
    SET p.preco = p.preco + (p.preco * (perc / 100));
END Aumenta_Produto;
/

CALL Aumenta_Produto(10);

/*
2 – Criar a função percdesconto, que recebe como parâmetro o código do cliente e deve retornar o
percentual de desconto conforme a tabela abaixo:
Qtd de Itens Comprados % Desconto
= 1 5
> 1 e <= 9 7.5
>= 10 12.5
*/

CREATE OR REPLACE FUNCTION percdesconto (
    p_codcliente IN INTEGER
)
RETURN NUMBER
IS
    var_q    INTEGER;
    var_perc NUMBER;
BEGIN
    SELECT SUM(i.qtde)
    INTO   var_q
    FROM   cliente c
    JOIN   venda v ON v.codcliente = c.codcliente
    JOIN   itensvenda i ON i.nnf = v.nnf AND i.dtvenda = v.dtvenda
    WHERE  c.codcliente = p_codcliente;

    IF var_q = 1 THEN
        var_perc := 5;
    ELSIF var_q <= 9 THEN
        var_perc := 7.5;
    ELSE
        var_perc := 12.5;
    END IF;

    RETURN var_perc;
END percdesconto;
/

SELECT percdesconto(3) FROM dual;

/*
3 – Criar uma procedure media_vendas:
Esta procedure recebe como parâmetro o código do cliente e deve retornar o valor médio das vendas
do cliente e a quantidade de vendas do cliente.
*/

CREATE OR REPLACE PROCEDURE media_vendas (
    p_codcliente IN  venda.codcliente%TYPE,
    p_media      OUT NUMBER,
    p_qtde       OUT NUMBER
)
IS
BEGIN
    SELECT AVG(vlvenda), COUNT(*)
    INTO   p_media, p_qtde
    FROM   venda
    WHERE  codcliente = p_codcliente;
END media_vendas;
/

SET SERVEROUTPUT ON;

DECLARE
    v_media NUMBER;
    v_qtde  NUMBER;
BEGIN
    media_vendas(3, v_media, v_qtde);
    DBMS_OUTPUT.PUT_LINE('Média: ' || v_media || ' | Qtde: ' || v_qtde);
END;
/

/*
4 – Criar uma procedure media_produto:
Esta procedure recebe como parâmetro duas datas, uma de início e uma de fim e deve retornar o valor
médio dos produtos vendidos no período e a soma das quantidades de produto vendido no período.
*/

CREATE OR REPLACE PROCEDURE media_produto (
    p_datainicio IN  DATE,
    p_datafim    IN  DATE,
    p_mediavalor OUT NUMBER,
    p_somaqtde   OUT NUMBER
)
IS
BEGIN
    SELECT AVG(pr.preco), SUM(i.qtde)
    INTO   p_mediavalor, p_somaqtde
    FROM   itensvenda i
    JOIN   produto pr ON pr.codproduto = i.codproduto
    WHERE  i.dtvenda >= p_datainicio
      AND  i.dtvenda <  p_datafim + 1;
END media_produto;
/

DECLARE
    v_mediavalor NUMBER;
    v_somaqtde   NUMBER;
BEGIN
    media_produto(TO_DATE('02/04/2017','DD/MM/YYYY'), TO_DATE('04/04/2017','DD/MM/YYYY'), v_mediavalor, v_somaqtde);
    DBMS_OUTPUT.PUT_LINE('Média valor: ' || v_mediavalor || ' | Soma qtde: ' || v_somaqtde);
END;
/

/*
5 – Criar uma procedure max_vltipopagto:
Esta procedure recebe como parâmetro a descrição do tipo de pagamento e retorna o maior valor
vendido para o tipo de pagamento informado no parâmetro.
*/

CREATE OR REPLACE PROCEDURE max_vltipopagto (
    p_desctppagamento IN  tipospagamento.descricaotppagamento%TYPE,
    p_maxvalor        OUT NUMBER
)
IS
BEGIN
    SELECT MAX(v.vlvenda)
    INTO   p_maxvalor
    FROM   venda v
    JOIN   tipospagamento t ON t.codtppagamento = v.codtppagamento
    WHERE  t.descricaotppagamento = p_desctppagamento;
END max_vltipopagto;
/

DECLARE
    v_maxvalor NUMBER;
BEGIN
    max_vltipopagto('Dinheiro', v_maxvalor);
    DBMS_OUTPUT.PUT_LINE('Maior valor: ' || v_maxvalor);
END;
/

/*
6 - Criar a função retorna_mediageral que retorna a média geral das vendas.
*/

CREATE OR REPLACE FUNCTION retorna_mediageral
RETURN NUMBER
IS
    var_media NUMBER;
BEGIN
    SELECT AVG(vlvenda)
    INTO   var_media
    FROM   venda;

    RETURN var_media;
END retorna_mediageral;
/

SELECT retorna_mediageral FROM dual;

/*
7 – Criar a função retorna_novo_preco, que recebe como parâmetro a descrição do produto e
mediante a quantidade vendida retorna o novo preço do produto, conforme a tabela abaixo:
Qtd vendida % Aumento
1 5
2 7
3 8
4 9
maior ou igual a 5 12
*/

CREATE OR REPLACE FUNCTION retorna_novo_preco (
    p_descricaoproduto IN produto.descricaoproduto%TYPE
)
RETURN NUMBER
IS
    var_codproduto produto.codproduto%TYPE;
    var_precoatual produto.preco%TYPE;
    var_qtde       NUMBER;
    var_perc       NUMBER;
BEGIN
    SELECT codproduto, preco
    INTO   var_codproduto, var_precoatual
    FROM   produto
    WHERE  descricaoproduto = p_descricaoproduto;

    SELECT SUM(qtde)
    INTO   var_qtde
    FROM   itensvenda
    WHERE  codproduto = var_codproduto;

    IF var_qtde = 1 THEN
        var_perc := 5;
    ELSIF var_qtde = 2 THEN
        var_perc := 7;
    ELSIF var_qtde = 3 THEN
        var_perc := 8;
    ELSIF var_qtde = 4 THEN
        var_perc := 9;
    ELSE
        var_perc := 12;
    END IF;

    RETURN var_precoatual + (var_precoatual * (var_perc / 100));
END retorna_novo_preco;
/

SELECT retorna_novo_preco('Sabonete Palmolive') FROM dual;

/*
8 – Criar a função retorna_valor_pagamento que recebe como parâmetro a descrição do tipo de
pagamento e retorna a quantidade de clientes que realizou venda com esse tipo de pagamento.
*/

CREATE OR REPLACE FUNCTION retorna_valor_pagamento (
    p_desctppagamento IN tipospagamento.descricaotppagamento%TYPE
)
RETURN NUMBER
IS
    var_qtdeclientes NUMBER;
BEGIN
    SELECT COUNT(DISTINCT v.codcliente)
    INTO   var_qtdeclientes
    FROM   venda v
    JOIN   tipospagamento t ON t.codtppagamento = v.codtppagamento
    WHERE  t.descricaotppagamento = p_desctppagamento;

    RETURN var_qtdeclientes;
END retorna_valor_pagamento;
/

SELECT retorna_valor_pagamento('Dinheiro') FROM dual;

/*
9 – Criar a função retorna_ultimavenda que recebe como parâmetro a descrição do produto e retorna a
última data que o produto foi vendido.
*/

CREATE OR REPLACE FUNCTION retorna_ultimavenda (
    p_descricaoproduto IN produto.descricaoproduto%TYPE
)
RETURN DATE
IS
    var_ultimadata DATE;
BEGIN
    SELECT MAX(i.dtvenda)
    INTO   var_ultimadata
    FROM   itensvenda i
    JOIN   produto p ON p.codproduto = i.codproduto
    WHERE  p.descricaoproduto = p_descricaoproduto;

    RETURN var_ultimadata;
END retorna_ultimavenda;
/

SELECT retorna_ultimavenda('Sabonete Palmolive') FROM dual;

/*
10 – Criar a função retorna_menorvenda que retorna o menor valor de venda realizada.
*/

CREATE OR REPLACE FUNCTION retorna_menorvenda
RETURN NUMBER
IS
    var_menor NUMBER;
BEGIN
    SELECT MIN(vlvenda)
    INTO   var_menor
    FROM   venda;

    RETURN var_menor;
END retorna_menorvenda;
/

SELECT retorna_menorvenda FROM dual;


DECLARE
    v_mediavalor NUMBER;
    v_somaqtde   NUMBER;
BEGIN
    media_produto(TO_DATE('02/04/2017','DD/MM/YYYY'), TO_DATE('04/04/2017','DD/MM/YYYY'), v_mediavalor, v_somaqtde);
    DBMS_OUTPUT.PUT_LINE('Média valor: ' || v_mediavalor || ' | Soma qtde: ' || v_somaqtde);
END;
/

CREATE OR REPLACE PROCEDURE media_produto (
    p_datainicio IN  DATE,
    p_datafim    IN  DATE,
    p_mediavalor OUT NUMBER,
    p_somaqtde   OUT NUMBER
)
IS
BEGIN
    SELECT AVG(pr.preco), SUM(i.qtde)
    INTO   p_mediavalor, p_somaqtde
    FROM   itensvenda i
    JOIN   produto pr ON pr.codproduto = i.codproduto
    WHERE  i.dtvenda BETWEEN p_datainicio AND p_datafim;
END media_produto;
/

/*
5 – Criar uma procedure max_vltipopagto:
Esta procedure recebe como parâmetro a descrição do tipo de pagamento e retorna o maior valor
vendido para o tipo de pagamento informado no parâmetro.
*/

DECLARE
    v_maxvalor NUMBER;
BEGIN
    max_vltipopagto('Dinheiro', v_maxvalor);
    DBMS_OUTPUT.PUT_LINE('Maior valor: ' || v_maxvalor);
END;
/

CREATE OR REPLACE PROCEDURE max_vltipopagto (
    p_desctppagamento IN  tipospagamento.descricaotppagamento%TYPE,
    p_maxvalor         OUT NUMBER
)
IS
BEGIN
    SELECT MAX(v.vlvenda)
    INTO   p_maxvalor
    FROM   venda v
    JOIN   tipospagamento t ON t.codtppagamento = v.codtppagamento
    WHERE  t.descricaotppagamento = p_desctppagamento;
END max_vltipopagto;
/

/*
6 - Criar a função retorna_mediageral que retorna a média geral das vendas.
*/

SELECT retorna_mediageral FROM dual;

CREATE OR REPLACE FUNCTION retorna_mediageral
RETURN NUMBER
IS
    var_media NUMBER;
BEGIN
    SELECT AVG(vlvenda)
    INTO   var_media
    FROM   venda;

    RETURN var_media;
END retorna_mediageral;
/

/*
7 – Criar a função retorna_novo_preco, que recebe como parâmetro a descrição do produto e
mediante a quantidade vendida retorna o novo preço do produto, conforme a tabela abaixo:
Qtd vendida % Aumento
1 5
2 7
3 8
4 9
maior ou igual a 5 12
*/

SELECT retorna_novo_preco('Sabonete Palmolive') FROM dual;

CREATE OR REPLACE FUNCTION retorna_novo_preco (
    p_descricaoproduto IN produto.descricaoproduto%TYPE
)
RETURN NUMBER
IS
    var_codproduto produto.codproduto%TYPE;
    var_precoatual produto.preco%TYPE;
    var_qtde       NUMBER;
    var_perc       NUMBER;
BEGIN
    SELECT codproduto, preco
    INTO   var_codproduto, var_precoatual
    FROM   produto
    WHERE  descricaoproduto = p_descricaoproduto;

    SELECT SUM(qtde)
    INTO   var_qtde
    FROM   itensvenda
    WHERE  codproduto = var_codproduto;

    IF var_qtde = 1 THEN
        var_perc := 5;
    ELSIF var_qtde = 2 THEN
        var_perc := 7;
    ELSIF var_qtde = 3 THEN
        var_perc := 8;
    ELSIF var_qtde = 4 THEN
        var_perc := 9;
    ELSE
        var_perc := 12;
    END IF;

    RETURN var_precoatual + (var_precoatual * (var_perc / 100));
END retorna_novo_preco;
/

/*
8 – Criar a função retorna_valor_pagamento que recebe como parâmetro a descrição do tipo de
pagamento e retorna a quantidade de clientes que realizou venda com esse tipo de pagamento.
*/

SELECT retorna_valor_pagamento('Dinheiro') FROM dual;

CREATE OR REPLACE FUNCTION retorna_valor_pagamento (
    p_desctppagamento IN tipospagamento.descricaotppagamento%TYPE
)
RETURN NUMBER
IS
    var_qtdeclientes NUMBER;
BEGIN
    SELECT COUNT(DISTINCT v.codcliente)
    INTO   var_qtdeclientes
    FROM   venda v
    JOIN   tipospagamento t ON t.codtppagamento = v.codtppagamento
    WHERE  t.descricaotppagamento = p_desctppagamento;

    RETURN var_qtdeclientes;
END retorna_valor_pagamento;
/

/*
9 – Criar a função retorna_ultimavenda que recebe como parâmetro a descrição do produto e retorna a
última data que o produto foi vendido.
*/

SELECT retorna_ultimavenda('Sabonete Palmolive') FROM dual;

CREATE OR REPLACE FUNCTION retorna_ultimavenda (
    p_descricaoproduto IN produto.descricaoproduto%TYPE
)
RETURN DATE
IS
    var_ultimadata DATE;
BEGIN
    SELECT MAX(i.dtvenda)
    INTO   var_ultimadata
    FROM   itensvenda i
    JOIN   produto p ON p.codproduto = i.codproduto
    WHERE  p.descricaoproduto = p_descricaoproduto;

    RETURN var_ultimadata;
END retorna_ultimavenda;
/

/*
10 – Criar a função retorna_menorvenda que retorna o menor valor de venda realizada.
*/

SELECT retorna_menorvenda FROM dual;

CREATE OR REPLACE FUNCTION retorna_menorvenda
RETURN NUMBER
IS
    var_menor NUMBER;
BEGIN
    SELECT MIN(vlvenda)
    INTO   var_menor
    FROM   venda;

    RETURN var_menor;
END retorna_menorvenda;
/