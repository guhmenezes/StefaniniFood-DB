--TABLES

CREATE TABLE CUSTOMERS (
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
CPF CHAR(11) NOT NULL,
FULL_NAME NVARCHAR2(40) NOT NULL,
PHONE VARCHAR2(11) NOT NULL,
EMAIL VARCHAR2(30) NOT NULL,
PASSWORD NVARCHAR2(10) NOT NULL,
ACTIVE CHAR(1) DEFAULT ON NULL 'Y',
CREATED_AT DATE DEFAULT ON NULL SYSDATE,
UPDATED_AT DATE NULL
);

CREATE TABLE ADDRESSES (
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
CUSTOMER_ID INTEGER NOT NULL,
CEP CHAR(9) NOT NULL,
LOGRADOURO NVARCHAR2(50) NOT NULL,
NUMERO VARCHAR2(4) NOT NULL,
COMPLEMENTO NVARCHAR2(50) NULL,
BAIRRO NVARCHAR2(50) NOT NULL,
LOCALIDADE NVARCHAR2(30) NOT NULL,
UF CHAR(2) NOT NULL,
DDD CHAR(2) NULL,
GIA VARCHAR2(10) NULL,
IBGE VARCHAR2(10) NULL,
SIAFI VARCHAR2(10) NULL,
DEFAULT_ADDRESS CHAR(1) DEFAULT ON NULL 0
);

CREATE TABLE WALLETS(
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
CUSTOMER_ID INTEGER NOT NULL,
PIX_KEY VARCHAR2(30),
BALANCE FLOAT DEFAULT ON NULL 0.0,
UPDATED_AT DATE DEFAULT ON NULL SYSDATE
);

CREATE TABLE CREDIT_CARDS(
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
WALLET_ID INTEGER NOT NULL,
CARD_NUMBER VARCHAR2(16) NOT NULL,
PRINTED_NAME VARCHAR2(20) NOT NULL,
EXPIRATION_DATE DATE NOT NULL,
CVV CHAR(3) NOT NULL
);

CREATE TABLE COMPANIES(
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
ACCOUNT_NUMBER INTEGER UNIQUE NOT NULL,
CNPJ CHAR(14) NOT NULL,
COMPANY_NAME NVARCHAR2(40) NOT NULL,
PHONE VARCHAR2(11) NOT NULL,
EMAIL VARCHAR2(30) NOT NULL,
PASSWORD NVARCHAR2(10) NOT NULL,
CREATED_AT DATE DEFAULT ON NULL SYSDATE,
UPDATED_AT DATE DEFAULT NULL
);

CREATE TABLE LOCALIZATIONS(
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
COMPANY_ID INTEGER NOT NULL,
ZIP_CODE CHAR(11) NOT NULL,
STREET NVARCHAR2(50) NOT NULL,
L_NUMBER VARCHAR2(4) NOT NULL,
DISTRICT NVARCHAR2(30) NOT NULL,
CITY NVARCHAR2(30) NOT NULL,
L_STATE CHAR(2) NOT NULL,
OPENING_TIME DATE DEFAULT ON NULL TO_DATE('01/01/01 10:00', 'DD/MM/YY HH24:MI'),
CLOSING_TIME DATE DEFAULT ON NULL TO_DATE('01/01/01 22:00', 'DD/MM/YY HH24:MI')
);

CREATE TABLE MOTOBOYS(
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
COMPANY_ID INTEGER,
ACCOUNT_NUMBER INTEGER UNIQUE NOT NULL,
CPF CHAR(11) NOT NULL,
FULL_NAME NVARCHAR2(40) NOT NULL,
PHONE CHAR(11) NOT NULL,
ROUTE_VALUE FLOAT DEFAULT ON NULL 8.5,
DELIVERIES_QTY INTEGER DEFAULT ON NULL 0
);

CREATE TABLE ORDERS(
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
COUPON_ID INTEGER NULL,
MOTOBOY_ID INTEGER NOT NULL,
CUSTOMER_ID INTEGER NOT NULL,
TOTAL FLOAT,
STATUS VARCHAR2(15) NOT NULL,
ORDERED_AT DATE DEFAULT ON NULL SYSDATE,
UPDATED_AT DATE DEFAULT NULL
);

CREATE TABLE ORDERED_ITEMS(
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
ORDER_ID INTEGER NOT NULL,
PRODUCT_ID INTEGER NOT NULL,
QUANTITY INTEGER DEFAULT ON NULL 1,
UNIT_PRICE FLOAT NOT NULL
);

