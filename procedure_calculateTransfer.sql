--------------------------------------------------------
--  Arquivo criado - terça-feira-setembro-20-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_CALCULATE_TRANSFER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "STFDEV"."SP_CALCULATE_TRANSFER" 
(p_month in INTEGER, p_year in INTEGER, p_monthly_fee in float, p_percent_fee in float)
IS
    v_date DATE := '01/'||p_month||'/'||p_year;
    v_transfer FLOAT;
    v_account COMPANIES.ACCOUNT_NUMBER%TYPE;
    v_releaseDate DATE := ADD_MONTHS(v_date + 4, 1);
    v_hasRecord CHAR := 0;

    CURSOR cur_sales IS SELECT C.ID,
    TO_CHAR(SUM(O.TOTAL), '9999D00') AS TOTAL 
    FROM ORDERS O INNER JOIN MOTOBOYS M ON M.ID = O.MOTOBOY_ID 
    INNER JOIN COMPANIES C ON C.ID = M.COMPANY_ID 
    WHERE O.STATUS <> 'AGUARDANDO' AND O.ORDERED_AT >= v_date
    AND O.ORDERED_AT < ADD_MONTHS(v_date, 1) 
    GROUP BY C.ID;

    CURSOR cur_deliveries IS SELECT M.ID, 
    M.ROUTE_VALUE, COUNT(*) AS DELIVERIES 
    FROM ORDERS O INNER JOIN MOTOBOYS M ON M.ID = O.MOTOBOY_ID  
    WHERE O.STATUS = 'FINALIZADO' AND O.ORDERED_AT >= v_date
    AND O.ORDERED_AT < ADD_MONTHS(v_date, 1) 
    GROUP BY M.ID, ROUTE_VALUE;
BEGIN

    IF TO_CHAR(v_releaseDate, 'D') = 1 THEN
    v_releaseDate := v_releaseDate - 2;
    ELSIF TO_CHAR(v_releaseDate, 'D') = 7 THEN
    v_releaseDate := v_releaseDate - 1;
    END IF;

    dbms_output.put_line('Atualizando valores a receber...');

    FOR company IN cur_sales LOOP

        IF company.total < 200 THEN
            v_transfer := company.total - ( company.total * p_percent_fee / 100);
        ELSE
            v_transfer := company.total - ( company.total * p_percent_fee / 100 + p_monthly_fee);
        END IF;

        SELECT C.ACCOUNT_NUMBER INTO v_account FROM COMPANIES C INNER JOIN DIGITAL_ACCOUNTS DA ON DA.ACCOUNT_NUMBER = C.ACCOUNT_NUMBER WHERE C.ID = company.id;   
        SELECT COUNT(*) INTO v_hasRecord FROM BANK_STATEMENTS WHERE EXTRACT(MONTH FROM RELEASE_DATE) = p_month+1 AND ACCOUNT_NUMBER = v_account;

        IF v_hasRecord = 1 THEN
            UPDATE BANK_STATEMENTS SET AMOUNT = v_transfer WHERE ACCOUNT_NUMBER = v_account AND EXTRACT(MONTH FROM RELEASE_DATE) = p_month+1 ;
            COMMIT;
        ELSIF v_hasRecord = 0 THEN
            INSERT INTO BANK_STATEMENTS VALUES (NULL, v_account, v_releaseDate, v_transfer, 'C', 'TRANSFERÊNCIA RECEBIDA - STEFANINIFOOD '||p_month||'/'||substr(p_year, length(p_year)-1));
            COMMIT;
        END IF;

        SP_UPDATE_BALANCE(v_account);

    END LOOP;

        dbms_output.put_line('Atualizando saldos...');

        FOR motoboy IN cur_deliveries LOOP

        v_transfer := motoboy.route_value * motoboy.deliveries;

        SELECT M.ACCOUNT_NUMBER INTO v_account FROM MOTOBOYS M INNER JOIN DIGITAL_ACCOUNTS DA ON DA.ACCOUNT_NUMBER = M.ACCOUNT_NUMBER WHERE M.ID = motoboy.id;   
        SELECT COUNT(*) INTO v_hasRecord FROM BANK_STATEMENTS WHERE EXTRACT(MONTH FROM RELEASE_DATE) = p_month+1 AND ACCOUNT_NUMBER = v_account;

        IF v_hasRecord = 1 THEN
            UPDATE BANK_STATEMENTS SET AMOUNT = v_transfer WHERE ACCOUNT_NUMBER = v_account AND EXTRACT(MONTH FROM RELEASE_DATE) = p_month+1 ;
            COMMIT;
        ELSIF v_hasRecord = 0 or v_hasRecord IS NULL THEN
            INSERT INTO BANK_STATEMENTS VALUES (NULL, v_account, v_releaseDate, v_transfer, 'C', 'TRANSFERÊNCIA RECEBIDA - STEFANINIFOOD '||p_month||'/'||substr(p_year, length(p_year)-1));
            COMMIT;
        END IF;

        SP_UPDATE_BALANCE(v_account);

    END LOOP;

END;

/
