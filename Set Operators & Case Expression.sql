
--SET OPERATIONS



--UNION / UNION ALL


--QUESTION: List the products sold in the cities of Charlotte and Aurora

SELECT product_name
FROM sale.customer c
INNER JOIN sale.orders o ON o.customer_id=c.customer_id
INNER JOIN sale.order_item i ON o.order_id=i.order_id
INNER JOIN product.product p ON i.product_id=p.product_id
WHERE city='Charlotte'
UNION
SELECT product_name
FROM sale.customer c
INNER JOIN sale.orders o ON o.customer_id=c.customer_id
INNER JOIN sale.order_item i ON o.order_id=i.order_id
INNER JOIN product.product p ON i.product_id=p.product_id
WHERE city='Aurora'



--UNION ALL/UNION vs IN 

SELECT product_name
FROM sale.customer c
INNER JOIN sale.orders o ON o.customer_id=c.customer_id
INNER JOIN sale.order_item i ON o.order_id=i.order_id
INNER JOIN product.product p ON i.product_id=p.product_id
WHERE city='Charlotte'
UNION ALL
SELECT product_name
FROM sale.customer c
INNER JOIN sale.orders o ON o.customer_id=c.customer_id
INNER JOIN sale.order_item i ON o.order_id=i.order_id
INNER JOIN product.product p ON i.product_id=p.product_id
WHERE city='Aurora'


SELECT product_name
FROM sale.customer c
INNER JOIN sale.orders o ON o.customer_id=c.customer_id
INNER JOIN sale.order_item i ON o.order_id=i.order_id
INNER JOIN product.product p ON i.product_id=p.product_id
WHERE city IN ('Charlotte','Aurora')


---SOME IMPORTANT RULES OF UNION / UNION ALL
---Even if the contents of to be unified columns are different, the data type must be the same.

SELECT brand_id
FROM product.brand
UNION
SELECT category_id
FROM product.category


---The number of columns to be unified must be the same in both queries.

SELECT *
FROM product.brand
UNION
SELECT *
FROM product.category


--Extra note: working with other database

SELECT city
FROM sale.customer
UNION ALL
SELECT Region
FROM [Northwind].[dbo].[Employees]


