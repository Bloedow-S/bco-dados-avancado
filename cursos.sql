/*
1 – Criar uma tabela de acumproduto com a seguinte estrutura:

codproduto int not null
descricaoproduto varchar(50) not null
qtde float not null
pk – codproduto

Criar um cursor com o código do produto, descrição do produto e quantidade de produto vendido
(coluna qtde da tabela itensvenda). Inserir na tabela de acumproduto.
*/

CREATE TABLE acumproduto (
    codproduto INT PRIMARY KEY NOT NULL,
    descricaoproduto VARCHAR(50) NOT NULL,
    qtde FLOAT NOT NULL
);
    

DECLARE
    v_codproduto produto.codproduto%TYPE;
    v_descricaoproduto produto.descricaoproduto%TYPE;
    v_qtde itensvenda.qtde%TYPE;

    CURSOR  c1  is
        SELECT DISTINCT
            p.codproduto,
            p.descricaoproduto,
            SUM(i.qtde) as qtde
        FROM produto p 
        JOIN itensvenda i ON p.codproduto = i.codproduto
        GROUP BY p.codproduto, p.descricaoproduto;
BEGIN
    OPEN c1;
    LOOP 
        FETCH c1 INTO v_codproduto, v_descricaoproduto, v_qtde;
        EXIT WHEN c1%NOTFOUND;

        INSERT INTO acumproduto (
            codproduto,
            descricaoproduto,
            qtde
        )
        VALUES (
            v_codproduto,
            v_descricaoproduto,
            v_qtde
        );

    END LOOP;
    CLOSE C1;
END;

SELECT * FROM ACUMPRODUTO;

/*
2 – Criar uma tabela de produto_novo com a seguinte estrutura
descricaoproduto varchar(50) not null
preco float not null
preco_aumento float not null
pk – descricaoproduto

Criar um cursor para inserir o nome e preço do produto. Caso o preço do produto seja inferior a R$
2,00, inserir na tabela produto_novo o nome do produto, preço atual e preço com 10% de aumento. Se
o preço do produto for superior a R$ 2,00 aumentar o preço do produto para 15% na tabela de
produto
*/

CREATE TABLE produto_novo (
    descricaoproduto VARCHAR(50) PRIMARY KEY NOT NULL,
    preco FLOAT NOT NULL,
    preco_aumento FLOAT NOT NULL
);

DECLARE
    v_nome produto.descricaoproduto%TYPE; 
    v_preco produto.preco%TYPE;
    v_preco_aumento produto.preco%TYPE;
    CURSOR c is
        SELECT
            descricaoproduto, preco
        FROM produto;
BEGIN
    OPEN c;
    LOOP 
        FETCH c INTO v_nome, v_preco;
        EXIT WHEN c%NOTFOUND;

        IF v_preco < 2.00 THEN
            v_preco_aumento := v_preco + (v_preco * 0.10);
            INSERT INTO produto_novo (
                descricaoproduto,
                preco,
                preco_aumento
            )
            VALUES (
                v_nome,
                v_preco,
                v_preco_aumento
            );
        ELSIF v_preco > 2.00 THEN
            v_preco_aumento := v_preco + (v_preco * 0.15);
            UPDATE produto
            SET preco = v_preco_aumento
            WHERE descricaoproduto = v_nome;
        END IF;
    END LOOP;
    CLOSE c;
END;


/*
3 – Criar uma tabela de nova_venda com a seguinte estrutura
nnf integer not null
dtvenda date not null
vlvenda float not null
vlvenda_desconto float not null
pk - nnf, dtvenda

Criar um cursor para selecionar o número da nota fiscal (nnf) da venda, a data e valor das vendas.
Caso o valor da venda seja superior a R$ 10,00, inserir o número da nota fiscal (nnf) da venda, data,
valor da venda e valor com 10% de desconto. Se o valor da venda for inferior a R$ 10,00 inserir todos
os dados, mas com valor de desconto de 8% (inserir na tabela nova_venda).
*/

CREATE TABLE nova_venda (
    nnf INTEGER NOT NULL,
    dtvenda DATE NOT NULL,
    vlvenda FLOAT NOT NULL,
    vlvenda_desconto FLOAT NOT NULL,
    PRIMARY KEY (nnf, dtvenda)
);

DECLARE
    v_nnf               venda.nnf%TYPE;
    v_dtvenda           venda.dtvenda%TYPE;
    v_vlvenda           venda.vlvenda%TYPE;
    v_vlvenda_desconto  venda.vlvenda%TYPE;

    CURSOR c IS
        SELECT nnf, dtvenda, vlvenda
        FROM venda;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_nnf, v_dtvenda, v_vlvenda;
        EXIT WHEN c%NOTFOUND;

        IF v_vlvenda > 10.00 THEN
            v_vlvenda_desconto := v_vlvenda - (v_vlvenda * 0.10);
            
            INSERT INTO nova_venda (
                nnf,
                dtvenda,
                vlvenda,
                vlvenda_desconto
            )
            VALUES (
                v_nnf,
                v_dtvenda,
                v_vlvenda,
                v_vlvenda_desconto
            );

        ELSIF v_vlvenda <= 10.00 THEN
            v_vlvenda_desconto := v_vlvenda - (v_vlvenda * 0.08);
            
            INSERT INTO nova_venda (
                nnf,
                dtvenda,
                vlvenda,
                vlvenda_desconto
            )
            VALUES (
                v_nnf,
                v_dtvenda,
                v_vlvenda,
                v_vlvenda_desconto
            );
        END IF;

    END LOOP;
    CLOSE c;
    COMMIT;
END;
