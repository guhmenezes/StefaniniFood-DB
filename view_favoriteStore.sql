--------------------------------------------------------
--  Arquivo criado - terça-feira-setembro-20-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View VW_FAVORITE_STORE
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STFDEV"."VW_FAVORITE_STORE" ("LOJA FAVORITA", "CUSTOMER_ID") AS 
  SELECT STATS_MODE(CO.COMPANY_NAME) AS "LOJA FAVORITA", C.ID AS CUSTOMER_ID 
FROM CUSTOMERS C 
INNER JOIN ORDERS O ON C.ID = O.CUSTOMER_ID 
INNER JOIN MOTOBOYS M ON M.ID = O.MOTOBOY_ID 
INNER JOIN COMPANIES CO ON M.COMPANY_ID = CO.ID 
WHERE STATUS = 'FINALIZADO' 
GROUP BY C.ID
;
