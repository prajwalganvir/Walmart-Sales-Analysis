-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

use walmartSales;

-- Create table
CREATE TABLE IF NOT EXISTS sales_walmart(
  invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
  branch VARCHAR(5) NOT NULL,
  city VARCHAR(30) NOT NULL,
  customer_type VARCHAR(30) NOT NULL,
  gender VARCHAR(30) NOT NULL,
  product_line VARCHAR(100) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL,
  tax_pct FLOAT NOT NULL,
  total DECIMAL(12, 4) NOT NULL,
  date DATETIME NOT NULL,
  time TIME NOT NULL,
  payment VARCHAR(15) NOT NULL,
  cogs DECIMAL(10,2) NOT NULL,
  gross_margin_pct FLOAT,
  gross_income DECIMAL(12, 4),
  rating FLOAT
);


select * from sales_walmart;

-- ______________________________________________________________________________________________________--- 
-------------------------------------------- FEATURE ENGINEERING ------------------------------------------

-- TIME OF DAY

select time, (case when `time` between "00:00:00" and "12:00:00" then "Morning"
					when `time` between "12:01:00" and "16:00:00" then "Afternoon"
                    else "Evening"
                   end ) as time_of_day from sales_walmart;
                   
                   
alter table sales_walmart add column time_of_day varchar(20);

set sql_safe_updates =0;

update sales_walmart
set time_of_day = (case when `time` between "00:00:00" and "12:00:00" then "Morning"
					when `time` between "12:01:00" and "16:00:00" then "Afternoon"
                    else "Evening"
                   end );

select * from sales_walmart;


-- day_name

select date,dayname(date) from sales_walmart;

alter table sales_walmart add column day_name varchar(20);

update sales_walmart
set day_name = dayname(date);

select * from sales_walmart;

-- month name 

select date,monthname(date) from sales_walmart;

alter table sales_walmart add column month_name varchar(20);

update sales_walmart
set month_name = monthname(date);

select * from sales_walmart;

-- ______________________________________ Business Questions _____________________________________________
-- --------------------------- Generic ---------------------------------------------------

-- how many unique cities does the data have?

select distinct city from sales_walmart;

-- how many unique branches does the data have?

select distinct branch from sales_walmart;

select distinct city,branch from sales_walmart;
-- _______________________________________________________________________________________________________
-- ------------------------------------- Product -----------------------------------------------------

-- how many unique product lines does the data have?

select count(distinct product_line )from sales_walmart;

-- what is the most common payment method?

select * from sales_walmart;

select payment,count(payment) as count from sales_walmart group by payment order by count desc;
-- what is the most selling product line ?

select * from sales_walmart;

select product_line,count(product_line) as count from sales_walmart group by product_line order by count desc;

-- what is the total revernue by month

select * from sales_walmart;

select month_name,sum(total) as total_revenue from sales_walmart group by month_name order by total_revenue desc;

-- which month had the largest COGS?


select month_name as month,sum(cogs) as cogs from sales_walmart group by month_name order by cogs;

-- which product line had the largest revenue?

select product_line ,sum(total) as total_revenue from sales_walmart group by product_line order by total_revenue;

-- what is the city with the largest revenue?

select branch,city,sum(total) as total_revenue from sales_walmart group by city,branch order by total_revenue desc;

-- what product line had the largest VAT?

select product_line,avg(tax_pct) as avg_tax from sales_walmart group by product_line order by avg_tax desc;

-- which branch sold more products than average product sold?

select branch,sum(quantity) as qty from sales_walmart group by branch having sum(quantity) > (select avg(quantity) from sales_walmart);

-- what is the most common product line by gender?

select gender,product_line,count(gender) as total_cnt from sales_walmart group by gender,product_line order by total_cnt desc;

-- what is the average rating of each product line ?

select * from sales_walmart;

select round(avg(rating),2) as avg_rating , product_line from sales_walmart group by product_line order by avg_rating desc;

-- ________________________________________________________________________________________________________
-- ---------------------------------------- Sales ----------------------------------------------------

-- Number of sales made in each time of the day per weekday ? 

select time_of_day,count(*) as total_sales from sales_walmart where day_name = "Monday" group by time_of_day order by total_sales desc;

-- Which of the customer types brings the most revenue ? 

select customer_type,sum(total) as total_rev from sales_walmart group by customer_type order by total_rev desc;


-- which city has the largest tax percent/ VAT (value Added Tax) ? 

select city,sum(tax_pct)as total_vat from sales_walmart group by city order by total_vat;
select * from sales_walmart;

-- which customer type pays the most in VAT?

select customer_type,sum(tax_pct)as total_vat from sales_walmart group by customer_type order by total_vat;
 
  -- ________________________________________________ CUSTOMER ____________________________________________________

-- How many unique customer types does the data have?
SELECT DISTINCT customer_type FROM sales_walmart;

-- How many unique payment methods does the data have?
SELECT DISTINCT payment FROM sales_walmart;


-- What is the most common customer type?
SELECT customer_type, count(*) as count FROM sales_walmart
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales_walmart
GROUP BY customer_type;


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales_walmart
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales_walmart
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales_walmart
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales_walmart
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales_walmart
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales_walmart
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales_walmart
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales_walmart
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales_walmart
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales_walmart
GROUP BY customer_type
ORDER BY total_tax;






