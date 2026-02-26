--  Importing Fact_Sales Table

CREATE TABLE Fact_Sales(
ProductKey INT,	
OrderDateKey INT,	
DueDateKey INT,	
ShipDateKey INT,	
CustomerKey INT,	
PromotionKey INT,	
CurrencyKey INT,	
SalesTerritoryKey INT,	
SalesOrderNumber VARCHAR(60),	
SalesOrderLineNumber INT,	
RevisionNumber INT,	
OrderQuantity INT,	
UnitPrice DOUBLE,	
ExtendedAmount DOUBLE, 
UnitPriceDiscountPct INT,	
DiscountAmount INT,	
ProductStandardCost DOUBLE,	
TotalProductCost DOUBLE,	
SalesAmount DOUBLE,	
TaxAmt DOUBLE,	
Freight DOUBLE,	
OrderDate Date,	
DueDate Date,	
ShipDate Date,
Year Int,
Month INT,	
MonthName VARCHAR(60),	
Quarter VARCHAR(10),	
YearMonth VARCHAR(50),	
WeekDayNo INT,	
WeekDay VARCHAR(60),	
FinancialMth INT,	
FinancialQtr VARCHAR(40)
);

SELECT @@secure_file_priv;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Project.csv' 
INTO TABLE Fact_Sales 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Describe fact_sales;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   Importing Customers Table

Create Table Customers(
CustomerKey	INT,
GeographyKey INT,	
CustomerAlternateKey VARCHAR(100),	
Title VARCHAR(100),	FirstName VARCHAR(100),	
MiddleName VARCHAR(100),	
LastName VARCHAR(100),	
NameStyle VARCHAR(50),	
BirthDate Date,	
MaritalStatus VARCHAR(100),	
Suffix VARCHAR(100),	
Gender VARCHAR(100),	
EmailAddress VARCHAR(100),	
YearlyIncome INT,	
TotalChildren INT,	
NumberChildrenAtHome INT,	
EnglishEducation VARCHAR(200),	
SpanishEducation VARCHAR(200),	
FrenchEducation VARCHAR(200),	
EnglishOccupation VARCHAR(200),	
SpanishOccupation VARCHAR(200),	
FrenchOccupation VARCHAR(200),	
HouseOwnerFlag INT,	
NumberCarsOwned	INT,
AddressLine1 VARCHAR(200),	
AddressLine2 VARCHAR(200),	
Phone VARCHAR(200),	
DateFirstPurchase Date,	
CommuteDistance VARCHAR(100),	
CustomerFullName VARCHAR(200));



LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customers.csv' 
INTO TABLE Customers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Describe Customers;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                   Queries
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
    YEAR(OrderDate)           AS year,
    MONTH(OrderDate)          AS month_no,
    MONTHNAME(OrderDate)      AS month_name,
    WEEKDAY(OrderDate) + 1    AS weekday_no,  
    DAYNAME(OrderDate)        AS weekday_name,
     CONCAT('Q', QUARTER(OrderDate)) AS Quarterr
FROM fact_sales ;

--  Financial Month

SELECT
    OrderDate,
    MONTHNAME(OrderDate) AS month,
    CASE
        WHEN MONTH(OrderDate) >= 4
            THEN MONTH(OrderDate) - 3
        ELSE MONTH(OrderDate) + 9
    END AS fin_month_no
FROM fact_sales;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 SELECT Sum(SalesAmount) FROM fact_sales;
 -- --------------------------------------------------------------------------------------------------------------------------------------------------
 
 SELECT SUM(TotalProductCost*OrderQuantity) as Production_Cost From fact_sales;
 
 -- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT distinct COUNT(customerKey) as Total_Customers FROM Customers;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT COUNT(orderquantity) Total_Quantities_Sold FROM fact_sales;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   Create a table for month and sales (provide the Year as filter to select a particular Year)

-- --->  I Have done this Using Stored Procedure

-- Only Year As Filter
call project.Year_Filter('2010,2011');

-- ----> Query I have written in Stored Procedure For Year Filter

/* CREATE DEFINER=`root`@`localhost` PROCEDURE `Year_Filter`(IN years_list VARCHAR(50))
BEGIN

SELECT Month,MonthName,sum(SalesAmount) FROM Fact_Sales 
where (years_list IS NULL OR years_list = '' or FIND_IN_SET(Year, years_list)) GROUP BY  Month,MonthName order by Month;

END */
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Both Year And Region As Filter
call project.Year_Region('2012', 'Canada');

-- ----> Query I have written in Stored Procedure For Year And Region Filter

/* CREATE DEFINER=`root`@`localhost` PROCEDURE `Year_Region`(IN years_list Varchar(50),IN Reg_list Varchar(50))
BEGIN

SELECT Month,MonthName,sum(SalesAmount) FROM Fact_Sales fs JOIN dimsalesterritory ds ON fs.SalesTerritoryKey = ds.SalesTerritoryKey 
where (years_list IS NULL OR years_list = '' or FIND_IN_SET(Year, years_list))
 AND (Reg_list IS NULL OR Reg_list = '' or FIND_IN_SET(SalesTerritoryRegion,Reg_list))
GROUP BY  Month,MonthName order by Month ;

END  */

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   Query to show yearwise Sales

SELECT Year,SUM(SalesAmount) FROM Fact_Sales GROUP BY Year ORDER BY Year;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Query to show Quarterwise sales

SELECT Quarter,SUM(SalesAmount) FROM Fact_Sales GROUP BY Quarter with rollup ORDER BY Quarter;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--    Query to show Salesamount and Productioncost together

SELECT Month,MonthName,sum(SalesAmount) as Sales,SUM(Totalproductcost) as Production_Cost FROM Fact_Sales 
GROUP BY  Month,MonthName order by Month;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Query to show Region Wise Sales

SELECT SalesTerritoryRegion,SUM(SalesAmount) as Sales FROM fact_sales fs JOIN dimsalesterritory st 
ON fs.SalesTerritoryKey = st.SalesTerritoryKey GROUP BY SalesTerritoryRegion;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Query to show Top 5 Customers By Sales

SELECT CustomerFullName,SUM(SalesAmount) as Sales FROM fact_sales fs JOIN Customers c ON 
fs.CustomerKey=c.CustomerKey GROUP BY CustomerFullName ORDER BY Sales DESC LIMIT 5;


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------









































































--                                     dimsalesterritory and Fact_Sales KEYS

SELECT * FROM dimsalesterritory;

DESCRIBE dimsalesterritory;

ALTER TABLE dimsalesterritory
RENAME COLUMN ï»¿SalesTerritoryKey TO SalesTerritoryKey;

ALTER TABLE dimsalesterritory
ADD CONSTRAINT pk PRIMARY KEY (SalesTerritoryKey);

ALTER TABLE fact_sales
ADD CONSTRAINT fk
FOREIGN KEY (SalesTerritoryKey)
REFERENCES dimsalesterritory(SalesTerritoryKey);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                Customers and Fact_Sales KEYS

ALTER TABLE Customers
ADD CONSTRAINT pk PRIMARY KEY (CustomerKey);

ALTER TABLE fact_sales
ADD CONSTRAINT fkk
FOREIGN KEY (CustomerKey)
REFERENCES Customers(CustomerKey);







