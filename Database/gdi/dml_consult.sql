-- MOSTRANDO NOME DA CLINICA QUE POSSUEM MAIS DE 10 FUNCIONARIOS (COM INNER JOIN)
SELECT c.razao_social, count(*) qtd_func FROM funcionario f
INNER JOIN clinica c ON c.id = f.id_clinica
GROUP BY c.razao_social
HAVING count(*) > 10

-- MOSTRANDO ID DAS CLINICAS QUE TEM MAIS FUNCIONARIOS QUE A MÉDIA (SUBCONSULTA DO TIPO ESCALAR)
SELECT ID_CLINICA, COUNT(*) 
FROM FUNCIONARIO 
GROUP BY ID_CLINICA
HAVING COUNT(*) > (SELECT AVG(QTD)
                    FROM (SELECT ID_CLINICA, COUNT(*) AS QTD
                            FROM FUNCIONARIO GROUP BY ID_CLINICA));
                            
--MOSTRANDO NOME DAS CLINICAS QUE TEM MAIS FUNCIONARIO QUE A MÉDIA (SUBCONSULTA DO TIPO ESCALAR)
SELECT C.RAZAO_SOCIAL, COUNT(*) 
FROM FUNCIONARIO F
INNER JOIN CLINICA C 
ON (F.ID_CLINICA = C.ID)
GROUP BY C.RAZAO_SOCIAL
HAVING COUNT(*) > (SELECT AVG(QTD)
                    FROM (SELECT ID_CLINICA, COUNT(*) AS QTD
                            FROM FUNCIONARIO GROUP BY ID_CLINICA));
                            
--MOSTRANDO FUNCIONARIOS (NOME, CPF) QUE NAO RECEBEM SALARIO
SELECT NOME, CPF FROM FUNCIONARIO 
WHERE CPF NOT IN (SELECT CPF 
                        FROM PAGA_FUNCIONARIO);

--NOME DOS MÉDICOS QUE RECEBE MAIS DE 5 MIL (COM INNER JOIN)
SELECT F.NOME, M.CRM 
FROM FUNCIONARIO F 
INNER JOIN MEDICOS M 
ON (M.CPF = F.CPF)
INNER JOIN PAGA_FUNCIONARIO P
ON (P.CPF = F.CPF)
WHERE P.VALOR > 5000;
                        
--NOME DOS MÉDICOS QUE RECEBE MAIS DE 5 MIL (COM SUB-CONSULTA)
SELECT F.NOME, M.CRM 
FROM FUNCIONARIO F 
INNER JOIN MEDICOS M 
ON (M.CPF = F.CPF)
WHERE M.CPF IN (SELECT CPF 
                FROM PAGA_FUNCIONARIO
                WHERE VALOR > 5000);    

-- FUNCAO DE UMA EMPRESA QUE TEM INDUSTRIES NO NOME
SELECT funcao FROM EMPRESA_TERCEIRIZADA
WHERE razao_social LIKE ('%Industries')

-- QUANTIDADE DE MÉDICOS QUE NAO TEM SUPERVISORES
SELECT count(*) FROM medicos
WHERE cpf in (SELECT supervisor FROM medicos)

-- FUNCIONARIOS QUE TRABALHAM DE GRAÇA (USANDO LEFT JOIN)
SELECT nome FROM funcionario f
LEFT JOIN paga_funcionario p on p.cpf = f.cpf
WHERE f.id_clinica is not null and p.cpf is null

-- FUNCIONARAIOS QUE TRABALHAM DE GRAÇA (USANDO RIGHT JOIN)
SELECT nome FROM paga_funcionario p
RIGHT JOIN funcionario f on p.cpf = f.cpf
WHERE f.id_clinica is not null and p.cpf is null

-- TODOS OS FUNCIONARIOS QUE NÃO SÃO MÉDICOS (USANDO ANTI-JOIN COM NOT IN) 
SELECT nome FROM funcionario
WHERE cpf not in (SELECT cpf FROM medicos)

-- MEDICOS QUE NAO RECEBEM SALARIO (USANDO semi-JOIN E COM IN)
SELECT nome FROM funcionario
WHERE cpf in (SELECT cpf FROM medicos) and cpf not in (SELECT cpf FROM paga_funcionario)

-- NOME E SALARIO DE FUNCIONARIOS QUE TRABALHAM NA CLINICA DE ID 8 E QUE POSSUI CAPACIDADE ACIMA DE 100 PESSOAS (USANDO SUBCONSULTA E SEMI-JOIN COM IN)
SELECT nome, valor FROM paga_funcionario p, funcionario f
WHERE p.id_clinica in (SELECT id FROM clinica
                    WHERE id = 8 and capacidade > 100) and
                    p.cpf in (SELECT cpf FROM funcionario)
                    and valor is not null

-- QUANTOS MÉDICOS RECEBEM SALARIO
SELECT count(*) as medicosAssalariados FROM medicos
WHERE cpf in (SELECT cpf FROM paga_funcionario)

--RAZÃO SOCIAL DAS CLINICAS DOS ESTADOS QUE TEM MAIS DE 2 CLINICAS(SUB-COSULTA TIPO TABELA)

