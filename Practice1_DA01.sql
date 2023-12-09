--BAITAP 1
select name from city
where population > 120000 and countrycode = 'USA' 

  --BAITAP 2
select * from city
where countrycode = 'JPN' ;  

--BAITAP 3
select city, state from station;

--BAITAP 4
SELECT DISTINCT city FROM station
WHERE city LIKE 'a%' OR city LIKE 'e%' OR city LIKE 'i%' OR city LIKE 'O%' OR city LIKE 'U%';
 
--BAITAP 5
 SELECT DISTINCT city FROM station
WHERE city LIKE '%a' OR city LIKE '%e' OR city LIKE '%i' OR city LIKE '%o' OR city LIKE '%u';

--BAITAP 6
SELECT DISTINCT city FROM station
WHERE city NOT like 'a%' and NOT city like 'e%' and NOT city like 'i%' and NOT city like 'o%' and NOT city like 'u%' ;

--BAITAP 7
select name from Employee
order by name ;

--BAITAP 8
select name from  Employee
where salary > 2000 AND months < 10
order by Employee_id ASC ;

  --BAITAP 9
select product_id from products
WHERE low_fats ='Y' AND recyclable ='Y' ;
  
--BAITAP 10
select name from Customer
where referee_id != 2 or referee_id is null;

--BAITAP 11
select name, population, area from world
where area >= 3000000 or population >= 25000000 ;

--BAITAP 12
select distinct author_id as id from views
where viewer_id = author_id 
order by author_id ASC ;

--BAITAP 13
SELECT part, assembly_step FROM parts_assembly
WHERE finish_date is null;

--BAITAP 14
select * from lyft_drivers
where yearly_salary <= 30000 or yearly_salary>= 70000 ;

--BAITAP 15
select advertising_channel from uber_advertising
where year = 2019 
and (money_spent > 100000) ;
