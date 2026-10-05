/*
1 – Criar um objeto Obj_Curso que recebe o nome do curso por parâmetro e retorna a quantidade de
horas desse curso.
*/

CREATE OR REPLACE FUNCTION Obj_Curso( p_nome IN curso.curso%TYPE )
RETURN NUMBER
IS
    var_horas curso.duracao%TYPE;
BEGIN
    SELECT duracao
    INTO var_horas
    FROM curso c
    WHERE c.curso = p_nome;

    RETURN var_horas;
END;
/

SELECT Obj_Curso('Linux') FROM DUAL;

/*
2 – Criar um objeto Media_Idade que recebe o tipo do funcionário (Analista ou Programador) e
retorna a média de idade conforme o parâmetro enviado.
*/

CREATE OR REPLACE FUNCTION Media_Idade( p_tipo_func IN VARCHAR )
RETURN NUMBER
IS
    var_media NUMBER;
BEGIN
    IF UPPER(p_tipo_func) = 'ANALISTA' THEN
        SELECT AVG(idade) 
        INTO var_media
        FROM analista;
    ELSIF UPPER(p_tipo_func) = 'PROGRAMADOR' THEN
        SELECT AVG(idade) 
        INTO var_media
        FROM programador;
    END IF;

    RETURN ROUND(var_media, 1);
END;    
/
SELECT Media_Idade('ANALISTA') from dual;

/*
3 – Criar um objeto Soma_Horas que recebe como parâmetro um período e retorna a soma das horas
dos cursos realizados dentro do período.
*/

CREATE OR REPLACE FUNCTION Soma_Horas( p_dtinicio IN curso.dtcurso%TYPE, p_dtfim IN curso.dtcurso%TYPE)
RETURN NUMBER
IS
    var_horas NUMBER;
BEGIN
    SELECT SUM(c.duracao)
    INTO var_horas
    FROM curso c
    WHERE c.dtcurso >= p_dtinicio AND c.dtcurso <= p_dtfim;

    RETURN var_horas;
END;
/
SELECT Soma_Horas(
    TO_DATE('01/03/2020', 'DD/MM/YYYY'),
    TO_DATE('08/04/2020', 'DD/MM/YYYY')
) from dual;

/*
4 - Criar um objeto Analista_Ult_Ativ que recebe como parâmetro o nome do analista e retorna a
última data de término de atividade realizada.
*/

CREATE OR REPLACE PROCEDURE Analista_Ult_Ativ( p_nome IN analista.analista%TYPE, ultima_data OUT atividadesanalise.Dttermino%TYPE)
IS
BEGIN
    SELECT MAX(Dttermino)
    INTO ultima_data
    FROM atividadesanalise atv
    JOIN analista a ON atv.codanalista = a.codanalista
    WHERE a.analista = p_nome;
END;
/
DECLARE
    datafim atividadesanalise.Dttermino%TYPE;
BEGIN
    Analista_Ult_Ativ('Joao', datafim);
    DBMS_OUTPUT.PUT_LINE('última data: ' || datafim);
END;
/

/*
5 - Criar um objeto Programador_Ult_Ativ que recebe como parâmetro o nome do programador e
retorna a última data de término de atividade realizada.
*/

CREATE OR REPLACE PROCEDURE Programador_Ult_Ativ( p_nome IN programador.programador%TYPE, ultima_data OUT atividadesprog.dttermino%TYPE )
IS
BEGIN
    SELECT MAX(dttermino)
    INTO ultima_data
    FROM atividadesprog atv
    JOIN programador p ON p.codprogramador = atv.codprogramador
    WHERE p.programador = p_nome;
END;
/

DECLARE
    datafim atividadesprog.dttermino%TYPE;
BEGIN
    Programador_Ult_Ativ('Jeferson', datafim);
    DBMS_OUTPUT.PUT_LINE('última data: ' || datafim);
END;
/

/*
6 - Criar um objeto Dados_Analista que retorna o endereço e a idade do analista mais velho.
*/

CREATE OR REPLACE PROCEDURE Dados_Analista( p_endereco OUT analista.endereco%TYPE, p_idade OUT analista.idade%TYPE)
IS
BEGIN
    SELECT endereco, idade
    INTO p_endereco, p_idade
    FROM analista
    WHERE idade = (SELECT MAX(idade) FROM analista);
END;
/

DECLARE
    endereco analista.endereco%TYPE;
    idade analista.idade%TYPE;
BEGIN
    Dados_Analista(endereco, idade);
    DBMS_OUTPUT.PUT_LINE('ENDEREÇO: ' || endereco || ' IDADE: ' || idade);
END;
/