---QUESTION: Write a query that returns all customers whose first or last name is Thomas.  
---(don't use 'OR')

SELECT first_name, last_name
FROM sale.customer
WHERE first_name='Thomas'
UNION ALL
SELECT first_name, last_name
FROM sale.customer
WHERE last_name='Thomas'


---INTERSECT-------------------------------------------------

---QUESTION: Write a query that returns all brands with products for both 2018 and 2020 model year.

SELECT b.brand_id, brand_name
FROM product.brand b
INNER JOIN product.product p ON b.brand_id=p.brand_id
WHERE model_year=2018
INTERSECT
SELECT b.brand_id, brand_name
FROM product.brand b
INNER JOIN product.product p ON b.brand_id=p.brand_id
WHERE model_year=2020;


SELECT brand_id, brand_name
FROM product.brand 
WHERE brand_id IN(
				SELECT brand_id
				FROM product.product
				WHERE model_year=2018
				INTERSECT
				SELECT brand_id
				FROM product.product
				WHERE model_year=2020
				)



---QUESTION: Write a query that returns the first and the last names of the customers who placed orders in all of 2018, 2019, and 2020.


SELECT first_name, last_name
FROM sale.customer
WHERE customer_id IN(
				SELECT customer_id
				FROM sale.orders
				WHERE YEAR(order_date)=2018
				INTERSECT
				SELECT customer_id
				FROM sale.orders
				WHERE YEAR(order_date)=2019
				INTERSECT
				SELECT customer_id
				FROM sale.orders
				WHERE YEAR(order_date)=2020
				)



---EXCEPT-------------------------------------------------

---QUESTION: Write a query that returns the brands have 2018 model products but not 2019 model products.

SELECT b.brand_id, brand_name
FROM product.brand b
INNER JOIN product.product p ON b.brand_id=p.brand_id
WHERE model_year=2018
EXCEPT
SELECT b.brand_id, brand_name
FROM product.brand b
INNER JOIN product.product p ON b.brand_id=p.brand_id
WHERE model_year=2019


SELECT brand_id, brand_name
FROM product.brand 
WHERE brand_id IN(
				SELECT brand_id
				FROM product.product
				WHERE model_year=2018
				EXCEPT
				SELECT brand_id
				FROM product.product
				WHERE model_year=2019)



WITH t1 AS(
			SELECT brand_id
			FROM product.product
			WHERE model_year=2018
			EXCEPT
			SELECT brand_id
			FROM product.product
			WHERE model_year=2019)
SELECT b.brand_id, brand_name
FROM product.brand b, t1
WHERE b.brand_id=t1.brand_id



---QUESTION: Write a query that contains only products ordered in 2019 (The result should not include products ordered in other years)

 
SELECT i.product_id, p.product_name
FROM sale.orders o 
INNER JOIN sale.order_item i ON o.order_id=i.order_id
INNER JOIN product.product p ON i.product_id=p.product_id
WHERE YEAR(o.order_date)=2019
EXCEPT
SELECT i.product_id, p.product_name
FROM sale.orders o 
INNER JOIN sale.order_item i ON o.order_id=i.order_id
INNER JOIN product.product p ON i.product_id=p.product_id
WHERE YEAR(o.order_date)<>2019



--CASE EXPRESSION

--Simple Case Expression

--QUESTION: Create a new column with the meaning of the values in the Order_Status column. 
--1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed

SELECT order_id , order_status, 
	CASE order_status
		WHEN 1 THEN 'Pending'
		WHEN 2 THEN 'Processing'
		WHEN 3 THEN 'Rejected'
		WHEN 4 THEN 'Completed'
		ELSE 'Invalid order'
	END order_status_desc
FROM sale.orders


--Searched Case Expression

--QUESTION: Create a new column with the meaning of the values in the Order_Status column. 
--(use searched case expresion)
--1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed

SELECT order_id , order_status, 
	CASE 
		WHEN order_status=1 THEN 'Pending'
		WHEN order_status=2 THEN 'Processing'
		WHEN order_status=3 THEN 'Rejected'
		WHEN order_status=4 THEN 'Completed'
		ELSE 'Invalid order'
	END order_status_desc
FROM sale.orders


---QUESTION: Create a new column that shows which email service provider ("Gmail", "Hotmail", "Yahoo" or "Other" ).

SELECT first_name, last_name, email,  
	CASE 
		WHEN email LIKE '%gmail%' THEN 'Gmail'
		WHEN email LIKE '%hotmail%' THEN 'Hotmail'
		WHEN email LIKE '%yahoo%' THEN 'Yahoo'
		WHEN email IS NOT NULL THEN 'Other'
		ELSE NULL
	END email_provider
FROM sale.customer


--USING WITH BUILT-IN FUNCTIONS

SELECT first_name, last_name, email,  
	LEN(CASE 
		WHEN email LIKE '%gmail%' THEN 'Gmail'
		WHEN email LIKE '%hotmail%' THEN 'Hotmail'
		WHEN email LIKE '%yahoo%' THEN 'Yahoo'
		WHEN email IS NOT NULL THEN 'Other'
		ELSE NULL
	END) email_provider
FROM sale.customer

--USING WITH GROUP BY

SELECT COUNT(customer_id)
FROM sale.customer
GROUP BY 
	CASE 
		WHEN email LIKE '%gmail%' THEN 'Gmail'
		WHEN email LIKE '%hotmail%' THEN 'Hotmail'
		WHEN email LIKE '%yahoo%' THEN 'Yahoo'
		WHEN email IS NOT NULL THEN 'Other'
		ELSE NULL
	END
	

---QUESTION: Write a query that gives the first and last names of customers who have ordered products from the computer accessories, speakers, and mp4 player categories in the same order.

;WITH t1 AS(
SELECT c.customer_id,first_name, last_name, o.order_id,
	SUM(CASE WHEN category_name = 'computer accessories' THEN 1 ELSE 0 END) ca,
	SUM(CASE WHEN category_name = 'speakers' THEN 1 ELSE 0 END) sp,
	SUM(CASE WHEN category_name = 'mp4 player' THEN 1 ELSE 0 END) MP4
FROM sale.customer c 
INNER JOIN sale.orders o ON c.customer_id=o.customer_id
INNER JOIN sale.order_item i ON o.order_id=i.order_id
INNER JOIN product.product p ON i.product_id=p.product_id
INNER JOIN product.category ct ON p.category_id=ct.category_id
GROUP BY c.customer_id,first_name, last_name, o.order_id)
SELECT *
FROM t1
WHERE ca>0 AND sp>0 AND MP4>0


---QUESTION: Write a query that returns the count of the orders day by day in a pivot table format that has been shipped two days later.
---(2 günden geç kargolanan sipariþlerin haftanýn günlerine göre daðýlýmýný hesaplayýnýz)

--SOUTION-1
SELECT
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Monday' THEN 1 ELSE 0 END) Monday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Tuesday' THEN 1 ELSE 0 END) Tuesday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Wednesday' THEN 1 ELSE 0 END) Wednesday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Thursday' THEN 1 ELSE 0 END) Thursday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Friday' THEN 1 ELSE 0 END) Friday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Saturday' THEN 1 ELSE 0 END) Saturday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Sunday' THEN 1 ELSE 0 END) Sunday
FROM sale.orders
WHERE DATEDIFF(DAY, order_date, shipped_date) > 2

