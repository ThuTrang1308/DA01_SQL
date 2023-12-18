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

Câu hỏi 1:
Question 1:
Level: Basic
Topic: DISTINCT

Task: Tạo danh sách tất cả chi phí thay thế (replacement costs )  khác nhau của các film.

Question: Chi phí thay thế thấp nhất là bao nhiêu?
Answer: 9.99

select distinct replacement_cost,film_id, title
from film
order by replacement_cost asc

Question 2:
Level: Intermediate
Topic: CASE + GROUP BY
Task: Viết một truy vấn cung cấp cái nhìn tổng quan về số lượng phim có chi phí thay thế trong các phạm vi chi phí sau
1.	low: 9.99 - 19.99
2.	medium: 20.00 - 24.99
3.	high: 25.00 - 29.99
Question: Có bao nhiêu phim có chi phí thay thế thuộc nhóm “low”?
Answer: 514

  select 
case 
 when replacement_cost between 9.99 and 19.99 then 'low'
 when replacement_cost between 20 and 24.99 then 'medium'
 when replacement_cost between 25 and 29.99 then 'high'
end catagory,
count(*) as so_luong
from film
group by catagory

  Question 3:
Level: c
Topic: JOIN
Task: Tạo danh sách các film_title  bao gồm tiêu đề (title), độ dài (length) và tên danh mục (category_name) được sắp xếp theo độ dài giảm dần. Lọc kết quả để chỉ các phim trong danh mục 'Drama' hoặc 'Sports'.
Question: Phim dài nhất thuộc thể loại nào và dài bao nhiêu?
Answer: Sports : 184

  select c.title as film_title, c.length, a.name
from category as a
join public.film_category as b on a.category_id = b.category_id
join public.film as c on c. film_id = b.film_id
where name = 'Drama' or name = 'Sports'
order by length desc

  Question 4:
Level: Intermediate
Topic: JOIN & GROUP BY
Task: Đưa ra cái nhìn tổng quan về số lượng phim (tilte) trong mỗi danh mục (category).
Question:Thể loại danh mục nào là phổ biến nhất trong số các bộ phim?
Answer: Sports :74 titles

select count(c.title) as titles, a.name
from category as a
join public.film_category as b on a.category_id = b.category_id
join public.film as c on c. film_id = b.film_id
group by a.name
order by titles desc

  Question 5:
Level: Intermediate
Topic: JOIN & GROUP BY
Task:Đưa ra cái nhìn tổng quan về họ và tên của các diễn viên cũng như số lượng phim họ tham gia.
Question: Diễn viên nào đóng nhiều phim nhất?
Answer: Susan Davis : 54 movies

select   a.first_name, a.last_name, count (b.film_id) as so_luong
from actor as a 
join public.film_actor as b on a.actor_id = b.actor_id
group by a.first_name, a.last_name
order by so_luong desc

  Question 6:
Level: Intermediate
Topic: LEFT JOIN & FILTERING
Task: Tìm các địa chỉ không liên quan đến bất kỳ khách hàng nào.
Question: Có bao nhiêu địa chỉ như vậy?
Answer: 4
select b.customer_id, count(a.address) as DIA_CHI_RONG
from address as a
left join customer as b on a.address_id = b.address_id
where b.customer_id is null
group by b.customer_id

  Question 7:
Level: Intermediate
Topic: JOIN & GROUP BY
Task: Danh sách các thành phố và doanh thu tương ừng trên từng thành phố 
Question:Thành phố nào đạt doanh thu cao nhất?
Answer: Cape Coral : 221.55
select sum(a.amount) as doanh_thu, b.address_id, d.city
from payment as a
join public.customer as b on a.customer_id = b.customer_id
join public.address as c on b.address_id = c.address_id
join public.city as d on d.city_id = c.city_id
group by b.address_id, d.city
order by doanh_thu desc

  Question 8:
Level: Intermediate 
Topic: JOIN & GROUP BY
Task: Tạo danh sách trả ra 2 cột dữ liệu: 
-	cột 1: thông tin thành phố và đất nước ( format: “city, country")
-	cột 2: doanh thu tương ứng với cột 1
Question: thành phố của đất nước nào đat doanh thu cao nhất
Answer: United States, Tallahassee : 50.85.

SELECT
d.city || ','||' ' || e.country AS CITY_COUNTRY, sum(a.amount) as doanh_thu
from payment as a
join public.customer as b on a.customer_id = b.customer_id
join public.address as c on b.address_id = c.address_id
join public.city as d on d.city_id = c.city_id
join public.country as e on e.country_id = d.country_id
group by b.address_id, d.city, e.country
ORDER BY doanh_thu DESC
