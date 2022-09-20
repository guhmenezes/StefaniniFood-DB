--------------------------------------------------------
--  Arquivo criado - terça-feira-setembro-20-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function CONFIRMPAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "STFDEV"."CONFIRMPAYMENT" 
(p_total IN orders.total%type, p_paymentMethod IN INTEGER, 
p_customerId in customers.id%type, 
p_creditCard in credit_cards.card_number%type default null,
p_expirationCard in CREDIT_CARDS.EXPIRATION_DATE%type default null)
RETURN CHAR
IS
    v_balance wallets.balance%type;
    v_validCC CHAR;
    v_accepted CHAR := 0;
BEGIN
    IF p_paymentMethod = 1 THEN 
        SELECT BALANCE INTO v_balance FROM WALLETS WHERE WALLETS.CUSTOMER_ID = p_customerId;
        IF v_balance >= p_total then
            v_accepted := 1;
            dbms_output.put_line('Pedido realizado com sucesso, R$' || TO_CHAR(p_total, '999D00') || ' debitado da carteira.');
        ELSE
            dbms_output.put_line('Pedido NÃO realizado. Saldo insuficiente!');  
        END IF;
    ELSIF p_paymentMethod = 2 THEN
        IF p_creditCard IS NULL OR p_expirationCard IS NULL THEN
            dbms_output.put_line('Pedido NÃO realizado.'); 
        ELSIF VALIDATE_CONVERSION(p_creditCard as NUMBER) = 1 
        AND LENGTH(p_creditCard) IN (13,14,15,16) AND
        p_expirationCard >= SYSDATE THEN
            v_validCC := checkCreditCard(p_creditCard, p_expirationCard);
            IF v_validCC = 1 THEN
                v_accepted := 1;
                IF substr(p_creditCard, 1,1) = '5' THEN
                dbms_output.put_line('Pedido realizado com sucesso, pagamento com cartão de crédito Mastercard final '
                || substr(p_creditCard, Length(p_creditCard) -3) || '.');
                ELSIF substr(p_creditCard, 1,1) = '4' THEN
                dbms_output.put_line('Pedido realizado com sucesso, pagamento com cartão de crédito Visa final '
                || substr(p_creditCard, Length(p_creditCard) -3) || '.');
                ELSIF substr(p_creditCard, 1,1) = '3' THEN
                dbms_output.put_line('Pedido realizado com sucesso, pagamento com cartão de crédito American Express final '
                || substr(p_creditCard, Length(p_creditCard) -3) || '.');
                ELSIF substr(p_creditCard, 1,1) = '6' THEN
                dbms_output.put_line('Pedido realizado com sucesso, pagamento com cartão de crédito Discover final '
                || substr(p_creditCard, Length(p_creditCard) -3) || '.');
                ELSE
                dbms_output.put_line('Pedido realizado com sucesso, pagamento com cartão de crédito final '
                || substr(p_creditCard, Length(p_creditCard) -3) || '.');
                END IF;
            ELSE
                dbms_output.put_line('Pedido NÃO realizado. Cartão inválido!');  
            END IF;
        ELSE
            dbms_output.put_line('Pedido NÃO realizado.'); 
        END IF;
        RETURN v_accepted;
    ELSIF p_paymentMethod = 3 THEN
        v_accepted := 1;
        dbms_output.put_line('Pedido realizado com sucesso, pague R$' || TO_CHAR(p_total, '999D00') || ' para o motoboy.');    
    ELSE
        dbms_output.put_line('Pedido NÃO realizado. Forma de pagamento inválida!');    
    END IF;
    RETURN v_accepted;
END;

/
