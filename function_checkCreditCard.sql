--------------------------------------------------------
--  Arquivo criado - terça-feira-setembro-20-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function CHECKCREDITCARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "STFDEV"."CHECKCREDITCARD" 
(p_CARDNUMBER IN CREDIT_CARDS.CARD_NUMBER%type, 
p_expirationCard in CREDIT_CARDS.EXPIRATION_DATE%type)
RETURN CHAR
IS
    isValid CHAR(1) :=0;
    len NUMBER;
    digit NUMBER;
    total NUMBER := 0;
    res NUMBER := 0;
BEGIN
    len := Length(p_CARDNUMBER);
    IF len = 16 THEN
        FOR i IN REVERSE 1.. len LOOP          
            digit := TO_NUMBER(Substr(p_CARDNUMBER, i, 1));
            
            IF (MOD(i, 2) <> 0) THEN
                res := digit * 2;
                IF res > 9 THEN
                res := res - 9;
                END IF;
            ELSE
                res := digit;
            END IF;
            total := total + res;
        END LOOP;
    ELSE
                FOR i IN 1.. len LOOP          
            digit := TO_NUMBER(Substr(p_CARDNUMBER, i, 1));
            
            IF (MOD(i, 2) = 0) THEN
                res := digit * 2;
                IF res > 9 THEN
                res := res - 9;
                END IF;
            ELSE
                res := digit;
            END IF;
            total := total + res;
        END LOOP;
    END IF;
    
    IF MOD(total,10) = 0 AND len > 1 AND p_expirationCard > SYSDATE then
    isValid :=1;
    end if;
    RETURN isvalid;
END;

/
