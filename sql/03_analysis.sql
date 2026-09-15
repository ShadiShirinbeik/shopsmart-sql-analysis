-- Q1 · Customer segmentation
-- Business question: How many customers do we have in each region?
-- Insight: Customer base is fairly balanced; South/North lead (57/56), West/East trail (44/43).
select region, 
	count(*) as number_of_customers
from customers
group by region
order by number_of_customers desc;


-- Q2 · Regional performance
-- Business question: What is the average order value in each region?
-- Insight: West has the highest average order value (~$2,567) despite the fewest orders; 
--			East trails (~$1,662). Order value and number of orders don't move together.
select region, 
	round(avg(total_amount), 2) as avg_order_value,
	count(*) as number_of_orders
from customers c 
join orders o 
	using (customer_id)
group by region
order by avg_order_value desc;


-- Q3 · Product mix
-- Business question: Which product categories carry the highest average list price?
-- Insight: Electronics is the premium category (~$280 avg list price), 
--			Clothing the most affordable (~$177). 
--			Home has only 4 products, so its average price is not particularly reliable.
select category,
	   round(avg(unit_price)) as list_price_average,
	   count(*) as number_of_products
from products p 
group by category 
order by list_price_average desc;


-- Q4 · Revenue trend
-- Business question: How has monthly revenue developed over time?
-- Insight: Monthly revenue goes up and down a lot, between about $34k and $70k with no clear seasonal pattern; 
--	    	Sep 2025 is the peak. Oct 2024 and Oct 2025 are partial months and should be excluded from comparisons.
select sum(total_amount) as monthly_revenue,
	   date_trunc('month', order_date) as monthly_order_date
from orders o 
group by monthly_order_date 
order by monthly_revenue desc;


-- Q5 · Product performance
-- Business question: Which 10 products sell the most units?
-- Insight: The best-selling product is "How" from Sports with 83 units. 
--			Sports has 3 products in the top 4, so it is the strongest category by volume.
select product_name,
	   sum(quantity) as unit_sold,
	   category
from products p 
join order_items oi 
	using(product_id)
group by product_id
order by unit_sold desc
limit 10;


-- Q6 · Customer loyalty
-- Business question: Which customers placed more than 3 orders in the last 6 months of data?
-- Insight:




-- Q7 · Pricing
-- Business question: Which categories are discounted more than 10% on average per order line?
-- Insight:
-- =====================================================================

-- =====================================================================
-- Q8 · Regional targets
-- Business question: Which regions exceeded $175,000 in total sales?
-- Insight:
-- =====================================================================

-- =====================================================================
-- Q9 · High-value customers
-- Business question: Which customers have an average order value above the company-wide average?
-- Insight:
-- =====================================================================

-- =====================================================================
-- Q10 · Catalog health
-- Business question: Which products have never been sold?
-- Insight:
