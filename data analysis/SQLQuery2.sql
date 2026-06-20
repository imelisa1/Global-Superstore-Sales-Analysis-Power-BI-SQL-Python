USE SALESDB
SELECT TOP 100 * FROM SALES;

EXEC sp_help sales; -- Kolonların veri tiplerini görmek için

UPDATE SALES SET Order_Date = CONVERT(varchar(10), TRY_CONVERT(date, Order_Date, 105), 23); 
ALTER TABLE sales ALTER COLUMN Order_Date DATE NOT NULL 

UPDATE SALES SET Ship_Date = CONVERT(varchar(10), TRY_CONVERT(date, Ship_Date, 105), 23); 
ALTER TABLE sales ALTER COLUMN Ship_Date DATE NOT NULL; 

-- Burada text ten date formatına dönüştürürken 105 formatı = dd-MM-yyyy 23 formatında = yyyy-MM-dd değitiriyoruz ki sql hata vermesin.
-- Sonra textten tarih dönüşümü yapıyoruz.

ALTER TABLE SALES DROP COLUMN Postal_Code -- postal_code kolonunu kaldırıyorum, çok null var

ALTER TABLE SALES
ALTER COLUMN Sales DECIMAL(18,3) NOT NULL; -- Sales kolonunu decimal yapıyoruz.

ALTER TABLE SALES ALTER COLUMN Quantity TINYINT NOT NULL -- Quantity kolonunu int yaptık

ALTER TABLE sales
ALTER COLUMN Discount DECIMAL(6,4) NOT NULL; -- discount kolonunu güncelledik (p,s) p (precision) = toplam basamak sayısı s (scale) = virgülden sonraki basamak sayısı 

ALTER TABLE sales ALTER COLUMN Profit DECIMAL(18,4) NOT NULL; -- profit kolonunu güncelliyorum

ALTER TABLE sales
ALTER COLUMN Shipping_Cost DECIMAL(18,2) NOT NULL; -- shipping_cost kolonunu güncelliyorum

-- ---------------------------------------------------------------------------------------------------
SELECT COUNT(*) AS TotalRows
FROM sales; -- toplam kayıt sayısı

-- tekrarlı row id var mı
SELECT Row_ID, COUNT(*) FROM SALES GROUP BY Row_ID HAVING COUNT(*)>1;

-- tekrarlı order id var mI
SELECT Order_ID,COUNT(*) AS Order_Count
FROM SALES
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY Order_Count DESC;

-- Boş kontrolü
SELECT COUNT(*)
FROM SALES
WHERE Category IS NULL;


-- Maaliyet kolonu oluşturalım

ALTER TABLE SALES ADD Estimated_Cost DECIMAL(18,4);

UPDATE SALES
SET Estimated_Cost = Sales - Profit;

-- Ülke bazında toplam satış ve toplam kar ve toplam maaliyet
SELECT
    Country,
    SUM(Sales) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    SUM(Estimated_Cost) as TotalCost
FROM SALES
GROUP BY Country
ORDER BY TotalProfit DESC;

-- Order ID lerde toplam tutar
SELECT
    Order_ID,
    SUM(Sales) AS Basket_Total
FROM SALES
GROUP BY Order_ID
ORDER BY Basket_Total DESC;

-- ülkelerde en çok satan ürün
SELECT
    Country,
    Product_Name,
    TotalSales
FROM (
    SELECT
        Country,
        Product_Name,
        SUM(Sales) AS TotalSales,
        ROW_NUMBER() OVER (
            PARTITION BY Country
            ORDER BY SUM(Sales) DESC
        ) AS rn
    FROM SALES
    GROUP BY Country, Product_Name
) AS T
WHERE rn = 1
ORDER BY Country;

-- en çok satan kategori
SELECT Category,
       SUM(Sales) AS TotalSales
FROM sales
GROUP BY Category
ORDER BY TotalSales DESC;

-- bölgelere göre satış

SELECT Region,
       SUM(Sales) AS TotalSales
FROM sales
GROUP BY Region
ORDER BY TotalSales DESC;

-- en değerli 10 müşteri
SELECT TOP 30
Customer_Name,
SUM(Sales) AS TotalSales,
Country
FROM sales
GROUP BY Customer_Name, Country
ORDER BY TotalSales DESC;

--Yıllara göre satış
SELECT
YEAR(Order_Date) AS OrderYear,
SUM(Sales) AS TotalSales
FROM sales
GROUP BY YEAR(Order_Date)
ORDER BY OrderYear;

--Ortalama teslimat günü
SELECT AVG(DATEDIFF(DAY, Order_Date, Ship_Date)) AS AvgShippingDays
FROM sales;

SELECT TOP 20
    Order_ID,
    Order_Date,
    Ship_Date,
    DATEDIFF(DAY, Order_Date, Ship_Date) AS ShippingDays
FROM SALES
WHERE DATEDIFF(DAY, Order_Date, Ship_Date) = 0;

-- Kar marjı
SELECT
    Country,
    SUM(Sales) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    ROUND((SUM(Profit) * 100.0) / NULLIF(SUM(Sales), 0), 2) AS ProfitMargin
FROM SALES
GROUP BY Country
ORDER BY ProfitMargin DESC;

SELECT *
FROM SALES;