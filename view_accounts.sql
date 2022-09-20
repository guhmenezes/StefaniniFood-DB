--------------------------------------------------------
--  Arquivo criado - terça-feira-setembro-20-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View VW_ACCOUNTS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STFDEV"."VW_ACCOUNTS" ("CONTA", "CLIENTE", "SALDO R$", "A RECEBER R$", "ATUALIZADO AS") AS 
  SELECT DA.ACCOUNT_NUMBER AS CONTA, M.FULL_NAME AS CLIENTE, 
TO_CHAR(DA.BALANCE,'9990D00') AS "SALDO R$", 
TO_CHAR(DA.RECEIVABLE,'9990D00') AS "A RECEBER R$", 
TO_CHAR(current_timestamp, 'HH24:MM:SS TZR') AS "ATUALIZADO AS" 
FROM MOTOBOYS M 
INNER JOIN DIGITAL_ACCOUNTS DA ON M.ACCOUNT_NUMBER = DA.ACCOUNT_NUMBER
UNION
SELECT DA.ACCOUNT_NUMBER, C.COMPANY_NAME, TO_CHAR(DA.BALANCE,'9990D00'), 
TO_CHAR(DA.RECEIVABLE,'9990D00'), 
TO_CHAR(current_timestamp, 'HH24:MM:SS TZR') 
FROM COMPANIES C 
INNER JOIN DIGITAL_ACCOUNTS DA ON C.ACCOUNT_NUMBER = DA.ACCOUNT_NUMBER
;
