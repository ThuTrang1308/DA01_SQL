--Ex1:
WITH cte1 AS
(SELECT EXTRACT(YEAR FROM transaction_date) AS year, product_id,
spend AS curr_year_spend,
LAG(spend) OVER (PARTITION BY product_id ORDER BY product_id, 
EXTRACT(YEAR FROM transaction_date)) AS prev_year_spend 
FROM user_transactions)
SELECT year, product_id, curr_year_spend, prev_year_spend, 
ROUND(100 * (curr_year_spend - prev_year_spend) / prev_year_spend, 2) AS yoy_rate 
FROM cte1;

--Ex2:
SELECT DISTINCT card_name, 
FIRST_VALUE(issued_amount) OVER(PARTITION BY card_name
ORDER BY issue_year ) AS issued_amount 
FROM monthly_cards_issued 
ORDER BY issued_amount DESC

--Ex3:
SELECT user_id,spend, transaction_date FROM
(SELECT user_id, spend, transaction_date,
rank () OVER (PARTITION BY user_id ORDER BY transaction_date) as rank1
FROM transactions) as x
WHERE rank1 = 3

--Ex4:
WITH bang1 AS 
(SELECT transaction_date, user_id, product_id, RANK() OVER (PARTITION BY user_id ORDER BY transaction_date DESC) AS rank1 
FROM user_transactions) 
  
SELECT transaction_date, user_id,
COUNT(product_id) AS purchase_count
FROM bang1
WHERE rank1 = 1 
GROUP BY transaction_date, user_id
ORDER BY transaction_date;

--Ex5:
SELECT user_id, tweet_date,   
ROUND(AVG(tweet_count) OVER (PARTITION BY user_id ORDER BY tweet_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS rolling_avg_3d
FROM tweets;

--Ex6:
WITH a1 AS 
(SELECT transaction_id, merchant_id, credit_card_id, amount, 
transaction_timestamp as current_transaction,
LAG(transaction_timestamp) OVER(PARTITION BY merchant_id, credit_card_id, amount ORDER BY transaction_timestamp) AS previous_transaction
FROM transactions)

SELECT COUNT(merchant_id) as payment_count
FROM a1
WHERE current_transaction - previous_transaction <= INTERVAL '10 minutes'

--Ex7:
SELECT category, product, total_spend 
FROM (SELECT category, product, SUM(spend) AS total_spend, RANK() OVER (PARTITION BY category ORDER BY SUM(spend) DESC) AS ranking 
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product) AS ranked_spending
WHERE ranking <= 2 
ORDER BY category, ranking
 
--Ex8:
SELECT artist_name, artista_rank FROM
(SELECT artist_name ,DENSE_RANK() OVER(ORDER BY COUNT(RANK) DESC) artista_rank
FROM artists a
JOIN songs b ON b.artist_id = a.artist_id
JOIN global_song_rank c ON c.song_id=b.song_id
WHERE rank <=10
GROUP BY artist_name) top_artist
WHERE artista_rank <=5
