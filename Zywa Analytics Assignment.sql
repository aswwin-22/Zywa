SELECT * FROM transactions
LIMIT 100;

SELECT DISTINCT billing_currency from transactions;


-- ### Monthly transactions
-- Need how much amount we have processed each month commutative and every month.

SELECT
  MONTH(new_date) AS month,
  SUM(transaction_amount) AS monthly_amount,
  SUM(SUM(transaction_amount)) OVER (ORDER BY MONTH(new_date)) AS cumulative_amount
FROM transactions
GROUP BY MONTH(new_date);


SHOW VARIABLES LIKE 'sql_mode';

SET GLOBAL sql_mode='modes';

-- ### **Most Popular Products/Services:**
-- Design a SQL query to identify the top 5 most popular products or services based on transaction counts.

SELECT merchant_name, count(transaction_amount) as no_of_transactions 
FROM TRANSACTIONS
GROUP BY merchant_name
ORDER BY no_of_transactions DESC
LIMIT 5;

-- ### **Average Transaction Amount by Product Category:**
-- Formulate a SQL query to find the average transaction amount for each product category.

SELECT merchant_type, avg(transaction_amount) as avg_transaction_amount
FROM TRANSACTIONS
GROUP BY merchant_type
ORDER BY avg_transaction_amount DESC;

-- ### **Daily Revenue Trend:**
-- Formulate a SQL query to visualize the daily revenue trend over time.

ALTER TABLE transactions
ADD COLUMN new_date TIMESTAMP;

UPDATE transactions
SET new_date = str_to_date(transaction_timestamp,'%m/%d/%y %H:%i');

SELECT DATE(new_date) as date, SUM(billing_amount) as bill_amount,
LAG (SUM(billing_amount)) OVER(ORDER BY Date(new_date)) AS prev_date_amount,
SUM(billing_amount)- LAG (SUM(billing_amount)) OVER(ORDER BY Date(new_date)) as diff
FROM transactions
GROUP BY DATE(new_date)
ORDER BY date(new_date);

### **Transaction Funnel Analysis:**
-- Create a SQL query to analyze the transaction funnel, including completed, pending, and cancelled transactions.


SELECT
  transaction_status,
  COUNT(*) AS transaction_count
FROM
  transactions
GROUP BY
  transaction_status
ORDER BY
  transaction_status;
  
-- ### **Monthly Retention Rate:**
-- Design a SQL query to calculate the Monthly Retention Rate, grouping users into monthly cohorts.
 
 
 SELECT month(new_date)as month ,COUNT(DISTINCT user_id) as no_of_users from transactions
 GROUP BY month(new_date);
 
SELECT
  MONTH(new_date) AS month,
  COUNT(DISTINCT user_id) AS total_users,
  COUNT(DISTINCT CASE WHEN EXTRACT(YEAR_MONTH FROM new_date) = EXTRACT(YEAR_MONTH FROM MIN(new_date)) THEN user_id END) AS retained_users
FROM transactions
GROUP BY MONTH(new_date)
ORDER BY MONTH(new_date);
 
SELECT
  MONTH(new_date) AS month,
  COUNT(DISTINCT user_id) AS total_users,
  COUNT(DISTINCT CASE WHEN cohort_month = MONTH(new_date) THEN user_id END) AS retained_users
FROM (
  SELECT
    user_id,
    MIN(new_date) AS cohort_month
  FROM transactions
  GROUP BY user_id
) AS cohorts
GROUP BY MONTH(new_date)
ORDER BY MONTH(new_date);
 

 
SELECT
  DATE_FORMAT(MIN(new_date), '%Y-%m') AS cohort_month,
  DATE_FORMAT(MIN(new_date), '%Y-%m') AS current_month,
  COUNT(DISTINCT user_id) AS retained_users,
  COUNT(DISTINCT user_id) / COUNT(DISTINCT initial_users.user_id) * 100 AS retention_rate
FROM (
  SELECT
    user_id,
    MIN(new_date) AS cohort_month
  FROM
    transactions
  GROUP BY
    user_id
) AS initial_users
JOIN (
  SELECT
    user_id,
    MIN(new_date) AS current_month
  FROM
    transactions
  GROUP BY
    user_id
) AS current_users ON initial_users.user_id = current_users.user_id
   AND EXTRACT(YEAR_MONTH FROM initial_users.cohort_month) = EXTRACT(YEAR_MONTH FROM current_users.current_month)
GROUP BY
  EXTRACT(YEAR_MONTH FROM initial_users.cohort_month), EXTRACT(YEAR_MONTH FROM current_users.current_month)
ORDER BY
  EXTRACT(YEAR_MONTH FROM initial_users.cohort_month), EXTRACT(YEAR_MONTH FROM current_users.current_month);

SELECT
  DATE_FORMAT(MIN(new_date), '%Y-%m') AS cohort_month,
  DATE_FORMAT(MIN(new_date), '%Y-%m') AS current_month,
  COUNT(DISTINCT user_id) AS retained_users,
  COUNT(DISTINCT user_id) / COUNT(DISTINCT initial_users.user_id) * 100 AS retention_rate
FROM (
  SELECT
    user_id,
    MIN(new_date) AS cohort_month
  FROM
    transactions
  GROUP BY
    user_id
) AS initial_users
JOIN (
  SELECT
    user_id,
    MIN(new_date) AS current_month
  FROM
    transactions
  GROUP BY
    user_id
) AS current_users ON initial_users.user_id = current_users.user_id
   AND EXTRACT(YEAR_MONTH FROM initial_users.cohort_month) = EXTRACT(YEAR_MONTH FROM current_users.current_month)
GROUP BY
  EXTRACT(YEAR_MONTH FROM initial_users.cohort_month), EXTRACT(YEAR_MONTH FROM current_users.current_month)
ORDER BY
  EXTRACT(YEAR_MONTH FROM initial_users.cohort_month), EXTRACT(YEAR_MONTH FROM current_users.current_month);




