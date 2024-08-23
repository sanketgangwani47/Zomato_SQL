CREATE DATABASE zomato_project;

USE zomato_project;

DROP TABLE IF EXISTS goldusers_signup;
CREATE TABLE goldusers_signup(userid INT,gold_signup_date DATE); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
VALUES 
(1,"2017-09-22"),
(3,"2017-04-21");

DROP TABLE IF EXISTS users;
CREATE TABLE users(userid INT,signup_date DATE); 

INSERT INTO users(userid,signup_date) 
VALUES (1,"2014-09-02"),
(2,"2015-01-15"),
(3,"2014-04-11");


DROP TABLE IF EXISTS product;
CREATE TABLE product(product_id INT,product_name CHAR(2),price INT); 

INSERT INTO product(product_id,product_name,price) 
VALUES
(1,"p1",980),
(2,"p2",870),
(3,"p3",330);

DROP TABLE IF EXISTS sales;
CREATE TABLE sales(userid INT,created_date DATE,product_id INT); 

INSERT INTO sales(userid,created_date,product_id) 
VALUES 
(1,"2017-04-19",2),
(3,"2019-12-18",1),
(2,"2020-07-20",3),
(1,"2019-10-23",2),
(1,"2018-03-19",3),
(3,"2016-12-20",2),
(1,"2016-11-09",1),
(1,"2016-05-20",3),
(2,"2017-09-24",1),
(1,"2017-03-11",2),
(1,"2016-03-11",1),
(3,"2016-11-10",1),
(3,"2017-12-07",2),
(3,"2016-12-15",2),
(2,"2017-11-08",2),
(2,"2018-09-10",3);

-- TOTAL AMOUNT SPENT BY EACH CUSTOMER 

SELECT s.userid,SUM(p.price) AS "Total"
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id
GROUP BY s.userid ;

-- TOP SELLING PRODUCT WITH SALES

SELECT p.product_name,SUM(price) AS "Sales" FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY SUM(price) DESC
LIMIT 1;

-- HOW MANY DAYS EACH CUSTOMER VISITED ZOMATO

SELECT userid,COUNT(DISTINCT created_date) "Days_Visited"
FROM sales
GROUP BY userid;


-- WHAT WAS THE FIRST PRODUCT PURCHASED BY EACH CUSTOMER

SELECT userid,product_name FROM
(SELECT s.userid,p.product_name,
DENSE_RANK() OVER(PARTITION BY userid ORDER BY created_date) AS Rnk
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id) a
WHERE Rnk = 1;

-- WHAT IS THE MOST PURCHASED ITEM ON THE MENU AND HOW MANY TIMES WAS IT PURCHASED BY ALL CUSTOMERS

SELECT userid,COUNT(product_id) AS "No_Of_Orders" FROM sales WHERE product_id =
(SELECT product_id FROM sales
GROUP BY product_id
ORDER BY COUNT(product_id) DESC
LIMIT 1)
GROUP BY userid;

-- MOST ORDERED PRODUCT FOR EACH CUSTOMER

SELECT userid,product_name AS "Most_Ordered_Product",cnt AS "No_Of_Orders" FROM
(SELECT *,DENSE_RANK() OVER(PARTITION BY userid ORDER BY cnt DESC) AS Rnk FROM 
(SELECT userid,product_name,COUNT(product_name) AS Cnt
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id
GROUP BY userid,product_name) a) b
WHERE Rnk = 1;


-- WHICH ITEM WAS PURCHASED FIRST BY THE CUSTOMER AFTER THEY BECAME A MEMBER

SELECT userid,product_name FROM 
(SELECT s.userid,p.product_name,s.created_date,DENSE_RANK() OVER(PARTITION BY s.userid ORDER BY s.created_date) AS Rnk 
FROM sales AS s
JOIN goldusers_signup AS g
ON s.userid = g.userid AND s.created_date>=g.gold_signup_date
JOIN product AS p
ON s.product_id = p.product_id ) a
WHERE Rnk = 1;

-- WHICH ITEM WAS PURCHASED JUST BEFORE THE CUSTOMER BECAME A MEMBER

SELECT * FROM 
(SELECT s.userid,p.product_name,s.created_date,DENSE_RANK() OVER(PARTITION BY s.userid ORDER BY s.created_date DESC) AS Rnk
FROM sales AS s
JOIN goldusers_signup AS g
ON s.userid = g.userid AND s.created_date<g.gold_signup_date
JOIN product AS p
ON s.product_id = p.product_id) a
WHERE Rnk = 1;


-- WHAT IS THE AMOUNT SPENT BY EACH CUSTOMER BEFORE THEY BECAME A MEMBER

SELECT s.userid,COUNT(p.product_name) AS "No_of_orders",SUM(p.price) AS "Total_Amount_Spent" 
FROM sales AS s
JOIN goldusers_signup AS g
ON s.userid = g.userid AND s.created_date<g.gold_signup_date
JOIN product AS p
ON s.product_id = p.product_id
GROUP BY s.userid;


-- PERCENTAGE CONTRIBUTION OF INDIVIDUAL PRODUCTS IN TOTAL SALES

SELECT p.product_name,
(SUM(price) /(SELECT SUM(price) FROM sales AS s JOIN product AS p ON s.product_id = p.product_id))*100 
AS "Percentage_Contribution"
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id
GROUP BY p.product_name;

