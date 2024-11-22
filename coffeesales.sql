use analysis;
-- DATA CLEANING 
SELECT 
    *
FROM
    coffeesales;
-- finding duplicates
SELECT 
    transaction_id,
    transaction_time,
    transaction_qty,
    store_id,
    store_location,
    product_id,
    unit_price,
    product_category,
    product_type,
    product_detail,
    COUNT(*)
FROM
    coffeesales
GROUP BY 
	 transaction_id,
    transaction_time,
    transaction_qty,
    store_id,
    store_location,
    product_id,
    unit_price,
    product_category,
    product_type,
    product_detail
HAVING COUNT(*) > 1;

-- finding null values (no null values were found)
SELECT 
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS transaction_id_nulls,
    SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS transaction_date_nulls,
    SUM(CASE WHEN transaction_time IS NULL THEN 1 ELSE 0 END) AS transaction_time_nulls,
    SUM(CASE WHEN transaction_qty IS NULL THEN 1 ELSE 0 END) AS transaction_qty_nulls,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS store_id_nulls,
    SUM(CASE WHEN store_location IS NULL THEN 1 ELSE 0 END) AS store_location_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price_nulls,
    SUM(CASE WHEN product_category IS NULL THEN 1 ELSE 0 END) AS product_category_nulls,
    SUM(CASE WHEN product_type IS NULL THEN 1 ELSE 0 END) AS product_type_nulls,
    SUM(CASE WHEN product_detail IS NULL THEN 1 ELSE 0 END) AS product_detail_nulls
FROM coffeesales;

-- EXPLORATORY DATA ANALYSIS
-- Sales and Revenue Insights
-- 1. what is the total revenue?
select round(sum(transaction_qty * unit_price)) as total_revenue
from coffeesales;

-- 2. what is the total sales
select sum(transaction_qty) as total_sales
from coffeesales;

-- 3. what is the total profit 
select round(sum(transaction_qty * unit_price) - sum(transaction_qty)) as total_profit
from coffeesales;

-- 4.What are the total sales and revenue over time?
SELECT 
    date_format(STR_TO_DATE(transaction_date, '%m/%d/%Y'),'%W') AS trans_day,
    date_format(STR_TO_DATE(transaction_date, '%m/%d/%Y'),'%M') AS trans_month,
    YEAR(STR_TO_DATE(transaction_date, '%m/%d/%Y')) AS trans_year,
    sum(transaction_date) as total_sales
FROM 
    coffeesales
group by 1,2,3;

-- 4. what is the total revenue by product category
select product_category, sum(transaction_qty * unit_price) as revenue
from coffeesales
group by 1;

-- 5. what is the most purchased product by category and the least purchased?
(SELECT 
    product_category, SUM(transaction_qty) AS total_sales
FROM
    coffeesales
GROUP BY product_category
ORDER BY total_sales DESC
LIMIT 1) UNION ALL (SELECT 
    product_category, SUM(transaction_qty) AS total_sales
FROM
    coffeesales
GROUP BY product_category
ORDER BY total_sales ASC
LIMIT 1);
 
-- 6. which store locations generate the most sales as most revenue?
select store_location, sum(transaction_qty) as total_sales, sum(transaction_qty * unit_price) as total_revenue
from coffeesales
group by 1
order by 3,2,1; 

-- 7. what are the most and least popular products
(select product_id, product_type, sum(transaction_qty) as total_sales
from coffeesales
group by 1,2
order by 3 DESC
LIMIT 1)
UNION ALL
(select product_id, product_type, sum(transaction_qty) as total_sales
from coffeesales
group by 1,2
order by 3 asc
LIMIT 1);