SELECT RAZAO_SOCIAL,ESTADO FROM CLINICA
WHERE ESTADO in(SELECT ESTADO FROM CLINICA
GROUP BY ESTADO
having COUNT(ESTADO) > 2)
order by ESTADO

-- NOME DE TODOS OS SUPERVISORES E QUANTIDADE DE MEDICOS QUE SUPERVISIONAM MAIS DE 3 MÉDICOS (USANDO GROUP BY E INNER JOIN)

SELECT NOME, count(SUPERVISOR) as qtd FROM FUNCIONARIO 
INNER JOIN MEDICOS on FUNCIONARIO.CPF = MEDICOS.SUPERVISOR
group by nome, Supervisor
HAVING COUNT(SUPERVISOR) > 3
order by QTD DESC

-- NOME DE TODOS OS PACIENTES QUE NÃO SÃO FUNCIONARIOS (ANTI-JOIN COM NOT EXISTS)
SELECT nome FROM paciente p
WHERE NOT EXISTS (SELECT f.cpf FROM funcionario f
                WHERE p.cpf = f.cpf)

-- NOME E CPF DE MÉDICOS QUE POSSUEM MAIS DE UMA CONSULTA (INNER-JOIN, GROUP BY E HAVING)
SELECT F.NOME, A.CPF_MEDICO, COUNT(*) AS QTD 
FROM AGENDAMENTO A
INNER JOIN FUNCIONARIO F ON (F.CPF = A.CPF_MEDICO)
GROUP BY F.NOME, A.CPF_MEDICO
HAVING COUNT(*) > 1;

--NOME E CPF DE MÉDICOS QUE POSSUEM MAIS DE UMA CONSULTA (INNER-JOIN, INNER-JOIN, GROUP BY E HAVING)
select f.nome, m.cpf, count(*) from medicos m
inner join funcionario f on f.cpf = m.cpf 
inner join agendamento on m.cpf = cpf_medico
group by f.nome, m.cpf
having count(*)>1

--TODOS OS FUNCIONARIOS E SEUS BENEFICIOS, CASO RECEBAM (FULL OUTER JOIN)
SELECT B.COD, F.CPF, F.NOME
FROM BENEFICIO B
FULL OUTER JOIN FUNCIONARIO F ON (B.CPF = F.CPF);

--CPF DOS MÉDICOS QUE PARTICIPAM DE UM AGENDAMENTO 
SELECT cpf
FROM Funcionario
UNION
SELECT cpf_medico
FROM agendamento

--FUNCIONARIOS QUE SÃO PAGOS E NÃO RECEBEM BENEFÍCIOS
SELECT count(cpf) FROM paga_funcionario p
WHERE NOT EXISTS (SELECT cpf FROM beneficio b
                WHERE p.cpf = b.cpf);

--FUNCIONARIOS QUE SÃO PAGOS E NÃO RECEBEM BENEFÍCIOS
SELECT count(p.cpf) FROM paga_funcionario p
LEFT JOIN beneficio b on b.cpf = p.cpf
WHERE b.cpf is null;


--NOME E CONTATO DAS EMPRESAS QUE OFERECEM O MESMO SERVIÇO QUE A VIVAMUS INSTITUTE ORDENADO ALFABETICAMENTE (SUBCONSULTA TIPO LINHA)
SELECT E.RAZAO_SOCIAL, E.CONTATO
FROM EMPRESA_TERCEIRIZADA E
WHERE FUNCAO = (SELECT FUNCAO
                FROM EMPRESA_TERCEIRIZADA
                WHERE RAZAO_SOCIAL = 'Vivamus Institute')
ORDER BY E.RAZAO_SOCIAL ASC;

--CRM DE FUNCIONARIOS COM EMAIL DA UFPE (SUBCONSULTA TIPO TABELA)
select m.crm from funcionario f
inner join medicos m on m.cpf = f.cpf
where f.cpf in (select cpf from email_funcionario
            where email like '%@ufpe.br')

--FUNCIONARIOS QUE TRABALHAM COM A CLINICA DE ID 8 (INNER JOIN)
select f.nome, r.cpf from recepcionista r
inner join funcionario f on f.cpf = r.cpf 
where descricao = 'alergia'

--EMPRESA TERCEIRIZADA QUE ESTAO TENDO SERVICOS SENDO REALIZADOS (SEMI-JOIN, SUBCONSULTA TIPO TABELA)
select cnpj, razao_social
from empresa_terceirizada
where exists(select 1
from servico
where servico.cnpj = empresa_terceirizada.cnpj);

-- CLINICAS QUE NAO ESTAO TENDO SERVICOS SENDO REALIZADOS (ANTI-JOIN, SUBCONSULTA TIPO TABELA)
select ID, razao_social
from clinica
where not exists(select 1
from servico
where servico.id_clinica = clinica.ID);


--CONTRATOS COM VALOR MAIOR QUE 5 MIL (SEMI-JOIN, SUBCONSULTA TIPO TABELA)
select cod, valor
from contrato
where exists(select 1
from servico
where contrato.cod = servico.cod and valor > 5000)

--PACIENTES QUE MORAM NA MESMA CIDADE QUE A CLINICA (OPERACAO DE CONJUNTO, INTERSECT)
select cidade
from paciente
intersect
select cidade
from CLINICA