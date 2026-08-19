
/*1 – Criar uma view funcionario que contenha o nome dos funcionários, endereço e idade. Incluir
nessa view uma coluna informando o tipo de funcionário Analista ou Programador. Formatar o nome
e endereço do funcionário para maiúsculo.*/
CREATE OR REPLACE VIEW funcionario AS
SELECT 
    CASE
        WHEN a.codanalista IS NOT NULL THEN 'Analista'
    END as tpfuncionario,
    UPPER(a.analista) AS nome,
    a.idade,
    UPPER(a.endereco) AS endereço
FROM analista a
UNION 
SELECT
    'Programador' AS tpfuncionario,
    UPPER(p.programador) AS nome,
    p.idade,
    UPPER(p.endereco) AS endereço
FROM programador p

SELECT * FROM funcionario

/*2 – Criar uma view analistasemcurso que contenha o nome dos analistas que não fizeram curso.*/

CREATE OR REPLACE VIEW vw_analistasemcurso AS
SELECT 
    analista
FROM analista
WHERE codanalista NOT IN (
    SELECT codanalista
    FROM analistacurso
)

SELECT * FROM vw_analistasemcurso

/*
3 – Criar uma view ativanalise2sem que contenha o código e o nome dos analistas que terminaram ou
começaram atividade após o dia 03/02/2020.
*/

CREATE OR REPLACE VIEW vw_ativanalise2sem AS
SELECT DISTINCT
    a.codanalista,
    a.analista
FROM analista a
JOIN atividadesanalise at ON a.codanalista = at.codanalista
WHERE at.dtinicio > TO_DATE('03/02/2020', 'DD/MM/YYYY') OR at.dttermino > TO_DATE('03/02/2020', 'DD/MM/YYYY');

SELECT * FROM vw_ativanalise2sem

/*
4 - Criar uma view ativprogramador1sem que contenha o código e o nome dos programadores que
começaram atividade após o dia 05/02/2020 e antes de 15/07/2020.
*/

CREATE OR REPLACE VIEW vw_ativprogramador1sem AS
SELECT 
    p.codprogramador,
    p.programador
FROM programador p
JOIN atividadesprog at ON p.codprogramador = at.codprogramador
WHERE at.dtinicio > TO_DATE('05/02/2020', 'DD/MM/YYYY') AND at.dtinicio < TO_DATE('15/07/2020', 'DD/MM/YYYY');

SELECT * FROM vw_ativprogramador1sem

/*
5 - Criar uma view cursonaoreal que contenha o código, o nome e duração dos cursos não realizados
pelos analistas.
*/

CREATE OR REPLACE VIEW vw_cursonaoreal AS
SELECT
    codcurso,
    curso,
    duracao
FROM curso
WHERE codcurso NOT IN (
    SELECT codcurso
    FROM analistacurso
)

SELECT * FROM vw_cursonaoreal

/*
6 - Criar uma view analistasemcurso que contenha o código, nome e idade dos analistas que não
realizaram cursos.
*/

CREATE OR REPLACE VIEW vw_analistasemcurso AS
SELECT
    codanalista,
    analista,
    idade
FROM analista
WHERE codanalista NOT IN (
    SELECT codanalista
    FROM analistacurso
)
ORDER BY codanalista

SELECT * FROM vw_analistasemcurso

/*
7 - Criar uma view qtdativprogramador que contenha o nome do programador e a quantidade de
atividades realizadas por cada programador.
*/

CREATE OR REPLACE VIEW vw_qtdativprogramador AS
SELECT
    p.programador,
    at.q AS total_atividades
FROM programador p
JOIN(
    SELECT COUNT(codatividadeprog) as q, codprogramador
    FROM atividadesprog
    GROUP BY codprogramador
) at ON p.codprogramador = at.codprogramador

SELECT * FROM vw_qtdativprogramador
