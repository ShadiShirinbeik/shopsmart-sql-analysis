-- Q1 · Customer segmentation
-- Business question: How many customers do we have in each region?
-- Insight: Customer base is fairly balanced; South/North lead (57/56), West/East trail (44/43).

select region, 
	count(*) as number_of_customers
from customers
group by region
order by number_of_customers desc;

-- =====================================================================

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

-- =====================================================================

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

-- =====================================================================

-- Q4 · Revenue trend
-- Business question: How has monthly revenue developed over time?
-- Insight: Monthly revenue goes up and down a lot, between about $34k and $70k with no clear seasonal pattern; 
--	    	Sep 2025 is the peak. Oct 2024 and Oct 2025 are partial months and should be excluded from comparisons.

select sum(total_amount) as monthly_revenue,
	   date_trunc('month', order_date) as monthly_order_date
from orders o 
group by monthly_order_date 
order by monthly_revenue desc;

-- =====================================================================

-- Q5 · Product performance
-- Business question: Which 10 products sell the most units?
-- Insight: The best-selling product is "How" from Sports with 83 units. 
--			Sports has 3 products in the top 4, so it is the strongest category by volume.

select product_id,
	   product_name,
	   sum(quantity) as unit_sold,
	   category
from products p 
join order_items oi 
	using(product_id)
group by product_id, product_name
order by unit_sold desc
limit 10;

-- =====================================================================

-- Q6 · Customer loyalty
-- Business question: Which customers placed more than 3 orders in the last 6 months of data?
-- Insight: Only one customer (Evans, 4 orders) ordered more than 3 times in the last 6 months. 
--			Most active customers (81 of 115) placed just one order in that window, 
--			so repeat purchasing is rare and there is no real "loyal core" yet.

select customer_id, 
	   last_name,
	   count(*) as total_orders
from customers c
join orders o 
	using(customer_id)
where order_date >= (select max(order_date) - interval '6 month' from orders)
group by customer_id, last_name
having count(*) > 3
order by total_orders desc;

-- =====================================================================

-- Q7 · Pricing
-- Business question: Which categories are discounted more than 10% on average per order line?
-- Insight: No category has an average line discount above 10%. 
--			All categories have discount between 7.5% and 8.0%, 
--			which suggests discounts are applied uniformly rather than being targeted at specific categories.

select category, avg(oi.discount) as avg_order_discount
from products p 
join order_items oi 
	using(product_id)
group by category
having avg(oi.discount) > 0.10;

-- =====================================================================

-- Q8 · Regional targets
-- Business question: Which regions exceeded $175,000 in total sales?
-- Insight: North (~$197k) and South (~$183k) passed the $175k target,
--			and East is far behind at ~$110k,
--			Combined with Q2, East has both the fewest big orders and the lowest total.

select region, sum(total_amount) as total_order_amount
from customers c 
join orders o 
	using(customer_id)
group by region
having sum(total_amount) > 175000 
order by total_order_amount desc;

-- =====================================================================

-- Q9 · High-value customers
-- Business question: Which customers have an average order value above the company-wide average?
-- Insight: 74 of 159 buyers have an average order value above the company average of ~$2,161.
--			The top of the list is dominated by customers with only 1–2 orders,
--			so a high average often reflects a single large purchase

with customer_avg as (
	select customer_id, 
			first_name,
			count(*) as number_of_orders,
			round(avg(total_amount), 2) as avg_order_value
	from orders o
	join customers c
		using(customer_id)
	group by customer_id, first_name
),
overall as (
	select round(avg(total_amount), 2) as overal_avg
	from orders
)
select ca.customer_id, 
		ca.first_name,
		ca.number_of_orders,
		ca.avg_order_value,
		ov.overal_avg 
from customer_avg ca
cross join overall ov
where ca.avg_order_value  > ov.overal_avg 
order by ca.avg_order_value desc
limit 10;

-- =====================================================================

-- Q10 · Catalog health
-- Business question: Which products have never been sold?
-- Insight: Every product in the catalog has sold at least once, so there is no dead stock to remove.

select product_id, 
		product_name,
	    sum(quantity) as product_quantity
from products p 
left join order_items oi 
	using(product_id)
group by product_id
having sum(quantity) is null
order by product_quantity;

-- =====================================================================

