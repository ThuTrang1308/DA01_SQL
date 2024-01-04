--1.Tạo ra 1 dataset:
WITH BANG_1 AS( SELECT product_id,status,  FORMAT_DATE('%Y-%m', DATE (created_at)) as month,  FORMAT_DATE('%Y', DATE (created_at)) as year
FROM bigquery-public-data.thelook_ecommerce.order_items)
, BANG_2 AS(
SELECT product_id,category, a.sale_price as revenue, a.order_id as TPO,b.cost
FROM bigquery-public-data.thelook_ecommerce.order_items AS a
JOIN bigquery-public-data.thelook_ecommerce.products AS b
ON a.product_id=b.id)

 SELECT  a.month,a.year, b.category AS Product_category, round(sum(revenue),2) as TPV,
ROUND((round(sum(revenue),2) - LAG( round(sum(revenue),2)) OVER (PARTITION BY category ORDER BY month)) / LAG( round(sum(revenue),2)) OVER (PARTITION BY category ORDER BY month)*100,2) || "%"as Revenue_growth,
COUNT(TPO) as TPO,
ROUND(((COUNT(TPO) - LAG( COUNT(TPO)) OVER (PARTITION BY category ORDER BY month)) /  LAG( COUNT(TPO)) OVER (PARTITION BY category ORDER BY month))*100,2) || "%" AS Order_growth,
ROUND(SUM(cost),2) AS Total_cost,
 ROUND(SUM(revenue) - SUM(cost),2) AS Total_profit,
ROUND((SUM(revenue) - SUM(cost))/ SUM(cost),2) AS Profit_to_cost_ratio

FROM  BANG_1 as a
JOIN BANG_2 AS b 
ON a.product_id=b.product_id
WHERE month BETWEEN "2019-01" AND "2022-04" AND status = 'Complete'
group by 1,2,category
ORDER BY category,month DESC,year DESC


  
--2.Tạo retention cohort analysis
WITH purchase_index AS (
SELECT  user_id,amount,  FORMAT_DATE('%Y-%m', DATE (first_purchase_date)) AS cohort_month,created_at,
(EXTRACT(year FROM created_at ) - EXTRACT(year FROM first_purchase_date ))*12 
+ (EXTRACT(month FROM created_at ) - EXTRACT(month FROM first_purchase_date )) + 1 as index FROM 
(SELECT user_id, ROUND(sale_price,2) AS amount,
MIN(created_at) OVER (PARTITION BY user_id) AS first_purchase_date,
created_at
FROM bigquery-public-data.thelook_ecommerce.order_items) )

,cohort_date AS (
SELECT cohort_month,
index,
COUNT(DISTINCT user_id ) AS COUNT,
ROUND(SUM(amount),2) AS revenue

FROM purchase_index
GROUP BY  cohort_month,index
ORDER BY index)
--COHORT CHART
, CUSTOMER_COHORT AS (
SELECT cohort_month,
SUM(CASE WHEN index = 1 THEN COUNT ELSE 0 END) AS t1,
SUM(CASE WHEN index = 2 THEN COUNT ELSE 0 END) AS t2,
SUM(CASE WHEN index = 3 THEN COUNT ELSE 0 END) AS t3,
SUM(CASE WHEN index = 4 THEN COUNT ELSE 0 END) AS t4
FROM cohort_date
GROUP BY cohort_month
ORDER BY cohort_month)
--RETENTION COHORT
SELECT cohort_month,
ROUND(100.00*t1/t1,2) || "%" as t1,
ROUND(100.00*t2/t1,2) || "%" as t2,
ROUND(100.00*t3/t1,2) || "%" as t3,
ROUND(100.00*t4/t1,2) || "%" as t4
FROM CUSTOMER_COHORT

--CHURN COHORT
SELECT cohort_month,
(100-ROUND(100.00*t1/t1,2)) || "%" as t1,
(100-ROUND(100.00*t2/t1,2)) || "%" as t2,
(100- ROUND(100.00*t3/t1,2)) || "%" as t3,
(100- ROUND(100.00*t4/t1,2)) || "%" as t4
FROM CUSTOMER_COHORT

-- visualize thêm 1 cohort analysis trên excel. LINK: https://docs.google.com/spreadsheets/d/1GR2cX5SU6rjr56VaXOjLXleUp_r5RhOl/edit#gid=804108180
-- đề xuất giúp cải thiện tình hình kinh doanh của công ty: Qua số lệu các năm có thể thấy tỉ lệ giữ chân khách của TheLook đã có 
sự tăng trưởng nhẹ. Tuy nhiên, tỉ lệ này vẫn rất thấp so với tỉ lệ khách hàng đã rời bỏ thương hiệu này( trung bình khoảng 90%).
Điều này khiến doanh thu của TheLook sụt giảm 1 cách trầm trọng mặc dù lượng khách hàng mới mỗi tháng của thương hiệu này có dấu hiệu tăng vượt trội. 
TheLook nên chú trọng hơn vào các chiến dịch Marketing đa nền tảng và tạo ra các chương trình khuyến mãi  cho các khách hàng thân thiết,  
tạo thêm các sản phẩm ưa chuộng, bắt trend phù hợp với tình hình của thị trường 
thời trang để có thể thu hút thêm nhiều khách hàng mới và có thể tăng thêm các khách hàng trung thành với thương hiệu này trong tương lai.





