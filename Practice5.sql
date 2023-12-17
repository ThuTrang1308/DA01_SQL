--ex1: 
SELECT country.continent, floor(avg(city.population)) 
FROM city inner join country 
ON city.countrycode= country.code 
GROUP BY country.continent;

--ex2: 
SELECT 
ROUND(SUM(CASE WHEN t.signup_action = 'Confirmed' THEN 1 ELSE 0 END)*1.0 / COUNT(t.signup_action),2)
FROM emails e LEFT JOIN texts t  
ON e.email_id  = t.email_id
WHERE 
  e.email_id IS NOT NULL

--ex3: 
SELECT age_bucket,
ROUND(
SUM(case when activity_type = 'send' then time_spent else 0 end)*100.0/
(SUM(case when activity_type = 'open' then time_spent else 0 end) + 
SUM(case when activity_type = 'send' then time_spent else 0 end))
,2)
as send_perc,
ROUND(SUM(case when activity_type = 'open' then time_spent else 0 end)*100.0/(SUM(case when activity_type = 'open' then time_spent else 0 end) + 
SUM(case when activity_type = 'send' then time_spent else 0 end))
,2) as open_perc
from activities
join age_breakdown
on age_breakdown.user_id = activities.user_id
GROUP BY age_bucket


--ex4: 
SELECT a.customer_id
FROM customer_contracts as a
JOIN products as b ON a.product_id = b.product_id
GROUP BY a.customer_id
HAVING 
SUM(CASE WHEN b.product_category = 'Analytics' THEN 1 ELSE 0 END) >=1 AND
SUM(CASE WHEN b.product_category = 'Containers' THEN 1 ELSE 0 END) >= 1 AND
SUM(CASE WHEN b.product_category = 'Compute' THEN 1 ELSE 0 END) >=1

--ex5: 
select em2.employee_id, em2.name,
count(*) as reports_count,
round(avg(em1.age)) as average_age
from employees em1
inner join employees em2 
on em1.reports_to = em2.employee_id 
group by em2.employee_id, em2.name
order by em2.employee_id

  --ex6: 
select a.product_name,
 sum(b.unit) as unit
from Products as a
inner join Orders as b
on a.product_id = b.product_id
where b.order_date between '2020-02-01' and '2020-02-29'
group by a.product_name
having  unit >= 100;

--ex7: 
SELECT pg.page_id 
FROM pages pg
LEFT JOIN page_likes AS pgl ON pg.page_id = pgl.page_id
WHERE liked_date IS NULL
ORDER BY pg.page_id ASC
