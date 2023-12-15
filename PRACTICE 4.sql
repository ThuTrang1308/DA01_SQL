--EX 1
SELECT 
  SUM(CAST(device_type = 'laptop' AS int)) AS laptop_reviews,
  SUM(CAST(device_type IN ('phone','tablet') AS int)) AS mobile_reviews
FROM viewership;

--EX 2
select x, y, z,
case
when x + y > z and x + z > y and y + z > x then 'Yes'
else 'No'
end as triangle
from triangle


--EX 3
SELECT  
 ROUND( 100* SUM(CASE
    WHEN call_category IS NULL
 OR call_category = 'n/a' 
 THEN 1 END)
/COUNT(case_id), 1)AS call_percentage
 FROM callers;

--EX 4
select name from Customer
where referee_id != 2 or referee_id is null;

--EX 5
SELECT
    survived,
    SUM(CASE WHEN pclass = 1 THEN 1 ELSE 0 END) AS first_class,
    SUM(CASE WHEN pclass = 2 THEN 1 ELSE 0 END) AS second_class,
    SUM(CASE WHEN pclass = 3 THEN 1 ELSE 0 END) AS third_class
FROM titanic
GROUP BY survived