-- 8. what are the peak times for transactions in each store?
(select store_location, transaction_time, sum(transaction_qty) as total_sales
from coffeesales
where store_location = 'Astoria'
group by 1,2
order by 3 desc
limit 1)
union
(select store_location, transaction_time, sum(transaction_qty) as total_sales
from coffeesales
where store_location = "Hell's Kitchen"
group by 1,2
order by 3 desc
limit 1)
union
(select store_location, transaction_time, sum(transaction_qty) as total_sales
from coffeesales
where store_location = 'Lower Manhattan'
group by 1,2
order by 3 desc
limit 1);

-- 9. what is the average transaction quantity per order
select avg(transaction_qty)
from coffeesales;

-- 10. which product type contribute the most to revenue?
(select product_type, sum(transaction_qty * unit_price)
from coffeesales
group by 1
order by 2 DESC ,1
limit 5)
UNION ALL
(select product_type, sum(transaction_qty * unit_price)
from coffeesales
group by 1
order by 2,1
limit 5);

-- 11. which products have the highest unit price and do they sell well?
SELECT 
    product_type,
    unit_price,
    SUM(transaction_qty) AS total_sales_volume,
    (SELECT 
            (AVG(transaction_qty))
        FROM
            coffeesales) AS avg_trans_qty
FROM
    coffeesales
GROUP BY 1 , 2
ORDER BY 2 DESC , total_sales_volume DESC
LIMIT 10;

-- 12. how does price affect quantity demanded?
SELECT 
    product_type, 
    ROUND(AVG(unit_price)) AS unit_price,    
    SUM(transaction_qty) AS total_quantity
FROM 
    coffeesales
GROUP BY 
    product_type
ORDER BY 
    2 desc,product_type;

-- 13. which stores have the highest transaction quantity per product category
SELECT 
    store_location,
    product_category,
    SUM(transaction_qty) AS total_quantity
FROM
    coffeesales cs
GROUP BY store_location , product_category
HAVING SUM(transaction_qty) = (SELECT 
        MAX(total_qty)
    FROM
        (SELECT 
            store_location, SUM(transaction_qty) AS total_qty
        FROM
            coffeesales
        WHERE
            product_category = cs.product_category
        GROUP BY store_location) AS subquery)
ORDER BY total_quantity DESC;

-- 14. whats the average time a transaction occurs?
select avg(transaction_time)
from coffeesales;

-- 15. are certain product categories only popular in certian locations?
SELECT 
    store_location, 
    product_category,   
    SUM(transaction_qty) AS total_quantity_sold
FROM 
    coffeesales
GROUP BY 
    store_location, product_category
ORDER BY 
    store_location, total_quantity_sold DESC;

-- 16. what is the average revenue per transaction in each location
SELECT 
    store_location, 
    AVG(unit_price * transaction_qty) AS avg_revenue_per_transaction
FROM 
    coffeesales
GROUP BY 
    store_location
ORDER BY 
    avg_revenue_per_transaction DESC;
    
-- 17. how often do customers make bulk purchases
SELECT 
    CASE
        WHEN transaction_qty <= 2 THEN '1-2'
        WHEN transaction_qty <= 4 THEN '3-4'
        WHEN transaction_qty <= 6 THEN '5-6'
        WHEN transaction_qty <= 8 THEN '7-8'
        ELSE '9-10' 
    END AS quantity_range,
    COUNT(*) AS transaction_count
FROM 
    coffeesales
GROUP BY 
    quantity_range
ORDER BY 
    transaction_count DESC;
    
-- 18. are there any seasonal trends in customer purchasing behavior?
select date_format(str_to_date(transaction_date,'%m/%d/%Y' ),'%M') as months, SUM(transaction_qty) AS total_transactions
from coffeesales
where transaction_date is not null
group by 1
order by 1
;

-- 19. Is there a difference in transaction quantity or volume on weekends versus weekdays?
SELECT 
    sum(transaction_qty), 
    date_format(STR_TO_DATE(transaction_date, '%m/%d/%Y'),'%W') AS trans_day
FROM 
    coffeesales
group by 2
order by 1;	






