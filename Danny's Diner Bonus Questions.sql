-- Bonus Question - 1
select s.customer_id, s.order_date, menu.product_name, menu.price,
case when order_date>=join_date then 'Y'
else 'N' end as member
from sales s 
inner join menu on s.product_id=menu.product_id
left join members m on s.customer_id=m.customer_id

-- Bonus Question - 2
with cte as 
(select s.customer_id, s.order_date, menu.product_name, menu.price,
case when order_date>=join_date then 'Y'
else 'N' end as member
from sales s 
inner join menu on s.product_id=menu.product_id
left join members m on s.customer_id=m.customer_id)
select *, 
case when member = 'N' then null
else rank() over(partition by customer_id, member order by order_date) end as ranking
from cte