--ex1
WITH company AS
(SELECT
  company_id
FROM job_listings
GROUP BY company_id, title, description
HAVING COUNT(*) > 1)
SELECT COUNT(*) FROM company

--ex2
with cte1 as 
(select category, product, sum(spend)
from product_spend
where category = 'appliance'
and transaction_date BETWEEN '2022-01-01' AND '2023-01-01' 
group by 1,2
order by 3 desc
limit 2),
cte2 as
(select category, product, sum(spend)
from product_spend
where category = 'electronics'
and  transaction_date BETWEEN '2022-01-01' AND '2023-01-01'
group by 1,2
order by 3 desc
limit 2)
select * from cte1 
UNION all select * from cte2

--ex3
SELECT COUNT(members) AS member_count
FROM
(SELECT policy_holder_id AS members,
  COUNT(case_id) AS calls
FROM callers
GROUP BY policy_holder_id
HAVING COUNT(case_id)>=3) AS member_count

--ex4
select a.page_id from pages as a
left join page_likes  as b 
on a.page_id = b.page_id
where liked_date is null
ORDER BY page_id asc

--ex5
WITH cte AS
(SELECT  user_id	from user_actions 
where EXTRACT(month from event_date) in (6,7) 
and EXTRACT(year from event_date) = 2022 
GROUP BY user_id 
having count(DISTINCT EXTRACT(month from event_date)) = 2)

SELECT 7 as month , count(*) as number_of_user 
from cte 

--ex6
select DATE_FORMAT(trans_date, '%Y-%m') AS month,
country,
count(id) as trans_count,
sum(case when state = "approved" then 1 else 0 end) as approved_count,
sum(amount) as trans_total_amount,
sum(case when state = "approved" then amount else 0 end) as approved_total_amount
from Transactions
group by DATE_FORMAT(trans_date, '%Y-%m'), country

--ex7
SELECT product_id, year AS first_year, quantity, price 
FROM sales
WHERE (product_id, year) IN (
    SELECT product_id, MIN(year) 
    FROM sales 
    GROUP BY product_id)

--ex8
SELECT  customer_id FROM Customer GROUP BY customer_id
HAVING COUNT(distinct product_key) = (SELECT COUNT(product_key) FROM Product)

  --ex9
select employee_id
from Employees
where salary < 30000 and manager_id not in (select employee_id from Employees)
order by employee_id asc

--ex10
WITH a AS (
  SELECT company_id
  FROM job_listings
  GROUP BY company_id, title, description
  HAVING COUNT(*) > 1)
SELECT COUNT(*) AS duplicate_companies
FROM a

--ex11
(SELECT name AS results
FROM MovieRating JOIN Users USING(user_id)
GROUP BY name
ORDER BY COUNT(*) DESC, name
LIMIT 1)
UNION ALL
(SELECT title AS results
FROM MovieRating JOIN Movies USING(movie_id)
WHERE EXTRACT(YEAR_MONTH FROM created_at) = 202002
GROUP BY title
ORDER BY AVG(rating) DESC, title
LIMIT 1)

--ex12
SELECT id, COUNT(*) AS num 
FROM (SELECT requester_id AS id FROM RequestAccepted
    UNION ALL
    SELECT accepter_id FROM RequestAccepted) AS friends_count
GROUP BY id
ORDER BY num DESC 
LIMIT 1
