CREATE Database Tech_Nova_Business_Analysis;

CREATE TABLE Suppliers (
supplier_id VARCHAR(10) PRIMARY KEY,
supplier_name VARCHAR (255),
Country CHAR (50),
Reliability_score INT,
Lead_time_days INT

);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_suppliers.csv'
INTO TABLE Suppliers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(supplier_id, supplier_name, Country, Reliability_score, Lead_time_days);

SELECT * FROM Suppliers

CREATE TABLE Customers (
Customer_id   VARCHAR (15) PRIMARY KEY,
Customer_name CHAR (60),
Country       CHAR (60),
City          CHAR (60)
); 

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Customer_id , Customer_name, Country, City);


CREATE TABLE Products (
Product_id    VARCHAR (15) PRIMARY KEY,
Product_name  CHAR (60),
Category      CHAR (60),
Supplier_id   VARCHAR (10),
Price INT,
FOREIGN KEY (Supplier_id) REFERENCES Suppliers (Supplier_id)
); 



LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_products 1(in).csv'
INTO TABLE Products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Product_id , Product_name, Category, Supplier_id, Price);

SELECT* FROM Products;

CREATE TABLE Date_ (
     Date_id INT,
    `Date` DATE  -- Use backticks to escape the reserved keyword
);

ALTER TABLE Date_
DROP COLUMN Date_id;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_dates(in).csv'
INTO TABLE Date_
IGNORE 1 ROWS 
(`Date`);


SELECT* FROM DATE_;
SELECT* FROM PRODUCTS


CREATE INDEX idx_date ON date_(date);


CREATE TABLE Fact_Sales(
Order_id       VARCHAR (15),
Customer_id    VARCHAR (15),
Order_Date     DATE,
Product_id     VARCHAR (15),
Quantity       INT,
Unit_Price     INT,
Discount       INT,
Total_Amount   INT,
Status_        CHAR (20),
Payment_Method CHAR (30),
FOREIGN KEY (Customer_id) REFERENCES Customers (Customer_id),
FOREIGN KEY (Product_id) REFERENCES Products (Product_id),
FOREIGN KEY (order_date) REFERENCES Date_(date)
);



LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_sales.csv'
INTO TABLE Fact_Sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_id, Customer_id, Order_Date, Product_id, Quantity, Unit_Price, Discount, Total_Amount, Status_, Payment_Method);


SHOW VARIABLES LIKE 'local_infile';

SHOW VARIABLES LIKE 'secure_file_priv';


-- IDENTIFYING THE TOP 6 REVENUE GENERATING PRODUCTS OVER THE LAST 6 MONTHS

SELECT
    p.product_name,
    SUM(fs.total_amount) AS Total_Revenue
FROM fact_sales fs
JOIN products p ON fs.product_id = p.product_id
WHERE fs.status_ = 'Delivered'
  AND fs.order_date >= DATE_SUB(
      (SELECT MAX(order_date) FROM fact_sales WHERE status_ = 'Delivered'), 
      INTERVAL 6 MONTH
  )
GROUP BY p.product_name
ORDER BY Total_Revenue DESC
LIMIT 5;


-- IDENTIFYING THE MOST LOYAL CUSTOMERS WITH MORE THAN 10 ORDERS
SELECT c.customer_name,
COUNT(fs.order_id) AS Total_orders
FROM fact_sales fs
JOIN customers C ON C.Customer_id = fs.customer_id
WHERE fs.Status_ = 'Delivered'
GROUP BY C.Customer_name
HAVING Total_orders >=10
ORDER BY Total_orders DESC;


-- IDENTIFYING THE MONTH WITH THE HIGHEST SALES VOLUME AND REVENUE
SELECT fs.Order_Date,
DATE_FORMAT (fs.order_date,  '%Y-%m') AS Sales_Month,
SUM(fs.Quantity)                      AS Sales_Volume,
SUM(fs.Total_Amount)                 AS Total_Revenue
FROM Fact_Sales fs
WHERE fs.Status_ = 'Delivered'
GROUP BY fs.order_date
ORDER BY Total_Revenue DESC
LIMIT 1;

-- IDENTIFYING SUPPLIERS WITH HIGH LEAD TIMES AND LOW RELIABILITY SCORES
SELECT Sp.Supplier_name,
	   Sp.Reliability_Score,
	   Sp.Lead_time_days
FROM Suppliers Sp
ORDER BY SP.Reliability_Score ASC, Sp.Lead_time_days DESC;

-- MOST POPULAR PAYMENT METHOD FOR HIGH-VALUE ORDERS (> $1,000)
SELECT fs.Payment_Method, 
       COUNT(*)              AS Number_of_Orders,
       SUM(fs.Total_Amount) AS Total_Value
FROM fact_sales fs
WHERE fs.Status_ = 'Delivered'
GROUP BY fs.Payment_Method
HAVING Total_Value >1000
ORDER BY Total_Value DESC;



