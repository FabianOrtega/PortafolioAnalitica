-- Creación de tablas de la base de datos --

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

	-- Creación de la tabla de clientes --
CREATE table clientes(
customer_id int PRIMARY KEY,
first_name varchar(30),
last_name varchar(30),
gender varchar(15),
past_3_years_bike_related_purchases varchar(50),
job_title varchar(100),
job_industry_category varchar(100),
wealth_segment varchar(30),
owns_car varchar(5));

	-- Creación de la tabla de clientes_direción --

CREATE table clientes_direccion(
customer_id int PRIMARY KEY,
address varchar(100),
postcode int,
statee varchar(30),
country varchar(50))

-- Copio los datos desde los archivos hasta las tablas de la base de datos
COPY transacciones FROM 'C:/Users/57350/Desktop/Transacciones.csv' WITH DELIMITER ',' CSV HEADER;
COPY clientes FROM 'C:/Users/57350/Desktop/Customer.csv' WITH DELIMITER ',' CSV HEADER;
COPY clientes_direccion FROM 'C:/Users/57350/Desktop/Geografico.csv' WITH DELIMITER ',' CSV HEADER;

/* -----------------------------
   Preguntas del caso de estudio
   ----------------------------*/
/* 1. 
P: ¿Cuales son los productos que más ingresos generan en febrero? 
Q: ¿What are the products that generate the most income in February?
*/

SELECT
	product_id,
	brand as Brand,
	product_line as Line,
	product_class,
	product_size,
	sum(list_price::money) AS Revenue
FROM 
	transacciones
WHERE
	EXTRACT(MONTH FROM transaction_date) = 2 --Note: 2 == febrero == february
GROUP BY 
	product_id,
	brand,
	product_line,
	product_class,
	product_size
ORDER BY 
	sum(list_price) DESC;
	
/* 2. 
P: ¿Cuales son las marcas que más se venden por medios digitales? 
Q:¿What are the brands that sell the most through digital media?
*/
-- Extensión necesaria para crear 'Pivot tables' en POSTGRESQL
CREATE EXTENSION tablefunc;

SELECT 
	*
FROM 
	crosstab(
		'SELECT brand, online_order, COUNT(transaction_id)
		  FROM transacciones
		  GROUP BY brand, online_order
		  ORDER BY brand, online_order DESC',
		'SELECT DISTINCT online_order FROM transacciones ORDER BY online_order') 
AS 
	ct (brand text, physical int, digital int) 
WHERE
	digital > 1000
ORDER BY 
	digital DESC;
	
/* 3.
P: ¿De qué estados son los clientes que más han comprado en los pasados 3 años, cuanto gastan por transacciones?
Q: ¿From which states are the customers who have bought the most in the past 3 years, how much do they spend per transaction?
*/

SELECT
	d.statee AS state,
	AVG(
		c.past_3_years_bike_related_purchases::INT
		) AS "transactions (#)",
	AVG(
		t.list_price
		) AS "spend ($)"
FROM
	clientes_direccion d
LEFT JOIN 	
	clientes c ON d.customer_id = c.customer_id
LEFT JOIN
	transacciones t ON d.customer_id = t.customer_id
GROUP BY
	state
ORDER BY
	"transactions (#)" DESC;
		
/* 4.
P: ¿De que Estado de Australia provienen la mayoria de transacciones digitales?
Q: ¿From which State of Australia do the majority of digital transactions come from?
*/
 -- Nota: Todas las transacciones son de Australia
 -- Note: All transactions are from Australia

SELECT
	c.statee,
	SUM(CASE
		WHEN
			t.online_order
		THEN
			1
		ELSE
			0
		END) AS digital_transactions,
	SUM(CASE
		WHEN
			t.online_order
		THEN
			0
		ELSE
			1
		END) AS physic_transactions
FROM 
	transacciones t
INNER JOIN
	clientes_direccion c ON t.customer_id = c.customer_id
GROUP BY
	c.statee
ORDER BY
	 digital_transactions DESC

/* 5.
P: ¿Cuál es el promedio de ingreso por transacción entre quienes tienen carro y los que no?
Q: ¿What is the average revenue per transaction between those who have a car and those who do not?
*/

SELECT
	c.owns_car,
	avg(t.list_price) AS AVG_spend
FROM
	transacciones t
INNER JOIN
	clientes c ON c.customer_id = t.customer_id
GROUP BY
	owns_car