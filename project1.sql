--BT1:
select * from SALES_DATASET_RFM_PRJ

ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN priceeach TYPE numeric USING (trim(priceeach)::numeric)
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN sales TYPE numeric USING (trim(sales)::numeric)
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN ordernumber TYPE smallint USING (trim(ordernumber)::smallint)
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN quantityordered TYPE smallint USING (trim(quantityordered)::smallint);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN orderlinenumber TYPE smallint USING (trim(orderlinenumber)::smallint);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN orderlinenumber TYPE smallint USING (trim(orderlinenumber)::smallint);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN orderdate TYPE date USING (trim(orderdate)::date);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN status TYPE text USING (trim(status)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN productline TYPE text USING (trim(productline)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN msrp TYPE smallint USING (trim(msrp)::smallint);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN productcode TYPE text USING (trim(productcode)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN customername TYPE text USING (trim(customername)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN phone TYPE text USING (trim(phone)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN addressline1 TYPE text USING (trim(addressline1)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN addressline2 TYPE text USING (trim(addressline2)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN city TYPE text USING (trim(city)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN state TYPE text USING (trim(state)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN postalcode TYPE text USING (trim(postalcode)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN country TYPE text USING (trim(country)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN territory TYPE text USING (trim(territory)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN contactfullname TYPE text USING (trim(contactfullname)::text);
ALTER TABLE SALES_DATASET_RFM_PRJ ALTER COLUMN dealsize TYPE text USING (trim(dealsize)::text);


--BT2:
SELECT *
FROM sales_dataset_rfm_prj
WHERE COALESCE(ordernumber, quantityordered,priceeach,orderlinenumber,sales) IS NULL
AND COALESCE(orderdate) IS NULL

  -- BT3
 ---Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME:
 ALTER TABLE sales_dataset_rfm_prj
 ADD COLUMN contactlastname VARCHAR(30)
  ALTER TABLE sales_dataset_rfm_prj
 ADD COLUMN contactfirstname VARCHAR(30)
--- Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME:
UPDATE sales_dataset_rfm_prj
SET contactlastname = SUBSTRING(contactfullname,position('-' in contactfullname)+ 1)
UPDATE sales_dataset_rfm_prj
SET contactfirstname = SUBSTRING(contactfullname, 1, POSITION('-' IN contactfullname) - 1)

--- CHUẨN HÓA CONTACTLASTNAME, CONTACTFIRSTNAME:
UPDATE sales_dataset_rfm_prj
SET contactlastname = CONCAT(UPPER(LEFT(contactlastname,1)),
LOWER(RIGHT(contactlastname,LENGTH(contactlastname)-1)))

UPDATE sales_dataset_rfm_prj
SET contactfirstname = CONCAT(UPPER(LEFT(contactfirstname,1)),
LOWER(RIGHT(contactfirstname,LENGTH(contactfirstname)-1)))

--BT4: Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE 

  SELECT * FROM public.sales_dataset_rfm_prj
---Thêm cột QTR_ID, MONTH_ID, YEAR_ID
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN QTR_ID INT, ADD COLUMN MONTH_ID INT, ADD COLUMN YEAR_ID INT   

  ---lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE 
UPDATE sales_dataset_rfm_prj
SET QTR_ID = EXTRACT (QUARTER FROM orderdate) 

UPDATE sales_dataset_rfm_prj
SET MONTH_ID = EXTRACT (MONTH FROM orderdate) 

UPDATE sales_dataset_rfm_prj
SET YEAR_ID = EXTRACT (YEAR FROM orderdate)

--BT5: Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED 
--hãy chọn cách xử lý cho bản ghi đó (2 cách) , IQR= Q3-Q1=16, N= 2823, Q1= 27, Q3= 43, Q2=35, MIN=3, MAX=67
---- CÁCH 1: BOXPLOT
SELECT quantityordered FROM sales_dataset_rfm_prj
ORDER BY quantityordered ASC
-- outlier   
SELECT quantityordered 
FROM sales_dataset_rfm_prj
WHERE quantityordered NOT BETWEEN 3 AND 67
ORDER BY quantityordered 

-----CÁCH 2: Z-SCORE (quantityordered-avg)/ stddev
SELECT avg(quantityordered), 
stddev(quantityordered), 
FROM sales_dataset_rfm_prj

with cte1 as 
(SELECT quantityordered, 
(SELECT avg(quantityordered) FROM sales_dataset_rfm_prj) as avg,
(SELECT stddev(quantityordered) FROM sales_dataset_rfm_prj) as stddev
FROM sales_dataset_rfm_prj)

SELECT quantityordered, ((quantityordered-avg)/ stddev) AS Z_SCORE
FROM cte1
WHERE ABS((quantityordered-avg)/ stddev) > 3

--BT6:  
DELETE quantityordered 
FROM public.sales_dataset_rfm_prj
WHERE quantityordered >= 70
