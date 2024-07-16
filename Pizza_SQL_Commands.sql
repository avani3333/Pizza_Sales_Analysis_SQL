-- total number of orders placed
select count(order_id) as total_orders from orders;

-- total revenue from pizza sales
select round(sum(order_details.quantity*pizzas.price),2) as total_revenue from order_details join pizzas on pizzas.pizza_id=order_details.pizza_id

-- highest price pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;  

-- most common pizza size orderd
select pizzas.size, count(order_details.quantity) as order_count from pizzas join order_details on pizzas.pizza_id=order_details.pizza_id group by size order by order_count desc; 

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS order_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY order_quantity DESC
LIMIT 5;

-- Determine the distribution of orders by hour of the day.
select hour(order_time), count(order_id) from orders group by hour(order_time); 

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) as count from pizza_types group by category; 

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) as avg_order_per_day from (select orders.order_date, sum(order_details.quantity) as quantity from orders join order_details on orders.order_id=order_details.order_id group by orders.order_date) as order_quantity; 

--  Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(order_details.quantity*pizzas.price) as revenue from pizza_types join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id join order_details on order_details.pizza_id=pizzas.pizza_id group by pizza_types.name order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category, round(sum(order_details.quantity*pizzas.price) / (select round(sum(order_details.quantity*pizzas.price), 2) as total_sales from order_details join pizzas on pizzas.pizza_id=order_details.pizza_id)*100,2) as revenue from pizza_types join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id join order_details on order_details.pizza_id=pizzas.pizza_id group by pizza_types.category order by revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue from (select orders.order_date, sum(order_details.quantity*pizzas.price) as revenue from order_details join pizzas on order_details.pizza_id=pizzas.pizza_id join orders on orders.order_id=order_details.order_id group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
 select name, revenue from (select category, name, revenue, rank() over(partition by category order by revenue desc) as rn from (select pizza_types.category, pizza_types.name, sum((order_details.quantity)*pizzas.price) as revenue from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id join order_details on order_details.pizza_id=pizzas.pizza_id group by pizza_types.category, pizza_types.name) as a) as b where rn<=3;