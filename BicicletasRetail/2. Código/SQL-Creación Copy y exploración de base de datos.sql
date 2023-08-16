-- Creación de la base de datos --

-- Creación de la tabla de transacciones --
CREATE table transacciones(
transaction_id varchar(10),
product_id int,
customer_id int,
transaction_date date,
online_order boolean,
order_status varchar(15),
brand varchar(50),
product_line varchar(15),
product_class varchar(10),
product_size varchar(10),
list_price numeric,
standard_cost numeric,
product_first_sold_date date);

-- Copio los datos desde los archivos hasta las tablas de la base de datos
COPY transacciones FROM 'C:/Users/57350/Desktop/Transacciones.csv' WITH DELIMITER ',' CSV HEADER;

SELECT * from transacciones;