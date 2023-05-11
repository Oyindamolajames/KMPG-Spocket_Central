--DATASET

SELECT *
FROM kpmg.Transactions

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
        NTILE(4) OVER (ORDER BY Recency) rfm_recency,
        NTILE(4) OVER (ORDER BY Frequency) rfm_frequency,
        NTILE(4) OVER (ORDER BY MonetaryValue) rfm_monetary

    FROM RFM r
)
SELECT 
    c.*, rfm_recency+rfm_frequency+rfm_monetary as rfm_cell,
    CAST(rfm_recency as varchar)+CAST(rfm_frequency as varchar)+CAST(rfm_monetary as varchar) rfm_score
INTO #rfm
from rfm_calc c

SELECT *
from #rfm

SELECT customer_id, rfm_recency,rfm_frequency,rfm_monetary,rfm_score,
    case 
        when rfm_score in (444,443,434,433) then 'churned best customer' --they have transacted a lot and frequent but it has been a long time since last transaction
        when rfm_score in (421,422,423,424,434,432,433,431) then 'lost customer'
        when rfm_score in (342,332,341,331) then 'declining customer'
        when rfm_score in (344,343,334,333) then 'slipping best customer'--they are best customer that have not purchased in a while
        when rfm_score in (142,141,143,131,132,133,242,241,243,231,232,233) then 'active loyal customer' -- they have purchased recently, frequently, but have low monetary value
        when rfm_score in (112,111,113,114,211,213,214,212) then 'new customer' 
        when rfm_score in (144) then 'best customer'-- they have purchase recently and frequently, with high monetary value
        when rfm_score in (411,412,413,414,313,312,314,311) then 'one time customer'
        when rfm_score in (222,221,223,224) then 'Potential customer'
        else 'customer'
    end rfm_segment

FROM #rfm


