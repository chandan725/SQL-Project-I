use week1
select * from members
select * from menu
select * from sales

--1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(price) as total_spend
from menu inner join sales s 
on menu.product_id=s.product_id
group by s.customer_id

--2. How many days has each customer visited the restaurant?
select customer_id, count( distinct order_date) as total_day_visited from sales
group by customer_id

--3. What was the first item from the menu purchased by each customer? (assuming only one item purchased for each order on a particular day)
select customer_id, product_name as first_item_purchased from
	(select s.customer_id, menu.product_name, s.order_date, row_number() over(partition by customer_id order by order_date) as rn
	from menu inner join sales s 
	on menu.product_id=s.product_id) as x
where rn = 1

--3. What was the first item from the menu purchased by each customer? (assuming more items purchased an order on a particular day)
select customer_id, product_name as first_item_purchased from
	(select s.customer_id, menu.product_name, s.order_date, rank() over(partition by customer_id order by order_date) as rn
	from menu inner join sales s 
	on menu.product_id=s.product_id) as x
where rn = 1 

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select TOP 1 menu.product_name as most_purchased_item, count(*) as frequency from menu inner join sales s 
on menu.product_id=s.product_id
group by product_name
order by frequency desc


--5. Which item was the most popular for each customer?
with cte as
    (select customer_id, product_name, count(*) as cnt,
	rank() over(partition by customer_id order by count(*) desc) rnk from menu
	inner join sales s 
	on menu.product_id=s.product_id
	group by customer_id, product_name)
select customer_id, product_name from cte 
where rnk=1

--6. Which item was purchased first by the customer after they became a member?
with cte1 as
	(select s.customer_id, menu.product_name, s.order_date,  m.join_date, DATEDIFF(day, m.join_date, s.order_date) as diff
	from sales s inner join menu on s.product_id=menu.product_id inner join members m on s.customer_id=m.customer_id
	where DATEDIFF(day, m.join_date, s.order_date) >= 0),
cte2 as
    (select customer_id, product_name, diff, rank() over(partition by customer_id order by diff) as rn  from cte1)
select customer_id, product_name as first_item_as_member from cte2
where rn = 1

--7. Which item was purchased just before the customer became a member?
with cte1 as
	(select s.customer_id, menu.product_name, s.order_date,  m.join_date, DATEDIFF(day, s.order_date, m.join_date) as diff         
	from sales s inner join menu on s.product_id=menu.product_id inner join members m on s.customer_id=m.customer_id
	where DATEDIFF(day, m.join_date, s.order_date) < 0),
cte2 as
    (select *, rank() over(partition by customer_id order by diff) as rn  from cte1)
select customer_id, product_name  from cte2
where rn=1

--8. What is the total items and amount spent for each member before they became a member?
with cte as
	(select s.customer_id, menu.product_name, menu.price, s.order_date,  m.join_date, DATEDIFF(day, s.order_date, m.join_date) as diff         
	from sales s inner join menu on s.product_id=menu.product_id inner join members m on s.customer_id=m.customer_id
	where DATEDIFF(day, m.join_date, s.order_date) < 0)
select customer_id, count(*) as total_item_ordered, sum(price) as total_spent from cte
group by customer_id

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id, sum(case when product_name = 'sushi' then price*2*10 else price*10 end) as points
from menu inner join sales s on menu.product_id=s.product_id
group by customer_id

/*--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
not just sushi - how many points do customer A and B have at the end of January? */
select s.customer_id,
	sum(case when order_date between join_date and dateadd(day, 6, join_date) then price*2*10
	when product_name='sushi' then price*2*10
	else price*10 end) as points
from sales as s
inner join menu on s.product_id=menu.product_id
inner join members as m on s.customer_id=m.customer_id
where order_date <= '2021-01-31'
group by s.customer_id