--SOUTION-2
SELECT
	CASE
		WHEN DATENAME(DW, order_date) = 'Monday' THEN 'Monday'
		WHEN DATENAME(DW, order_date) = 'Tuesday' THEN 'Tuesday'
		WHEN DATENAME(DW, order_date) = 'Wednesday' THEN 'Wednesday'
		WHEN DATENAME(DW, order_date) = 'Thursday' THEN 'Thursday'
		WHEN DATENAME(DW, order_date) = 'Friday' THEN 'Friday'
		WHEN DATENAME(DW, order_date) = 'Saturday' THEN 'Saturday'
		WHEN DATENAME(DW, order_date) = 'Sunday' THEN 'Sunday'
	END AS [Day],
	COUNT(a.order_id) AS count_of_days
FROM sale.orders AS a
WHERE DATEDIFF(DAY, a.order_date, a.shipped_date) > 2
GROUP BY
	CASE
		WHEN DATENAME(DW, order_date) = 'Monday' THEN 'Monday'
		WHEN DATENAME(DW, order_date) = 'Tuesday' THEN 'Tuesday'
		WHEN DATENAME(DW, order_date) = 'Wednesday' THEN 'Wednesday'
		WHEN DATENAME(DW, order_date) = 'Thursday' THEN 'Thursday'
		WHEN DATENAME(DW, order_date) = 'Friday' THEN 'Friday'
		WHEN DATENAME(DW, order_date) = 'Saturday' THEN 'Saturday'
		WHEN DATENAME(DW, order_date) = 'Sunday' THEN 'Sunday'
	END 

--SOUTION-3
SELECT
	DATENAME(DW, order_date) [order_day],
	COUNT(DATENAME(DW, order_date)) cnt_order
FROM sale.orders 
WHERE DATEDIFF(DAY, order_date, shipped_date) > 2
GROUP BY DATENAME(DW, order_date)


SELECT
	DATENAME(DW, order_date) day, 
	COUNT(order_id) total
FROM sale.orders
WHERE DATEDIFF(DAY, order_date, shipped_date) > 2
GROUP BY DATENAME(DW, order_date)