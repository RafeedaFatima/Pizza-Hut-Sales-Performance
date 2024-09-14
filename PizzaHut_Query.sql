-- Retrieving the total number of orders placed.
SELECT COUNT(order_id) AS total_orders FROM orders;
-- Calculate the total revenue generated from pizza sales and round to two decimal places.
SELECT ROUND(SUM(od.quantity * p.price)::numeric, 2) AS total_sales
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id;
-- Identify the highest-priced pizza.
SELECT pt.name, p.price AS highest_priced_pizza
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
WHERE p.price = (SELECT MAX(price) FROM pizzas);
-- Identify the most common pizza size ordered.
SELECT p.size, COUNT(*) AS size_count
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY size_count DESC
LIMIT 1;
-- List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, SUM(od.quantity) AS most_ordered_pizza_types
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id	
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY most_ordered_pizza_types DESC
LIMIT 5;
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity) AS total_quantity_of_each_pizza_category
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id	
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY total_quantity_of_each_pizza_category DESC;
-- Determine the distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM order_time::time) AS hours, COUNT(order_id) AS orderCount
FROM orders
GROUP BY hours
ORDER BY hours;
-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name) FROM pizza_types 
GROUP BY category;
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity)::numeric, 0) AS AvgPizzaOrdered  FROM (SELECT o.order_date, SUM(od.quantity) AS quantity
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_date) AS orderQuantity;
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name, SUM(od.quantity * p.price) AS revenue
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id	
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category, 
       ROUND(SUM(od.quantity * p.price)::numeric / 
       (SELECT SUM(od_sub.quantity * p_sub.price)::numeric 
        FROM order_details od_sub 
        JOIN pizzas p_sub ON p_sub.pizza_id = od_sub.pizza_id) * 100, 2) AS revenue_percentage
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue_percentage DESC;
-- Analyze the cumulative revenue generated over time.
SELECT order_date, SUM(revenue) OVER(ORDER BY order_date) AS cumRevenue
FROM (SELECT o.order_date, SUM(od.quantity * p.price) AS revenue
FROM order_details od 
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN orders o ON o.order_id = od.order_id
GROUP BY o.order_date) AS sales;
--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, revenue
FROM(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM (SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category, pt.name) AS a) AS b
WHERE rn <= 3;