/*
7 - Criar uma view qtdatividades que contenha:
- o nome do programador e a quantidade de atividades realizadas por cada programador
unindo com
- o nome do analista e a quantidade de atividades realizadas por cada analista.
*/
CREATE VIEW qtdatividades AS
SELECT
    p.programador AS nome, 
    COUNT(atv.codatividadeprog) AS quantidade_atv
FROM programador p
JOIN atividadesprog atv ON atv.codprogramador = p.codprogramador
GROUP BY p.programador

UNION ALL

SELECT
    a.analista AS nome,
    COUNT(atv.codatividadeanalise) AS quantidade_atv
FROM analista a
JOIN atividadesanalise atv ON atv.codanalista = a.codanalista
GROUP BY a.analista;

SELECT * FROM qtdatividades

/*
8 – Criar uma view analistasemativ que contenha o nome do analista, idade e endereço dos analistas
que não fizeram atividade.
*/

CREATE VIEW analistasemativ AS
SELECT
    a.analista,
    a.idade,
    a.endereco
FROM analista a
WHERE a.codanalista NOT IN (
    SELECT codanalista
    FROM atividadesanalise
)

SELECT * FROM analistasemativ

/*
9 – Criar uma tabela de acumatividades com a seguinte estrutura
tipo varchar(13) not null
codatividade int not null
nome varchar(50) not null
dtinicio date not null
dttermino date not null
pk – tipo, codatividade

Criar um cursor com o
código da atividade de análise,
nome do analista, 
data de início e data de término da atividade de análise (Tipo = Análise) 

unindo com o 
código da atividade de programação,
nome do programador, 
data de início e data de término da atividade de programação (Tipo =Programação). 
Inserir na tabela de acumatividades.
*/

DECLARE CREATE TABLE acumatividades (
    tipo varchar(13) not null,
    codatividade int not null,
    nome varchar(50) not null,
    dtinicio date not null,
    dttermino date not null,
   CONSTRAINT pk_acumatividades PRIMARY KEY (tipo,codatividade)
);
    CURSOR c IS
        SELECT 
            atv.Codatividadeanalise AS cod,
            atv.Dtinicio,
            atv.Dttermino,
            a.analista AS nome,
            'Análise' AS tipo
        FROM atividadesanalise atv
        JOIN analista a ON a.codanalista = atv.codanalista

        UNION ALL

        SELECT 
            atv.Codatividadeprog AS cod,
            atv.Dtinicio,
            atv.Dttermino,
            p.programador AS nome,
            'Programação' AS tipo
        FROM atividadesprog atv
        JOIN programador p ON p.codprogramador = atv.codprogramador;

    v_relacao c%ROWTYPE;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_relacao;
        EXIT WHEN c%NOTFOUND;
    
        INSERT INTO acumatividades (
            tipo,
            codatividade,
            nome,
            dtinicio,
            dttermino
        )
        VALUES (
            v_relacao.tipo,
            v_relacao.cod,
            v_relacao.nome,
            v_relacao.dtinicio,
            v_relacao.dttermino
        );
    END LOOP;
    CLOSE c;
END;
/

/*
10 – Criar uma tabela de qtdcursos com a seguinte estrutura
codanalista int not null
analista varchar(50) not null
qtdcursos int not null
aumento float not null
pk – codanalista
Criar um cursor com o código do analista, nome do analista, quantidade de cursos feitos por ele. Para
a coluna de aumento inserir o percentual conforme tabela abaixo. Inserir na tabela de qtdcursos.
Qtd curso % Aumento
0 2.5
1 5
2 7.5
maior ou igual a 3 10
*/

DECLARE
    CURSOR c IS
        SELECT
            a.codanalista,
            a.analista,
            COUNT(ac.codcurso) AS qtd
        FROM analista a
        LEFT JOIN analistacurso ac ON ac.codanalista = a.codanalista
        GROUP BY a.codanalista, a.analista;

    v_analista c%ROWTYPE;
    v_aumento  qtdcursos.aumento%TYPE;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_analista;
        EXIT WHEN c%NOTFOUND;

        IF v_analista.qtd = 0 THEN
            v_aumento := 2.5;
        ELSIF v_analista.qtd = 1 THEN
            v_aumento := 5;
        ELSIF v_analista.qtd = 2 THEN
            v_aumento := 7.5;
        ELSE
            v_aumento := 10;
        END IF;

        INSERT INTO qtdcursos (codanalista, analista, qtdcursos, aumento)
        VALUES (v_analista.codanalista, v_analista.analista, v_analista.qtd, v_aumento);
    END LOOP;
    CLOSE c;

    COMMIT;
END;
/