-- Q11 · Regional sales by category
-- Business question: In the last 6 months, which category-region combinations generated more than $20,000 in net revenue?
-- Insight: Electronics is the only category that passes $20k in all four regions, with Electronics-South the strongest pair (~$34k). 
--			Sports clears the bar only in South and North, 
--			and Beauty only in North. 
--			Clothing and Home do not reach $20k anywhere in the last 6 months.

select category, 
		region,
		round(sum(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) as net_revenue
from orders o 
join customers c 
	using (customer_id)
join order_items oi 
	using(order_id)
join products p 
	using(product_id)
where order_date > (select max(order_date) - interval '6 month' from orders)
group by category, region
having sum(oi.quantity * oi.unit_price * (1 - oi.discount)) > 20000
order by net_revenue desc;

-- =====================================================================

-- Q12 · Cross-category buyers
-- Business question: Which customers have bought from more than 3 different categories?
-- Insight: 71 of 159 buyers (45%) have purchased from 4 or 5 of the 5 categories, 
--			and only 15 customers stick to a single category.

select customer_id, 
		last_name,
		count(distinct category) as count_categories
from orders o 
join order_items oi 
	using(order_id)
join products p 
	using(product_id)
join customers c 
	using(customer_id)
group by customer_id, last_name
having count(category) > 3
order by count_categories desc;

-- =====================================================================

-- Q13 · Discount depth by category
-- Business question: What is the average discount per category, considering only categories with at least 50 units sold?
-- Insight: Every category sells well above the 50-unit, so none are filtered out.
--			Average discounts stay in a tight 7.5%–8.0% band.

with category_sales as (
    select category,
           sum(oi.quantity) as units_sold,
           avg(oi.discount) as avg_discount
    from order_items oi
    join products p
	using(product_id)
    group by category
)
select category,
       units_sold,
       round(avg_discount * 100, 2) as avg_discount_pct
from category_sales
where units_sold >= 50
order by avg_discount_pct desc;

-- =====================================================================

-- Q14 · Campaign response
-- Business question: Who are the top 5 customers by spend during active promotion periods?
-- Insight: Cameron Bradley (~$2,840) and Nicholas Johnson (~$2,600) spent the most on promoted products while a promotion was active.

with promo_lines as (
select customer_id,
		oi.quantity * oi.unit_price * (1 - oi.discount) AS net_value
from orders o 
join order_items oi 
	using(order_id)
where exists
		(select 1 from promotions pr
		where pr.product_id = oi.product_id
		and o.order_date between pr.start_date and pr.end_date ) 
)
select customer_id,
		first_name,
		round(sum(pl.net_value), 2) as promo_spend
from promo_lines pl
join customers s
	using (customer_id)
group by customer_id, first_name
order by promo_spend desc
limit 5;
-- =====================================================================

-- Q15 · Promotion revenue
-- Business question: How much revenue did each promoted product generate during its promotion period?
-- Insight: Promotions on "How" (Sports) generated by far the most revenue (~$22.7k and ~$18k), 
--			but three overlapping promos on the same product make it impossible to credit any single one. 

with sales as (
    select product_id,
           order_date,
           quantity,
           quantity * unit_price * (1 - oi.discount) as net_value
    from order_items oi
    join orders o 
		using(order_id)
)
select promotion_id,
       product_name,
       category,
       start_date,
       end_date,
       end_date - start_date + 1 as promo_days,
       discount_percent,
       ROUND(COALESCE(SUM(s.net_value), 0), 2) as promo_revenue
from promotions pr
join products p 
	using(product_id)
left join sales s 
	using(product_id)
where order_date between start_date and end_date
group by promotion_id, product_name, category,
         start_date, end_date, discount_percent
order by promo_revenue desc;

-- =====================================================================

-- Q16 · Underperforming promotions
-- Business question: Which promoted products still sold less than the average product in their category?
-- Insight: 8 of the 17 promoted products still sold less than the average product in their category.
--          Four of them ("Identify", "Ball", "Reality", "Sometimes") are more than 55% below that average.

WITH product_sales AS (
    -- total net sales per product, all time
    SELECT p.product_id, p.product_name, p.category,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS product_sales
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
category_avg AS (
    -- average of those product totals, per category
    SELECT category, AVG(product_sales) AS category_avg_sales
    FROM product_sales
    GROUP BY category
)
SELECT ps.product_id, ps.product_name, ps.category,
       ROUND(ps.product_sales, 2) AS product_sales,
       ROUND(ca.category_avg_sales, 2) AS category_avg_sales,
       ROUND(100 * (ps.product_sales / ca.category_avg_sales - 1), 1) AS pct_vs_avg
FROM product_sales ps
JOIN category_avg ca ON ca.category = ps.category
WHERE EXISTS (SELECT 1 FROM promotions pr WHERE pr.product_id = ps.product_id)  -- only promoted products
  AND ps.product_sales < ca.category_avg_sales
ORDER BY pct_vs_avg;

-- =====================================================================

-- Q17 · Month-over-month growth
-- Business question: In which regions and months did the average order value grow compared to the previous month?
-- Insight: Average order value grew from one month to the next in 22 of 48 region-months.
--          West grew most often (7 of 12 months), East least often (4 of 12).

WITH monthly_aov AS (
    SELECT c.region,
           DATE_TRUNC('month', o.order_date)::date AS month,
           AVG(o.total_amount) AS avg_order_value
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY c.region, DATE_TRUNC('month', o.order_date)
)
SELECT cur.region,
       TO_CHAR(cur.month, 'YYYY-MM') AS month,
       ROUND(prev.avg_order_value, 2) AS previous_month_aov,
       ROUND(cur.avg_order_value, 2) AS current_month_aov,
       ROUND(100 * (cur.avg_order_value / prev.avg_order_value - 1), 1)  AS growth_pct
FROM monthly_aov cur
JOIN monthly_aov prev                                   -- self-join: same table twice
  ON prev.region = cur.region
 AND prev.month  = cur.month - INTERVAL '1 month'       -- prev row is exactly one month earlier
WHERE cur.avg_order_value > prev.avg_order_value
ORDER BY cur.region, cur.month;

-- =====================================================================
-- Q18 · Market basket
-- Business question: Which customers bought both Electronics and Sports products?
-- Insight: 79 of 159 buyers (half) have bought both Electronics and Sports products.

WITH customer_categories AS (
    SELECT o.customer_id,
           COUNT(*) FILTER (WHERE p.category = 'Electronics') AS electronics_lines,
           COUNT(*) FILTER (WHERE p.category = 'Sports')  AS sports_lines
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p     ON p.product_id = oi.product_id
    GROUP BY o.customer_id
)
SELECT c.customer_id, c.first_name, c.last_name,
       cc.electronics_lines, cc.sports_lines
FROM customer_categories cc
JOIN customers c ON c.customer_id = cc.customer_id
WHERE cc.electronics_lines > 0
  AND cc.sports_lines > 0
ORDER BY c.customer_id;

-- =====================================================================
-- Q19 · Market penetration
-- Business question: How many unique buyers does each category have, and which reach at least 40?
-- Insight: All five categories pass the 40-buyer threshold. Electronics has the widest reach with 119 of 200
--          customers (60%), then Clothing (113) and Sports (109). Home is the smallest with 60 buyers (30%).

SELECT p.category,
       COUNT(DISTINCT o.customer_id) AS unique_buyers,
       ROUND(100.0 * COUNT(DISTINCT o.customer_id) / (SELECT COUNT(*) FROM customers), 1) AS pct_of_all_customers
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o   ON o.order_id   = oi.order_id
GROUP BY p.category
HAVING COUNT(DISTINCT o.customer_id) >= 40
ORDER BY unique_buyers DESC;

-- =====================================================================

-- Q20 · Discount concentration
-- Business question: Which product received the largest total discount amount within each category?
-- Insight: The most discounted product in each category is simply its best seller ("How" in Sports, "Foot" in Electronics,
--          "Term" in Beauty, "Set" in Home, "Prevent" in Clothing). Discount rates are flat across products,
--          so the product that sells the most collects the biggest discount total.

WITH product_discount AS (
    SELECT p.category, p.product_id, p.product_name,
           SUM(oi.quantity * oi.unit_price * oi.discount) AS total_discount,  -- money given away
           SUM(oi.quantity * oi.unit_price) AS gross_sales      -- before discount
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT pd.category, pd.product_id, pd.product_name,
       ROUND(pd.total_discount, 2) AS total_discount,
       ROUND(pd.gross_sales, 2) AS gross_sales,
       ROUND(100 * pd.total_discount / pd.gross_sales, 1) AS effective_discount_pct
FROM product_discount pd
WHERE pd.total_discount = (
    SELECT MAX(x.total_discount)   -- correlated subquery: runs once per row,
    FROM product_discount x   -- looks at the same category as the outer row
    WHERE x.category = pd.category
)
ORDER BY pd.total_discount DESC;