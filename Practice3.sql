-- ex1
select name
from students
where marks > 75
order by right(name, 3), id

-- ex2
SELECT user_id, 
  CONCAT(UPPER(LEFT(name,1)),LOWER(RIGHT(name,LENGTH(name)-1))) AS name 
  FROM Users 
  RDER BY user_id

-- ex3
SELECT
  manufacturer, 
  CONCAT('$', ROUND(SUM(total_sales) / 1000000), ' million') AS sales
FROM pharmacy_sales 
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC, manufacturer
-- ex4
SELECT 
  EXTRACT(MONTH FROM submit_date) AS mth,
  product_id,
  ROUND(AVG(stars), 2) AS avg_stars
FROM reviews
GROUP BY 
  EXTRACT(MONTH FROM submit_date), 
  product_id
ORDER BY mth, product_id;

-- ex5
SELECT 
  sender_id,
  COUNT(message_id) AS count_messages
FROM messages
WHERE EXTRACT(MONTH FROM sent_date) = '8'
  AND EXTRACT(YEAR FROM sent_date) = '2022'
GROUP BY sender_id
ORDER BY count_messages DESC
LIMIT 2; 

-- ex6
SELECT tweet_id
FROM Tweets
WHERE CHAR_LENGTH(content) > 15;

-- ex7
select activity_date as day,
count(distinct user_id) as active_users 
from Activity 
where (activity_date > '2019-06-27' and activity_date <= '2019-07-27') 
group by activity_date;select activity_date as day,
count(distinct user_id) as active_users 
from Activity 
where (activity_date > '2019-06-27' and activity_date <= '2019-07-27') 
group by activity_date;


-- ex8
select 
count (id) as number_employee
from employees
WHERE EXTRACT (month from  joining_date) BETWEEN 1 and 7
and EXTRACT (month from  joining_date) = 2022


-- ex9
select position ('a' in first_name) from worker
where first_name = 'Amitah'

-- ex10
select substring(title, length(winery)+ 2, 4)
from winemag_p2
where country = 'Macedonia'



