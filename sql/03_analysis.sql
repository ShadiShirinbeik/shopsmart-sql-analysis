-- Q1 · Customer segmentation
-- Business question: How many customers do we have in each region?
-- Insight: Customer base is fairly balanced; South/North lead (57/56), West/East trail (44/43).

select region, 
	count(*) as number_of_customers
from customers
group by region
order by number_of_customers desc;

--==========================================================================================

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

--==========================================================================================

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

--==========================================================================================

-- Q4 · Revenue trend
-- Business question: How has monthly revenue developed over time?
-- Insight: Monthly revenue goes up and down a lot, between about $34k and $70k with no clear seasonal pattern; 
--	    	Sep 2025 is the peak. Oct 2024 and Oct 2025 are partial months and should be excluded from comparisons.

select sum(total_amount) as monthly_revenue,
	   date_trunc('month', order_date) as monthly_order_date
from orders o 
group by monthly_order_date 
order by monthly_revenue desc;

--==========================================================================================

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

--==========================================================================================

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

--==========================================================================================

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

--==========================================================================================

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

--==========================================================================================

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

--==========================================================================================

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


--==========================================================================================














