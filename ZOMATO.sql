use zomato

# Q1: What is the total amount each customer spent on Zomato?
select 
s.userid, sum(p.price) as spent_amount
from sales s
inner join product p on  s.product_id = p.product_id
group by 1


# Q2: How many days each customer visited Zomato?
select userid,
count(distinct created_date) as visited_date
from sales
group by userid

# Q:3: What is the first product purchased by each of the customer?
select * from 
(select *,
rank() over(partition by userid order by created_date) as `rank`
from sales) a where `rank` = 1


# Q4: what is most purchased item on the menu and how many times was it purchased by all the customer?
select userid, count(product_id) from sales 
where product_id = 
(select product_id 
from sales
group by product_id
order by count(product_id) desc
limit 1) 
group by userid


# Q5: Which item was most favorate from each of the cusrtomer?
select * from 
(select *,
rank() over(partition by userid order by cnt desc) `rank` from
(select userid,product_id, count(product_id) cnt
from sales
group by 1, 2)a)b
where `rank` =1

# Q6: which item was first purchased by the customer after they beacome a member?
select* from (
select a.*, rank() over(partition by userid order by created_date)`rank` from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales as s
inner join goldusers_signup as g 
on s.userid =g.userid and created_date >= gold_signup_date) as a) b
where `rank` = 1



# Q7: Which item was purchased  just before the customer become a member?
select* from (
select a.*, rank() over(partition by userid order by created_date desc)`rank` from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales as s
inner join goldusers_signup as g 
on s.userid =g.userid and created_date <= gold_signup_date) as a) b
where `rank` = 1


# Q8: What is the total order and amount spent for each member before they become a member?
select userid, count(created_date) as order_purchased, sum(price)as total_amount_spent from
(select a.*, b.price from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales as s
inner join goldusers_signup as g 
on s.userid =g.userid and created_date <= gold_signup_date)a 
inner join product b 
on a.product_id = b.product_id)c
group by userid


# Q9:  If buying each products generates points for eg 5rs = 2 Zomato points and
each  each product has diferent purchasinng points for eg. p1 5rs=1 Zomato point, for p2 
10rs=5 Zomato point and p3 5rs=1 Zomato point
Calculate points collect by each customer and for which product most points has been given till now>
select userid, sum(total_points) * 2.5 as total_points_earned from 
(select c.*, amount/ points as total_points from
(select b.*, case when product_id = 1 then 5
when product_id = 2 then 2
when product_id=3 then 5 
else 0 end as  points from
(select a.userid, a.product_id, sum(price) as amount from
(select s.*, p.price
from sales as s
inner join product as p
on s.product_id = p.product_id)a
group by userid, product_id)b)c)d
group by userid

# Q10: In the first one year after a customer joins the gold program (including their join date) irrespective
of what the customer has purchased they earn 5 zomato points for every 10 rs spent who earned more 1 or 3
and what was their points earnings in thier first yr?
1 zp=2rs
0.5 zp 1rs
select c.*,d.price * 0.5 total_points_earned from
(select a.userid, a.created_date,a.product_id, b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date and DATEDIFF(CREATED_DATE,Gold_signup_date)<=365)c
inner join product d on c.product_id=d.product_id;


#Rank all transactions of the customer?
select *, rank() over(partition by userid order by created_date) from sales


#Rank all the transactions for each member whenever they are a zomato gold member for every non gold member transction mark as na
select e.*, case when rnk=0 then 'na' else rnk end as rnkk from
(select c.*,cast((case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc) end) as varchar) as rnk 
from (select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a 
left join goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date)c)e;