--BT1:
--Thống kê tổng số lượng người mua và số lượng đơn hàng đã hoàn thành mỗi tháng ( Từ 1/2019-4/2022)
--Output: month_year ( yyyy-mm) , total_user, total_orde

WITH CTE AS(
SELECT order_id, user_id,status,created_at
FROM bigquery-public-data.thelook_ecommerce.orders
WHERE status = 'Complete')
, CTE2 AS 
(SELECT order_id, COUNT( user_id) AS  total_user, count(order_id) AS total_order
FROM bigquery-public-data.thelook_ecommerce.orders
GROUP BY user_id, order_id)
, CTE3 AS (
SELECT a.order_id, a.user_id, b.status, b.created_at,c.total_user, c.total_order
 FROM bigquery-public-data.thelook_ecommerce.orders as a
JOIN CTE AS b ON a.order_id= b.order_id
JOIN CTE2 AS c ON c.order_id= a.order_id
WHERE b.created_at BETWEEN "2019-01-01 00:00:00" AND "2022-05-01 00:00:00"
ORDER BY  b.created_at DESC)

SELECT sum(total_user) as total_user ,SUM( total_order) as total_order, 
cast(format_date('%Y-%m',created_at) as string) AS month_year 
FROM CTE3
GROUP BY month_year 
order by month_year  

--BT2:
-- Thống kê giá trị đơn hàng trung bình và tổng số người dùng khác nhau mỗi tháng( Từ 1/2019-4/2022)
--Output: month_year ( yyyy-mm), distinct_users, average_order_value

with cte as (
SELECT order_id, user_id,status, created_at  
FROM bigquery-public-data.thelook_ecommerce.orders
WHERE status = 'Complete')
, CTE2 AS 
(SELECT order_id, COUNT(DISTINCT user_id) AS  total_user, count(order_id) AS total_order, SUM(sale_price) as tong_so_tien
FROM bigquery-public-data.thelook_ecommerce.order_items
GROUP BY user_id, order_id)
,CTE3 AS (
SELECT a.order_id, a.user_id, b.status, b.created_at,c.total_user, c.total_order, c.tong_so_tien
 FROM bigquery-public-data.thelook_ecommerce.orders as a
JOIN CTE AS b ON a.order_id= b.order_id
JOIN CTE2 AS c ON c.order_id= a.order_id
WHERE b.created_at BETWEEN "2019-01-01 00:00:00" AND "2022-05-01 00:00:00"
ORDER BY  b.created_at DESC)

SELECT sum( total_user) as distinct_users, ROUND(SUM(tong_so_tien)/ SUM( total_order) ,2) AS average_order_value,
cast(format_date('%Y-%m',created_at) as string) AS month_year 
FROM CTE3
GROUP BY month_year 
order by month_year  

--BT3:
--Tìm các khách hàng có trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính ( Từ 1/2019-4/2022)
--Output: first_name, last_name, gender, age, tag (hiển thị youngest nếu trẻ tuổi nhất, oldest nếu lớn tuổi nhất)
--Hint: Sử dụng UNION các KH tuổi trẻ nhất với các KH tuổi trẻ nhất 
--tìm các KH tuổi trẻ nhất và gán tag ‘youngest’  
--tìm các KH tuổi trẻ nhất và gán tag ‘oldest’ 
--Insight là gì? (Trẻ nhất là bao nhiêu tuổi, số lượng bao nhiêu? Lớn nhất là bao nhiêu tuổi, số lượng bao nhiêu) 
--Note: Lưu output vào temp table rồi đếm số lượng tương ứng 

