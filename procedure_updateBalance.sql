--------------------------------------------------------
--  Arquivo criado - terça-feira-setembro-20-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "STFDEV"."SP_UPDATE_BALANCE" 
(p_account in NUMBER)
IS
    v_credit FLOAT;
    v_debit FLOAT;
    v_balance FLOAT;
    v_receivable FLOAT;
BEGIN
        SELECT SUM(S.AMOUNT) INTO v_receivable FROM DIGITAL_ACCOUNTS DA INNER JOIN BANK_STATEMENTS S ON DA.ACCOUNT_NUMBER = S.ACCOUNT_NUMBER 
        WHERE RELEASE_DATE > SYSDATE AND S.ACCOUNT_NUMBER = p_account AND S.AMOUNT_TYPE = 'C' ORDER BY S.RELEASE_DATE;
        SELECT SUM(S.AMOUNT) INTO v_credit FROM DIGITAL_ACCOUNTS DA INNER JOIN BANK_STATEMENTS S ON DA.ACCOUNT_NUMBER = S.ACCOUNT_NUMBER 
        WHERE RELEASE_DATE <= SYSDATE AND S.ACCOUNT_NUMBER = p_account AND S.AMOUNT_TYPE = 'C' ORDER BY S.RELEASE_DATE;
        SELECT SUM(S.AMOUNT) INTO v_debit FROM DIGITAL_ACCOUNTS DA INNER JOIN BANK_STATEMENTS S ON DA.ACCOUNT_NUMBER = S.ACCOUNT_NUMBER 
        WHERE RELEASE_DATE <= SYSDATE AND S.ACCOUNT_NUMBER = p_account AND S.AMOUNT_TYPE = 'D' ORDER BY S.RELEASE_DATE;
        IF v_receivable is null then
            v_receivable := 0;
        END IF;
        IF v_debit is null then
            v_debit := 0;
        END IF;
        IF v_credit is null then
            v_credit := 0;
        END IF;
        v_balance := TO_NUMBER(v_credit) - TO_NUMBER(v_debit);
        UPDATE DIGITAL_ACCOUNTS SET BALANCE = v_balance, RECEIVABLE = v_receivable where ACCOUNT_NUMBER = p_account;
        IF v_balance < 0 THEN
        dbms_output.put_line('SALDO INSUFICIENTE');
        ROLLBACK;
        ELSE 
        COMMIT;
        END IF;
END;

/
