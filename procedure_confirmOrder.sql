--------------------------------------------------------
--  Arquivo criado - terça-feira-setembro-20-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_CONFIRM_ORDER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "STFDEV"."SP_CONFIRM_ORDER" 
(p_orderId IN orders.id%type, p_paymentMethod IN INTEGER, 
p_cardId IN credit_cards.id%type default null,
p_creditCard IN credit_cards.card_number%type default null,
p_nameCard IN credit_cards.printed_name%type default null,
p_expirationCard IN DATE default null,
p_cVVCard IN credit_cards.cvv%type default null)
IS
    v_orderStatus ORDERS.STATUS%TYPE;
    v_customerId ORDERS.CUSTOMER_ID%TYPE;
    v_hasDeliveryAddress CHAR;
    v_match CHAR := 1;
    v_walletId WALLETS.ID%TYPE;
    v_balance FLOAT;
    v_total FLOAT;
    v_card CREDIT_CARDS.CARD_NUMBER%TYPE;
    v_expCard CREDIT_CARDS.EXPIRATION_DATE%TYPE;
    v_paymentAccepted CHAR := 0;
    v_alreadyAdd CHAR;
    v_motoboy INTEGER;
    v_companyId COMPANIES.ID%TYPE;
    v_qtyDelivery INTEGER;
BEGIN
    SELECT O.CUSTOMER_ID, O.TOTAL, O.STATUS INTO v_customerId, v_total, v_orderStatus FROM ORDERS O WHERE O.ID = p_orderId;
    SELECT MOTOBOY_ID INTO v_motoboy FROM ORDERS WHERE ID = P_orderId;
    SELECT COUNT(*) INTO v_hasDeliveryAddress FROM ADDRESSES WHERE CUSTOMER_ID = v_customerId AND DEFAULT_ADDRESS = '1';
    
    IF v_hasDeliveryAddress = 0 THEN
        dbms_output.put_line('Defina um endereço de entrega.');
    ELSE
        SELECT COMPANY_ID INTO v_companyId FROM motoboys M INNER JOIN ORDERS O ON M.ID = O.MOTOBOY_ID WHERE M.ID= v_motoboy AND O.ID = p_orderId;
        SELECT COUNT(*) INTO v_match FROM (SELECT L.CITY, L.L_STATE FROM COMPANIES C INNER JOIN LOCALIZATIONS L ON L.COMPANY_ID = C.ID WHERE C.ID = v_companyId), 
        ADDRESSES WHERE CUSTOMER_ID = v_customerId AND DEFAULT_ADDRESS = '1' AND L_STATE = UF AND UPPER(CITY) = UPPER(LOCALIDADE); 

        IF v_match = 0 THEN
        dbms_output.put_line('Restaurante não atende à sua regiao.');
        END IF;
        
    END IF;
    
    IF v_orderStatus = 'FINALIZADO' AND v_match = 1 THEN
    dbms_output.put_line('Pedido já finalizado.');
    ELSIF v_orderStatus = 'EM_PREPARACAO' AND v_match = 1 THEN
    dbms_output.put_line('O restaurante já está preparando seu pedido.');
    ELSIF v_orderStatus = 'AGUARDANDO' AND v_match = 1 THEN
        v_paymentAccepted := confirmPayment(v_total, p_paymentMethod, v_customerId, p_creditCard, p_expirationCard);
        
        IF p_paymentMethod = 1 THEN
            SELECT BALANCE INTO v_balance FROM WALLETS WHERE CUSTOMER_ID = v_customerId;
            v_balance := v_balance - v_total;
            UPDATE WALLETS SET BALANCE = v_balance WHERE CUSTOMER_ID = v_customerId;
        ELSIF p_paymentMethod = 2 THEN
            SELECT ID INTO v_walletId FROM WALLETS WHERE CUSTOMER_ID = v_customerId;
            IF p_cardId IS NOT NULL THEN
                SELECT COUNT(*) INTO v_alreadyAdd FROM CREDIT_CARDS WHERE ID = p_cardId AND WALLET_ID = v_walletId;
                IF v_alreadyAdd = 1 THEN
                SELECT CARD_NUMBER, EXPIRATION_DATE INTO v_card, v_expCard 
                FROM CREDIT_CARDS WHERE ID = p_cardId AND WALLET_ID = v_walletId
                GROUP BY CARD_NUMBER, EXPIRATION_DATE;
                v_paymentAccepted := confirmPayment(v_total, p_paymentMethod, v_customerId, v_card, v_expCard);
                ELSE
                    dbms_output.put_line('Cartão de Crédito com ID '||p_cardId||' não encontrado.');
                END IF;
            ELSE
                SELECT COUNT(*) INTO v_alreadyAdd FROM CUSTOMERS C INNER JOIN WALLETS W ON W.CUSTOMER_ID = C.ID 
                INNER JOIN CREDIT_CARDS CC ON CC.WALLET_ID = W.ID WHERE C.ID = v_customerId  AND CC.CARD_NUMBER = p_creditCard;
                
                IF v_alreadyAdd = 0 THEN
                    IF p_creditCard IS NULL THEN
                    dbms_output.put_line('Cartão de Crédito NÃO foi salvo. Número do cartão é obrigatório.');
                    ELSIF p_nameCard IS NULL THEN
                    dbms_output.put_line('Cartão de Crédito NÃO foi salvo. Nome impresso no cartão é obrigatório.');
                    ELSIF p_expirationCard IS NULL THEN
                    dbms_output.put_line('Cartão de Crédito NÃO foi salvo. Data de validade é obrigatória.');
                    ELSIF p_cVVCard IS NULL THEN
                    dbms_output.put_line('Cartão de Crédito NÃO foi salvo. CVV é obrigatório.');
                    ELSIF v_paymentAccepted = 1 THEN
                    INSERT INTO CREDIT_CARDS VALUES (NULL, v_walletId, p_creditCard, p_nameCard, p_expirationCard, p_cVVCard);
                    dbms_output.put_line('Cartão de Crédito salvo.');
                    END IF;
                END IF;
            END IF;
        END IF;
            UPDATE ORDERS SET STATUS = 'EM_PREPARACAO', ORDERED_AT = SYSDATE, UPDATED_AT = SYSDATE WHERE ID = p_orderId; 
            SELECT COUNT(*) into v_qtyDelivery FROM ORDERS WHERE MOTOBOY_ID = v_motoboy AND STATUS = 'FINALIZADO';
            UPDATE MOTOBOYS SET DELIVERIES_QTY = v_qtyDelivery WHERE ID = v_motoboy;
        IF v_paymentAccepted = 0 THEN
        dbms_output.put_line('rollback');
        ROLLBACK;
        ELSE
        COMMIT;
        SP_CALCULATE_TRANSFER(EXTRACT(MONTH FROM SYSDATE), EXTRACT(YEAR FROM SYSDATE), '19,9', 12);
        END IF;
    END IF;
END;

/
