# What is the total amount each customer spent at the restaurant?

select * from sales; 
select * from menu;
select * from members;

select s.customer_id,SUM(m.price) as Total_amount from menu m INNER JOIN sales s 
ON s.product_id=m.product_id
group by s.customer_id;


# How many days has each customer visited the restaurant?

with cte_days as 
(select *,day(order_date) as days from  sales)

select customer_id,count(distinct days) as total_days 
from cte_days
group  by customer_id;

# What was the first item from the menu purchased by each customer?

with cte1 as
(select m.product_name,m.price,s.customer_id,s.order_date,s.product_id , 
dense_rank() over (partition by customer_id order by order_date asc) as ranks
from sales as s 
inner join menu as m
on m.product_id = s.product_id) 
select customer_id, product_name
from cte1
where ranks = 1;

# What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name,count(*) as no_of_times_purchased 
from sales s inner join menu m
on s.product_id=m.product_id
group by m.product_name
order by no_of_times_purchased desc limit 1;

# how many times a product purchased by each customer ?

select m.product_name,s.customer_id,count(*) as no_of_times_purchased
from sales s 
inner join menu m
on m.product_id=s.product_id
group by m.product_name,s.customer_id
order by s.customer_id,no_of_times_purchased desc;

#What is the most purchased item on the menu and how many times was it purchased by each customer?
with cte1 as(select m.product_name,m.price,s.customer_id,s.order_date,s.product_id ,
dense_rank() over(order by s.product_id desc) as ranks
from sales as s 
join menu as m
on m.product_id = s.product_id),
cte2 as 
(select product_id,count(*) from cte1 group by product_id ) 
select product_name,customer_id,count(*)
from cte1
where ranks=1
group by PRODUCT_NAME,customer_id ;


# Which item was the most popular for each customer?

with cte1 as(
select m.product_name,s.customer_id,count(*) as total_units
from sales as s 
join menu as m
on m.product_id = s.product_id
group by s.customer_id , m.product_name) ,
cte2 as(
select * , dense_rank() over (partition by customer_id order by total_units desc) as ranks
from cte1)
select customer_id,product_name,total_units
 from cte2 
 where ranks =1 ;
 
 
 # Which item was purchased first by the customer after they became a member?
 
 with cte1 as(
select me.product_name,me.price,s.customer_id,s.order_date,s.product_id,m.join_date ,
 dense_rank() over(partition by s.customer_id order by s.order_date asc) as ranks
from sales as s
join members as m
on m.customer_id = s.customer_id
join menu as me
on me.product_id = s.product_id
where s.order_date >= m.join_date)
select customer_id,product_name , order_date , join_date
from cte1 where ranks =1; 



# Which item was purchased just before the customer became a member?
with cte1 as(
select me.product_name,me.price,s.customer_id,s.order_date,s.product_id,m.join_date ,
 dense_rank() over(partition by s.customer_id order by s.order_date desc) as ranks
from sales as s
join members as m
on m.customer_id = s.customer_id
join menu as me
on me.product_id = s.product_id
where s.order_date <= m.join_date)
select  customer_id,product_name , order_date , join_date
from cte1
 where ranks =1; 

 