-- PERCENTAGE CONTRIBUTION OF GOLD MEMBERS TRANSACTIONS IN TOTAL SALES

SELECT (SUM(price)/(SELECT SUM(price) FROM sales AS s JOIN product AS p ON s.product_id = p.product_id))*100 
AS "Percentage_Contribution"
FROM sales AS s
JOIN goldusers_signup AS g
ON s.userid = g.userid AND s.created_date>=g.gold_signup_date
JOIN product AS p
ON s.product_id = p.product_id;

-- PERCENTAGE CONTRIBUTION OF INDIVIDUAL USERS IN TOTAL SALES

SELECT s.userid,
(SUM(price) /(SELECT SUM(price) FROM sales AS s JOIN product AS p ON s.product_id = p.product_id))*100 
AS "Percentage_Contribution"
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id
GROUP BY s.userid;


-- YEARLY SALES GENERATED FROM EACH USER

SELECT s.userid,
SUM(CASE WHEN YEAR(s.created_date) = "2016" THEN p.price END) AS "Yr_2016" ,
SUM(CASE WHEN YEAR(s.created_date) = "2017" THEN p.price END) AS "Yr_2017" ,
SUM(CASE WHEN YEAR(s.created_date) = "2018" THEN p.price END) AS "Yr_2018" ,
SUM(CASE WHEN YEAR(s.created_date) = "2019" THEN p.price END) AS "Yr_2019" ,
SUM(CASE WHEN YEAR(s.created_date) = "2020" THEN p.price END) AS "Yr_2020" 
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id
GROUP BY s.userid;


-- YEARLY SALES GENERATED FROM EACH PRODUCT

SELECT p.product_id,
SUM(CASE WHEN YEAR(s.created_date) = "2016" THEN p.price END) AS "Yr_2016" ,
SUM(CASE WHEN YEAR(s.created_date) = "2017" THEN p.price END) AS "Yr_2017" ,
SUM(CASE WHEN YEAR(s.created_date) = "2018" THEN p.price END) AS "Yr_2018" ,
SUM(CASE WHEN YEAR(s.created_date) = "2019" THEN p.price END) AS "Yr_2019" ,
SUM(CASE WHEN YEAR(s.created_date) = "2020" THEN p.price END) AS "Yr_2020" 
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id
GROUP BY p.product_id;



-- IF BUYING SOME PRODUCTS GENERATES ZOMATO POINTS THEN CALCULATE 
-- TOTAL POINTS COLLECTED BY EACH CUSTOMER 
-- PRODUCT NAME THAT HAS CONTRIBUTED MOST IN TOTAL POINTS
-- [PRODUCT P1: 5Rs = 1 ZOMATO POINT, PRODUCT P2: 10Rs = 5 ZOMATO PONTS, PRODUCT P3: 5Rs = 1 ZOMATO POINT]

SELECT userid,SUM(Points) "Total_Points" FROM
(SELECT s.userid,p.product_name,p.price,
CASE 
WHEN p.product_name = "p1" THEN ROUND(p.price/5,0)
WHEN p.product_name = "p2" THEN ROUND(p.price/10,0)*5
WHEN p.product_name = "p3" THEN ROUND(p.price/5,0)
END AS "Points"
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id) a
GROUP BY userid;

SELECT product_name,SUM(Points) AS "Total_Points" FROM
(SELECT s.userid,p.product_name,p.price,
CASE 
WHEN p.product_name = "p1" THEN ROUND(p.price/5,0)
WHEN p.product_name = "p2" THEN ROUND(p.price/10,0)*5
WHEN p.product_name = "p3" THEN ROUND(p.price/5,0)
END AS "Points"
FROM sales AS s
JOIN product AS p
ON s.product_id = p.product_id) a
GROUP BY  product_name
ORDER BY SUM(Points) DESC 
LIMIT 1;

-- FOR FIRST YEAR AFTER A CUSTOMER JOINS THE GOLD MEMBERSHIP,THEY EARN 5 ZOMATO POINTS FOR EVERY 10Rs SPENT.
-- FIND THE TOTAL POINTS EARNED BY EACH MEMBER 

SELECT userid,ROUND((price/10)*5,0) AS "Points_Earned" FROM
(SELECT s.*,g.gold_signup_date,p.product_name,p.price,
DATE_ADD(g.gold_signup_date,INTERVAL 1 YEAR) AS "One_Year_To_Membership" 
FROM sales AS s
JOIN goldusers_signup AS g
ON s.userid = g.userid
JOIN product AS p
ON s.product_id = p.product_id) a
WHERE created_date BETWEEN gold_signup_date AND One_Year_To_Membership;


-- RANK ALL THE TRANSACTIONS FOR GOLD MEMBERS AND MARK "NA" FOR REGULAR (NON GOLD MEMBERS)

SELECT *,
CASE 
WHEN Gold_users IS NOT NULL THEN RANK() OVER(PARTITION BY userid ORDER BY created_date DESC) ELSE "NA"
END AS "Rnk"
FROM
(SELECT s.*,g.userid AS "Gold_users" FROM sales AS s
LEFT JOIN goldusers_signup AS g
ON s.userid = g.userid AND s.created_date>=g.gold_signup_date ) a;
