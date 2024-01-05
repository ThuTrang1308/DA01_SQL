--1) Doanh thu theo từng ProductLine, Year  và DealSize?
---Output: PRODUCTLINE, YEAR_ID, DEALSIZE, REVENUE
select  DISTINCT PRODUCTLINE, YEAR_ID, DEALSIZE, SUM( sales)
OVER (PARTITION BY PRODUCTLINE, YEAR_ID, DEALSIZE  ) AS REVENUE
FROM sales_dataset_rfm_prj
WHERE STATUS = 'Shipped'
ORDER BY YEAR_ID,PRODUCTLINE


--2) Đâu là tháng có bán tốt nhất mỗi năm?
--Output: MONTH_ID, REVENUE, ORDER_NUMBER
SELECT distinct MONTH_ID, SUM(sales) OVER (PARTITION BY MONTH_ID ) AS REVENUE , count(ordernumber) over (partition by MONTH_ID ) as ORDER_NUMBER
from sales_dataset_rfm_prj
WHERE STATUS = 'Shipped'
order by MONTH_ID

--3) Product line nào được bán nhiều ở tháng 11?
--Output: MONTH_ID, REVENUE, ORDER_NUMBER
SELECT distinct MONTH_ID,ProductLine, SUM(sales) OVER (PARTITION BY MONTH_ID,ProductLine ) AS REVENUE , count(ordernumber) over (partition by MONTH_ID,ProductLine ) as ORDER_NUMBER
from sales_dataset_rfm_prj
WHERE STATUS = 'Shipped' and MONTH_ID = '11'

--4) Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? 
--Xếp hạng các các doanh thu đó theo từng năm.
--Output: YEAR_ID, PRODUCTLINE,REVENUE, RANK
WITH T1 AS (
select  DISTINCT PRODUCTLINE, YEAR_ID, SUM( sales)
OVER (PARTITION BY PRODUCTLINE, YEAR_ID  ) AS REVENUE,
country
FROM sales_dataset_rfm_prj
WHERE STATUS = 'Shipped' AND country = 'UK')

SELECT *,
RANK() OVER (ORDER BY  REVENUE DESC) FROM 
( SELECT PRODUCTLINE, YEAR_ID,REVENUE,
RANK () OVER (PARTITION BY YEAR_ID ORDER BY  REVENUE DESC) STT 
 FROM T1) AS A
WHERE STT='1'
ORDER BY YEAR_ID

--5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
--(sử dụng lại bảng customer_segment ở buổi học 23)
 -- Tim gia tri R-F-M:
SELECT * FROM public.sales_dataset_rfm_prj
 SELECT * FROM public.customer
 WITH B1 AS (
select a.customer_id, current_date - max(b.orderdate) as R, count(distinct b.ordernumber) as F,
sum(b.sales) as M
from customer a join sales_dataset_rfm_prj b
on a.city=b.city
group by a.customer_id)

--CHIA CAC GT TREN THANG DIEM TU 1-5:
, rfm_score as (
select customer_id,
ntile(5) over(order by R desc) as R_SCORE,
ntile(5) over(order by F ) as F_SCORE,
ntile(5) over(order by M desc) as M_SCORE
FROM B1)

--PHAN NHOM THEO 125 TO HOP R-F-M
,rfm_final as (
select customer_id,
cast (R_SCORE as varchar) || cast(F_SCORE as varchar) || cast(M_SCORE as varchar) as rfm_score
from rfm_score)

select segment,count(*) as count from (
select a.customer_id, b.segment from rfm_final as a
join segment_score as b 
on a.rfm_score= b.scores ) as t1
group by segment
order by count-
  --LINK EXCEL: https://docs.google.com/spreadsheets/d/10x4ewdrRiT7flPirCHebxKggFJYaw98h/edit#gid=1460009688