with cte1 as (
SELECT MIN(age) as min_age, MAX(age) as max_age FROM bigquery-public-data.thelook_ecommerce.users
WHERE gender='F' AND created_at BETWEEN "2019-01-01 00:00:00" AND "2022-05-01 00:00:00")
, cte2 as (
SELECT MIN(age) as min_age, MAX(age) as max_age FROM bigquery-public-data.thelook_ecommerce.users
WHERE gender='M' AND created_at BETWEEN "2019-01-01 00:00:00" AND "2022-05-01 00:00:00")
, cte3 as (
SELECT first_name,last_name,
age,gender FROM bigquery-public-data.thelook_ecommerce.users AS a
JOIN CTE1 AS b ON a.age=b.min_age or a.age=b.max_age
WHERE gender='F' AND created_at BETWEEN "2019-01-01 00:00:00" AND "2022-05-01 00:00:00"
UNION ALL
SELECT first_name,last_name,
age,gender FROM bigquery-public-data.thelook_ecommerce.users AS a
JOIN CTE2 AS c ON a.age=c.min_age or a.age=c.max_age
WHERE gender='M' AND created_at BETWEEN "2019-01-01 00:00:00" AND "2022-05-01 00:00:00")
,cte4 as (
SELECT *, CASE
WHEN age in (SELECT MIN(age) as min_age FROM bigquery-public-data.thelook_ecommerce.users
WHERE gender='F' AND created_at BETWEEN "2019-01-01 00:00:00" AND "2022-05-01 00:00:00") then'youngest'
WHEN age in (SELECT MIN(age) as min_age FROM bigquery-public-data.thelook_ecommerce.users
WHERE gender='M' AND created_at BETWEEN "2019-01-01 00:00:00" AND "2022-05-01 00:00:00") then 'youngest'
else "oldest"
end as tag
from cte3
group by age, gender,tag,first_name,last_name
 order by age)

 select count(*) as so_luong, age, gender
 from cte4
 group by gender, age
order by age

--BT4:
--Thống kê top 5 sản phẩm có lợi nhuận cao nhất từng tháng (xếp hạng cho từng sản phẩm). 
---Output: month_year ( yyyy-mm), product_id, product_name, sales, cost, profit, rank_per_month
--Hint: Sử dụng hàm dense_rank()

  WITH CTE AS(
SELECT product_id,status,created_at
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE status = 'Complete')
, CTE2 AS 
(SELECT product_id, name as product_name, ROUND(SUM(sale_price),2) AS sales, ROUND(SUM(cost),2) as cost,  ROUND((SUM(sale_price) - SUM(cost)),2) as profit
 FROM bigquery-public-data.thelook_ecommerce.order_items as a
JOIN  bigquery-public-data.thelook_ecommerce.products AS b
ON a.product_id=b.id
GROUP BY product_id,name
)
,CTE3 AS (
SELECT c.product_name, a.product_id, b.status, b.created_at,c.sales, c.cost, c.profit
 FROM bigquery-public-data.thelook_ecommerce.order_items as a
JOIN CTE AS b ON a.product_id= b.product_id
JOIN CTE2 AS c ON c.product_id= a.product_id
WHERE b.status = 'Complete')
,CTE4 AS (
SELECT product_id, product_name, ROUND(sum(sales),2) as total_sales ,ROUND(SUM( cost),2) as total_cost, ROUND(sum(sales)-SUM( cost),2) as profit,
cast(format_date('%Y-%m',created_at) as string) AS month_year 
FROM CTE3
GROUP BY month_year, product_name,product_id )
, CTE5 AS (
SELECT *, DENSE_RANK () OVER(PARTITION BY month_year ORDER BY month_year DESC, profit desc  ) AS rank_per_month FROM cte4)

SELECT * FROM CTE5
WHERE rank_per_month <= 5
ORDER BY month_year

--BT5:
--Thống kê tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng qua ( giả sử ngày hiện tại là 15/4/2022)
--Output: dates (yyyy-mm-dd), product_categories, revenue

WITH BANG_1 AS( SELECT product_id,status
FROM bigquery-public-data.thelook_ecommerce.order_items
)
, BANG_2 AS(
SELECT product_id,category, SUM(sale_price) as tong_doanh_thu , DATE(delivered_at) AS delivered_at
FROM bigquery-public-data.thelook_ecommerce.order_items AS a
JOIN bigquery-public-data.thelook_ecommerce.products AS b
ON a.product_id=b.id
GROUP BY delivered_at, category,product_id)
SELECT  b.category, round(sum(tong_doanh_thu),2) as revenue, LAG( delivered_at) OVER (PARTITION BY category ORDER BY delivered_at ) as dates FROM  BANG_1 as a
JOIN BANG_2 AS b 
ON a.product_id=b.product_id
WHERE delivered_at BETWEEN "2022-01-15" AND "2022-04-15" AND status = 'Complete'
group by category,delivered_at
order by category,dates