CREATE TABLE PRODUCTS(
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
COMPANY_ID INTEGER NOT NULL,
PRODUCT_NAME NVARCHAR2(20) NOT NULL,
PRICE FLOAT NOT NULL,
DESCRIPTION NVARCHAR2(100) NULL
);

CREATE TABLE COUPONS(
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
CODE VARCHAR2(10) NOT NULL,
VALID_AT DATE NOT NULL,
DISCOUNT_VALUE FLOAT NOT NULL,
QUANTITY INTEGER NOT NULL
);

CREATE TABLE DIGITAL_ACCOUNTS(
ACCOUNT_NUMBER NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
BALANCE FLOAT DEFAULT ON NULL 0.0,
RECEIVABLE FLOAT DEFAULT ON NULL 0.0
);

CREATE TABLE BANK_STATEMENTS(
ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY NOT NULL,
ACCOUNT_NUMBER INTEGER NOT NULL,
RELEASE_DATE DATE DEFAULT ON NULL SYSDATE,
AMOUNT FLOAT NOT NULL,
AMOUNT_TYPE CHAR(1) NOT NULL,
T_DESCRIPTION NVARCHAR2(60) NOT NULL
);


-- FOREIGN KEYS

ALTER TABLE ADDRESSES
ADD CONSTRAINT FK_CUSTOMERS_ADDRESSES
FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS (ID);

ALTER TABLE WALLETS
ADD CONSTRAINT FK_CUSTOMERS_WALLETS
FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS (ID);

ALTER TABLE CREDIT_CARDS
ADD CONSTRAINT FK_WALLETS
FOREIGN KEY (WALLET_ID) REFERENCES WALLETS (ID);

ALTER TABLE LOCALIZATIONS
ADD CONSTRAINT FK_COMPANIES_LOCALIZATIONS
FOREIGN KEY (COMPANY_ID) REFERENCES COMPANIES (ID);

ALTER TABLE MOTOBOYS
ADD CONSTRAINT FK_COMPANIES_MOTOBOYS
FOREIGN KEY (COMPANY_ID) REFERENCES COMPANIES (ID);

ALTER TABLE ORDERS
ADD CONSTRAINT FK_MOTOBOYS_ORDERS
FOREIGN KEY (MOTOBOY_ID) REFERENCES MOTOBOYS (ID);

ALTER TABLE ORDERS
ADD CONSTRAINT FK_CUSTOMERS_ORDERS
FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS (ID);

ALTER TABLE PRODUCTS
ADD CONSTRAINT FK_COMPANIES_PRODUCTS
FOREIGN KEY (COMPANY_ID) REFERENCES COMPANIES (ID);

ALTER TABLE ORDERED_ITEMS
ADD CONSTRAINT FK_ORDERS_ORDERED_ITEMS
FOREIGN KEY (ORDER_ID) REFERENCES ORDERS (ID);

ALTER TABLE ORDERED_ITEMS
ADD CONSTRAINT FK_PRODUCTS_ORDERED_ITEMS
FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS (ID);

ALTER TABLE ORDERS
ADD CONSTRAINT FK_COUPONS_ORDERS
FOREIGN KEY (COUPON_ID) REFERENCES COUPONS (ID);

ALTER TABLE COMPANIES
ADD CONSTRAINT FK_DIGITAL_ACCOUNTS_COMPANIES
FOREIGN KEY (ACCOUNT_NUMBER) REFERENCES DIGITAL_ACCOUNTS (ACCOUNT_NUMBER);

ALTER TABLE MOTOBOYS
ADD CONSTRAINT FK_DIGITAL_ACCOUNTS_MOTOBOYS
FOREIGN KEY (ACCOUNT_NUMBER) REFERENCES DIGITAL_ACCOUNTS (ACCOUNT_NUMBER);

ALTER TABLE BANK_STATEMENTS
ADD CONSTRAINT FK_DIGITAL_ACCOUNTS_STATEMENTS
FOREIGN KEY (ACCOUNT_NUMBER) REFERENCES DIGITAL_ACCOUNTS (ACCOUNT_NUMBER);


-- INDEXES

CREATE UNIQUE INDEX CUSTOMER_IX
ON CUSTOMERS (CPF);

CREATE UNIQUE INDEX COMPANY_IX
ON COMPANIES (CNPJ);

CREATE UNIQUE INDEX MOTOBOY_IX
ON MOTOBOYS (CPF);

CREATE INDEX COUPONS_IX
ON COUPONS (CODE);