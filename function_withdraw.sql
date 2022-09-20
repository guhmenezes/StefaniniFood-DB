--------------------------------------------------------
--  Arquivo criado - terça-feira-setembro-20-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function WITHDRAW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "STFDEV"."WITHDRAW" 
(p_account IN BANK_STATEMENTS.ACCOUNT_NUMBER%TYPE, p_value IN FLOAT)
RETURN CHAR
IS
    v_balance DIGITAL_ACCOUNTS.BALANCE%TYPE;
BEGIN
    INSERT INTO BANK_STATEMENTS VALUES (NULL, p_account, SYSDATE, p_value, 'D', 'SAQUE');
    SP_UPDATE_BALANCE(p_account);
    SELECT BALANCE INTO v_balance FROM DIGITAL_ACCOUNTS WHERE ACCOUNT_NUMBER = p_account;
    RETURN 'Saldo: '||TO_CHAR(v_balance, '9990D00');
END;

/
