## 📑 Table of Contents

1. [Overview](#overview)  
2. [Tools Used](#tools-used)  
3. [Raw Data](#raw-data)  
4. [Database Setup](#database-setup)  
5. [Create & Populate Tables](#create--populate-tables)  
   - [Suppliers Table](#suppliers-table)  
   - [Customers Table](#customers-table)  
   - [Products Table](#products-table)  
   - [Date Table](#date-table)  
   - [Fact Sales Table](#fact-sales-table)  
7. [Business Insights (SQL Queries)](#business-insights-sql-queries)
8. [Recommendations](#-recommendations)


# End-to-End Retail Data-Modelling Insights
This project demonstrates how to build a normalized SQL database for a retail company and extract actionable business insights using raw .csv files and MySQL. The insights generated helped optimised sales, supply chain efficiency, and customer retention strategies.

## Tools Used
 * MySQL 8.0
 * CSV Data Files (dim_suppliers.csv, dim_customers.csv, dim_products.csv, dim_dates.csv, fact_sales.csv)
 * SQL (DDL, DML, Aggregate Functions, Joins, Subqueries, Indexing)

## Database Setup
 ```sql
CREATE DATABASE Tech_Nova_Business_Analysis;
```


## Create & Populate Tables

### Suppliers Table 
```sql
CREATE TABLE Suppliers (
    supplier_id VARCHAR(10) PRIMARY KEY,
    supplier_name VARCHAR(40),
    Country CHAR(15),
    Reliability_score INT,
    Lead_time_days INT
);
```

#### Load Data (using MySQL + file from this repo)
```sql
LOAD DATA LOCAL INFILE 'dim_suppliers.csv'
INTO TABLE Suppliers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(supplier_id, supplier_name, Country, Reliability_score, Lead_time_days);
```

###  Customers Table
```sql
CREATE TABLE Customers (
    Customer_id VARCHAR(15) PRIMARY KEY,
    Customer_name CHAR(60),
    Country CHAR(60),
    City CHAR(60)
);
```

#### Load Data 
```sql
LOAD DATA LOCAL INFILE 'dim_customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Customer_id, Customer_name, Country, City);
```

### Products Table
```sql
CREATE TABLE Products (
    Product_id VARCHAR(15) PRIMARY KEY,
    Product_name CHAR(60),
    Category CHAR(60),
    Supplier_id VARCHAR(10),
    Price INT,
    FOREIGN KEY (Supplier_id) REFERENCES Suppliers(Supplier_id)
);
```

#### Load Data
```sql
LOAD DATA LOCAL INFILE 'dim_products.csv'
INTO TABLE Products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Product_id, Product_name, Category, Supplier_id, Price);
```


### Date Table
```sql
CREATE TABLE Date_ (
    Date_id INT,
    `Date` DATE
);
```
#### Delete Unwanted Column (Date_id)
```sql
ALTER TABLE Date_
DROP COLUMN Date_id;
```


#### Load Data
```sql
LOAD DATA LOCAL INFILE 'dim_dates.csv'
INTO TABLE Date_
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(`Date`);
```


#### Index For Faster Joins
```sql
CREATE INDEX idx_date ON Date_(`Date`);
```


### Fact Table – Sales
```sql
CREATE TABLE Fact_Sales (
    Order_id VARCHAR(15) PRIMARY KEY,
    Customer_id VARCHAR(15),
    Order_Date DATE,
    Product_id VARCHAR(15),
    Quantity INT,
    Unit_Price INT,
    Discount INT,
    Total_Amount INT,
    Status_ CHAR(20),
    Payment_Method CHAR(30),
    FOREIGN KEY (Customer_id) REFERENCES Customers(Customer_id),
    FOREIGN KEY (Product_id) REFERENCES Products(Product_id),
    FOREIGN KEY (Order_Date) REFERENCES Date_(`Date`)
);
```

#### Load Data 
```sql
LOAD DATA LOCAL INFILE 'fact_sales.csv'
INTO TABLE Fact_Sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_id, Customer_id, Order_Date, Product_id, Quantity, Unit_Price, Discount, Total_Amount, Status_, Payment_Method);
```


## Business Insights (SQL Queries)

### 1. Top 5 Revenue-Generating Products (Last 6 Months)

```sql
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
```

---

### 2. Most Loyal Customers (10+ Delivered Orders)

```sql
SELECT c.customer_name,
       COUNT(fs.order_id) AS Total_orders
FROM fact_sales fs
JOIN customers c ON c.Customer_id = fs.customer_id
WHERE fs.Status_ = 'Delivered'
GROUP BY c.Customer_name
HAVING Total_orders >= 10
ORDER BY Total_orders DESC;
```

---

### 3. Month with Highest Sales Volume & Revenue

```sql
SELECT fs.Order_Date,
       DATE_FORMAT(fs.order_date, '%Y-%m') AS Sales_Month,
       SUM(fs.Quantity) AS Sales_Volume,
       SUM(fs.Total_Amount) AS Total_Revenue
FROM Fact_Sales fs
WHERE fs.Status_ = 'Delivered'
GROUP BY fs.order_date
ORDER BY Total_Revenue DESC
LIMIT 1;
```

---

### 4. Suppliers with Low Reliability & High Lead Times

```sql
SELECT Sp.Supplier_name,
       Sp.Reliability_Score,
       Sp.Lead_time_days
FROM Suppliers Sp
ORDER BY Sp.Reliability_Score ASC, Sp.Lead_time_days DESC;
```

---

### 5. Most Popular Payment Method for High-Value Orders (>1000)

```sql
SELECT fs.Payment_Method, 
       COUNT(*) AS Number_of_Orders,
       SUM(fs.Total_Amount) AS Total_Value
FROM fact_sales fs
WHERE fs.Status_ = 'Delivered'
GROUP BY fs.Payment_Method
HAVING Total_Value > 1000
ORDER BY Total_Value DESC;
```

## Recommendations

Based on the SQL analysis conducted in this project, the following business recommendations are proposed:

1. **Double Down on High-Performing Products**  
   Focus marketing and stock replenishment on the top 5 revenue-generating products identified over the last 6 months. These products are proven performers and likely to yield continued returns.

2. **Reward and Retain Loyal Customers**  
   Implement loyalty programs or exclusive offers for customers with 10+ delivered orders. These customers have demonstrated high engagement and should be prioritized for retention strategies.

3. **Plan Around Peak Sales Months**  
   The month with the highest sales volume and revenue indicates a strong seasonal trend. Leverage this insight for future inventory planning, marketing campaigns, and staffing.

4. **Reevaluate Low-Performing Suppliers**  
   Suppliers with low reliability scores and long lead times can negatively impact operations. Review contracts, explore alternatives, or set performance improvement targets.

5. **Streamline Popular Payment Methods**  
   Promote and optimize for the most commonly used payment methods among high-value transactions to improve customer experience and reduce cart abandonment.

