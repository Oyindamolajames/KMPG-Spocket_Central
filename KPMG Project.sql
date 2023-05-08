--inspecting data
select *
from kpmg.Transactions

-- checking unique values
select distinct transaction_id from kpmg.Transactions
select distinct product_id from kpmg.Transactions
select distinct customer_id from kpmg.Transactions
select distinct transaction_date from kpmg.Transactions
select distinct online_order from kpmg.Transactions
select distinct order_status from kpmg.Transactions --nice on to plot
select distinct brand from kpmg.Transactions --nice one to plot
select distinct product_line from kpmg.Transactions --nice one to plot
select distinct product_class from kpmg.Transactions --nice to plot
select distinct product_size from kpmg.Transactions --nice to plot

--ANALYSIS

-- Sum of sales by the product lines
SELECT product_line, SUM(list_price) Revenue
from kpmg.Transactions
GROUP by product_line
ORDER BY 2 desc
--The standard product line  15340723.81 in revenue out-performed 
--all others by a huge margin, Mountain product line fall short with revenue of 262541.56

--REVENUE BY PRODUCT CLASS
SELECT product_class, SUM(list_price) Revenue
from kpmg.Transactions
GROUP by product_class
ORDER BY 2 desc

-- Medium came in as the top performing product class with 15621698.760000339 in Revenue

--REVENUE BY PRODUCT SIZE 
SELECT product_size, SUM(list_price) Revenue
from kpmg.Transactions
GROUP by product_size
ORDER BY 2 desc

--REVENUE BY BRAND
SELECT brand, SUM(list_price) Revenue
from kpmg.Transactions
GROUP by brand
ORDER BY 2 desc

--REVENUE BY PRODUCT DETAILS
SELECT brand, product_class,  COUNT(transaction_id) Quantity_Sold,SUM(list_price) Revenue
from kpmg.Transactions
GROUP by  brand, product_class
ORDER BY 4 desc

--WHO IS OUR BEST CUSTOMER?
-- USING RFM ANALYSIS FOR CUSTOMER SEGMENTATION

DROP TABLE IF EXISTS #RFM;
WITH RFM AS
(
    SELECT
        customer_id,
        MAX(transaction_date) Last_order_date,
        (select MAX(transaction_date) from kpmg.Transactions) Max_Transaction_Date,
        DATEDIFF(DD,MAX(transaction_date),(select MAX(transaction_date) from kpmg.Transactions)) Recency,
        COUNT(transaction_id) Frequency,
        SUM(list_price) MonetaryValue,
        AVG(list_price)AvgMonetaryValue
    FROM kpmg.Transactions
    GROUP BY customer_id
),
rfm_calc AS
(
    SELECT r.*,
        NTILE(5) OVER (ORDER BY Recency) rfm_recency,
        NTILE(5) OVER (ORDER BY Frequency) rfm_frequency,
        NTILE(5) OVER (ORDER BY MonetaryValue) rfm_monetary

    FROM RFM r
)
SELECT 
    c.*, rfm_recency+rfm_frequency+rfm_monetary as rfm_cell,
    CAST(rfm_recency as varchar)+CAST(rfm_frequency as varchar)+CAST(rfm_monetary as varchar) rfm_score
INTO #rfm
from rfm_calc c

SELECT * FROM #rfm
--select customer_id, MAX(transaction_date) Last_Purchase, COUNT(transaction_id) Total_Transactions, SUM(list_price) Total_Purchased
--from kpmg.Transactions
--group by customer_id

