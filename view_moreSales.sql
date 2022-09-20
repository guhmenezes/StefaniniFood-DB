--------------------------------------------------------
--  Arquivo criado - terça-feira-setembro-20-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View VW_TOP_SALES
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STFDEV"."VW_TOP_SALES" ("EMPRESA", "CIDADE", "UF", "PEDIDOS", "MÉDIA POR PEDIDO", "TOTAL VENDIDO R$") AS 
  SELECT C.COMPANY_NAME AS EMPRESA, L.CITY AS CIDADE, L.L_STATE AS UF, 
COUNT(O.ID) AS PEDIDOS,TO_CHAR((SUM(O.TOTAL) / COUNT(O.ID)), '999D00') AS "MÉDIA POR PEDIDO", 
TO_CHAR(SUM(O.TOTAL), '9999D00') AS "TOTAL VENDIDO R$"
FROM ORDERS O INNER JOIN MOTOBOYS M ON M.ID = O.MOTOBOY_ID 
INNER JOIN COMPANIES C ON C.ID = M.COMPANY_ID 
INNER JOIN LOCALIZATIONS L ON L.COMPANY_ID = C.ID
WHERE O.STATUS = 'FINALIZADO' AND L.COMPANY_ID = C.ID 
GROUP BY C.COMPANY_NAME, L.CITY, L.L_STATE 
ORDER BY SUM(O.TOTAL) DESC
;
