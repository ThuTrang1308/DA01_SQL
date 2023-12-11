-- Ex1
select distinct city from station
where id%2 = 0

-- Ex2
select count(city) - count(distinct city) from station

-- Ex4
SELECT 
ROUND(CAST(SUM(item_count * order_occurrences) / SUM(order_occurrences) AS DECIMAL),1) AS MIN 
FROM items_per_order;

-- Ex5
SELECT candidate_id FROM candidates
WHERE Skill IN ('Python', 'Tableau', 'PostgreSQL')
group by candidate_id 
HAVING COUNT(skill) = 3

-- Ex6
SELECT user_id,
DATE(MAX(post_date)) - DATE(MIN(post_date)) as day_between
FROM posts
WHERE (post_date >='2021-01-01' AND post_date < '2022-01-01')
GROUP BY user_id
HAVING COUNT(post_id) >= 2

-- Ex7
SELECT card_name,
MAX(issued_amount) - MIN(issued_amount) AS DIFFERENCE
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY MAX(issued_amount) - MIN(issued_amount) DESC

-- Ex8
SELECT manufacturer,
COUNT(drug) AS drug_count,
ABS (SUM(cogs - total_sales))  AS total_loss
FROM pharmacy_sales
WHERE total_sales < cogs
GROUP BY manufacturer
ORDER BY ABS (SUM(cogs - total_sales)) DESC

-- Ex9
select * from cinema
where id%2 != 0 and description != 'boring' 
order by rating desc

-- Ex10
select teacher_id,
count(distinct subject_id ) as cnt
from teacher
group by teacher_id
having teacher_id

-- Ex11
select user_id,
count(distinct follower_id ) as  followers_count
from Followers 
group by user_id
order by user_id 

-- Ex12
select class
from Courses
group by class
having count(student) >= 5
