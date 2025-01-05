

--(Slide No.4)


--** Creating orders_copy table from orders table and added 3 new columns **--


select *  into orders_copy from Orders

select*from orders_copy



alter table orders_copy
add previous_count int,net_quantity int,net_amount float

--------------------------------------------------**--------------------------------------------------------
--------------------------------------------------**--------------------------------------------------------


--** Adding values in  previous_count column ,net_quantity column and net_amount column **--


update orders_copy set  previous_count=Quantity-1
from orders_copy 

update orders_copy set net_quantity=quantity-previous_count


update orders_copy set net_amount=(MRP-Discount)*net_quantity

------------------------------------------------------**-----------------------------------------------
--(Slide No.5)


/* to find the difference between net amount in orders_copy table and payment value in orderpayments
   table created orders_new table at order level(one record for one order_id) with both net amounts
   from order_copy table and payment velue from order_payment_new  table.*/

--created a new table order_payment_new for total payment value for each order_id(One order_id has one record)
--created Order_new table for order level record(One order_id has one record)


 select distinct order_id,count(payment_type) as no_of_payment_type,sum(payment_value)  as total_payment
 into order_payment_new from OrderPayments
 group by order_id


 
 --**Orders table**--
 --created a new table order_new from orders_copy with one record for each order_id(at order level)

 select distinct o.order_id,
               COUNT(DISTINCT PRODUCT_ID) AS NO_OF_PRODUCTS_PURCHASED,
			   sum(quantity) as total_quantity,
			   sum([cost per unit])as total_cost,
			   sum(mrp) as total_MRP,
			   sum(discount) as total_discount,
			   cast(sum(net_amount) as decimal(16,2))as total_amount,
			   sum(net_amount-[cost per unit]) as total_profit,
			   no_of_payment_type,
			   cast(total_payment as decimal(16,2)) as total_payment
			   
 into orders_new
 from orders_copy as o
 left join Order_Payment_new as op
 on o.order_id=op.order_id
 group by o.order_id,no_of_payment_type,
			   total_payment
 




--**created new column in orders_copy table named 'diff_bw_net_payment_amt' and set the values**

alter table orders_copy add diff_bw_net_payment_amt float

update orders_copy set orders_copy.diff_bw_net_payment_amt = abs(orders_new.total_amount-orders_new.total_payment) 
from orders_new, orders_copy
where orders_new.order_id=orders_copy.order_id



--** deleted records from orders_copy table where diff_bw_net_payment_amt>0.10 **


delete from orders_copy
where diff_bw_net_payment_amt>0.10


--** deleted the order_id which is not present in orderpayment table

delete from orders_copy
where order_id not in(select order_id from orderpayments)

--------------
select distinct o.order_id
from orders_copy as o
left join OrderPayments as p 
on o.order_id=p.order_id
where p.order_id is null 
---------------------------------------------------**------------------------------------------------------
--(Slide No.6)


--** Creating stores_info_new table from stores_info table for removing duplicate value **--

select Distinct * into stores_info_new
from ['Stores_Info']

---------------------------------------------------**------------------------------------------------------

 --**Replacing  the #N/A value of category column in products_info table by others **--

update Products_Info set Category='others'
where Category='#N/A'

select *
from Products_Info
where Category='others'


-------------------------------------------------------**------------------------------------------------
-------------------------------------------------------**------------------------------------------------

 --(Slide No.7)


 --searched order_id with multiple customer_id

select order_id,count(distinct customer_id)as total_count
from orders
group by order_id
having  count(distinct customer_id)>1



----searched customer ids for the above order_ids

select distinct order_id, customer_id
from orders
where order_id in('001ab0a7578dd66cd4b0a71f5b6e1e41','001d8f0e34a38c37f7dba2a37d4eba8b',
     '003324c70b19a16798817b2b3640e721','003f201cdd39cdd59b6447cff2195456',
	 '005d9a5423d47281ac463a968b3936fb')
 


--** Replacing the multiple customer_id against one order_id by the latest customer_id of that oreder_id **--

update orders_copy set Customer_id='8597290755'
where order_id='001ab0a7578dd66cd4b0a71f5b6e1e41'

update orders_copy set Customer_id='7341229049'
where order_id='001d8f0e34a38c37f7dba2a37d4eba8b'


update orders_copy set Customer_id='8420327284'
where order_id='003324c70b19a16798817b2b3640e721'

update orders_copy set Customer_id='2783002666'
where order_id='003f201cdd39cdd59b6447cff2195456'


update orders_copy set Customer_id='2820963182'
where order_id='005d9a5423d47281ac463a968b3936fb'


select count(distinct customer_id)
from orders_copy

------------------------------------------------------**---------------------------------------------------
--searched order_ids with multiple store_id

select count(*) 
from(
select order_id, count(order_id) as total_count
from orders
group by order_id
having count(distinct delivered_StoreID)>1) as y

------------------------------------------------------****--------------------------------------------------
-----------------------------------------------------****-------------------------------------------------------

--**Replacing multiple delivered_storeid against one order_id by latest delivered_storeid of that order_id**--

select * into orders_copy2 from(select * from  (select *,max(quantity)over(partition by order_id) as max_quantity
from orders_copy) as x)as y where Quantity=max_quantity

select* from orders_copy2

update orders_copy set orders_copy.Delivered_StoreID=orders_copy2.Delivered_StoreID
from orders_copy,orders_copy2
where orders_copy.order_id=orders_copy2.order_id


select order_id from orders_copy
group by order_id
having count(distinct delivered_storeid)>1


----------------------------------------------**-----------------------------------------------------------
----------------------------------------------**-----------------------------------------------------------
--**Replacing multiple bill_date against one order_id by latest bill_date of that order_id**--

--created orders_copy2 table by selecting latest record(max quantity) for each order_id from orders table


select* from orders_copy2

update orders_copy set orders_copy.Bill_date_timestamp=orders_copy2.Bill_date_timestamp
from orders_copy,orders_copy2
where orders_copy.order_id=orders_copy2.order_id


----------------------------------------------------**---------------------------------------------------------
----------------------------------------------------**-----------------------------------------------------------

--(Slide No.8)

/* ## Creating orderReview_ratings_copy table with average customer_satisfaction_score against one order_id 
      from orderReview_ratings table ## */

select distinct order_id,avg(Customer_Satisfaction_Score)over(partition by order_id) as Customer_Satisfaction_Score
into orderReview_ratings_copy from OrderReview_Ratings

alter table orderReview_ratings_copy
alter column  Customer_Satisfaction_Score int

--------------------------------------------------**---------------------------------------------------------


--** Changing the datatype of bill_date_timestamp table **--


alter table orders_copy
alter column Bill_date_timestamp datetime



---------------------------------------------------**-------------------------------------------------------
----------------------------------------------------**----------------------------------------------------------



--** Creating Bill_date column in orders_copy table with only date part from bill_date_timestamp**--


ALTER TABLE ORDERS_COPY
ADD  BILL_DATE DATE

UPDATE orders_copy SET BILL_DATE=cast(bill_date_timestamp as date)


-------------------------------------------------------**----------------------------------------------------
--------------------------------------------------------**----------------------------------------------------

-- ** Detailed exploratory data analysis ** --

--(Slide No.13)

-- Number of customers

SELECT COUNT(DISTINCT Custid) AS TOTAL_CUSTOMER
FROM Customers

SELECT COUNT(DISTINCT Customer_id) AS TOTAL_CUSTOMER
FROM orders_copy

--Number of orders

SELECT COUNT(DISTINCT order_id) AS TOTAL_ORDERS
FROM orders_copy

--Total Revenue

SELECT SUM(net_amount) AS TOTAL_revenue
FROM orders_copy

-- Total products

SELECT COUNT(DISTINCT PRODUCT_ID) AS TOTAL_PRODUCTS
FROM Products_Info

select count(distinct product_id) 
from orders_copy

--Total categories

SELECT COUNT(DISTINCT Category) AS TOTAL_CATEGORY
FROM Products_Info



--Total stores

SELECT COUNT(DISTINCT STOREID) AS TOTAL_stores
FROM ['Stores_Info']

SELECT COUNT(DISTINCT Delivered_StoreID) AS TOTAL_stores
FROM orders_copy


--(Slide No.14)


--Total discount

SELECT SUM(DISCOUNT) AS TOTAL_DISCOUNT
FROM orders_copy



--Total Profit

SELECT SUM(NET_AMOUNT-[Cost Per Unit]) AS TOTAL_PROFIT
FROM orders_copy

--Total Cost

SELECT SUM([Cost Per Unit])AS TOTAL_COST
FROM orders_copy

--Total quantity

SELECT SUM(NET_QUANTITY)AS TOTAL_QUANTITY
FROM orders_copy



--Total locations

SELECT COUNT(DISTINCT customer_city) AS CUSTOMER_LOCATION
FROM Customers as c
inner join orders_copy as o
on c.Custid=o.Customer_id

SELECT COUNT(DISTINCT seller_city) AS STORE_LOCATION
FROM stores_info_new as s
inner join orders_copy as o
on s.StoreID=o.Delivered_StoreID



--Total Regions

SELECT COUNT(DISTINCT REGION) AS TOTAL_REGION
FROM ['Stores_Info']

--Total channels

SELECT COUNT(DISTINCT Channel) AS TOTAL_channel
FROM orders_copy

--Total payment methods

SELECT COUNT(DISTINCT payment_type) AS TOTAL_payment_method
FROM OrderPayments


--(Slide No.15)

--Average discount per customer

select sum(total_discount)/count(customer_id) as avg_discount
from (
select Customer_id,sum(discount) as total_discount
from orders_copy
group by Customer_id) as x

--Average discount per order

select sum(total_discount)/count(order_id)
from (
select order_id,sum(discount) as total_discount
from orders_copy
group by order_id) as x



--Average Sales per Customer

Select sum(total_sales)/count(customer_id) as avg_sales_per_customer
from(
SELECT Customer_id,sum(NET_AMOUNT) AS Total_SALES
FROM orders_copy
GROUP BY Customer_id) as x

--Average profit per customer

Select sum(total_profit)/count(customer_id) as avg_profit_per_customer
from(
SELECT Customer_id,sum(NET_AMOUNT-[Cost Per Unit]) AS Total_profit
FROM orders_copy
GROUP BY Customer_id) as x

--(Slide No.16)

--Average order value or Average Bill Value

select SUM(NET_AMOUNT)/COUNT(DISTINCT ORDER_ID) AS AVERAGE_ORDER_VALUE
from orders_copy


--average number of categories per order

SELECT  1.00*sum(NO_OF_CATEGORIES)/count(order_id)  AS AVG_NO_OF_CATEGORIES
FROM(
SELECT order_id,COUNT( DISTINCT Category) AS NO_OF_CATEGORIES
FROM orders_copy AS OC
INNER JOIN Products_Info AS P
ON OC.product_id=P.product_id

GROUP BY order_id

) AS X

--average number of items per order

SELECT  1.00*sum(NO_OF_ITEMS)/count(order_id) AS AVG_NO_OF_ITEMS
FROM(
SELECT order_id,SUM(net_quantity) AS NO_OF_ITEMS
FROM orders_copy 


GROUP BY order_id

) AS X





--Transactions per Customer

Select 1.00*sum(total_transactions)/count(customer_id)
from(
SELECT Customer_id,count(DISTINCT ORDER_ID) AS TOTAL_TRANSACTIONS
FROM orders_copy
GROUP BY Customer_id) as x



--(Slide no.17)



-- percentage of profit


 SELECT (SUM(NET_AMOUNT-[Cost Per Unit])*100)/SUM([Cost Per Unit])AS PERCENTAGE_PROFIT
FROM orders_copy

--percentage of discount

SELECT (SUM(DISCOUNT)*100)/SUM(MRP) AS PERCENTAGE_DISCOUNT
FROM orders_copy

--Repeat customer percentage

SELECT CAST((COUNT(REPEATED_CUSTOMERS)*100.00)/(SELECT COUNT(DISTINCT CUSTOMER_ID)FROM orders_copy) AS FLOAT)
FROM(
SELECT CUSTOMER_ID AS REPEATED_CUSTOMERS,COUNT(DISTINCT ORDER_ID) AS DISTINCT_ORDER_COUNT
FROM orders_copy
GROUP BY Customer_id
HAVING COUNT(DISTINCT ORDER_ID)>1
)
AS X



--One time buyers percentage

SELECT CAST((COUNT(ONE_TIME_CUSTOMER)*100.00)/(SELECT COUNT(DISTINCT CUSTOMER_ID)FROM orders_copy) AS FLOAT)
FROM(
SELECT CUSTOMER_ID AS ONE_TIME_CUSTOMER,COUNT(DISTINCT ORDER_ID) AS DISTINCT_ORDER_COUNT
FROM orders_copy
GROUP BY Customer_id
HAVING COUNT(DISTINCT ORDER_ID)=1
)
AS X


--(Slide No.18)

--Understanding how many new customers acquired every month (who made transaction first time in the data)

select distinct month_no,months,years,count(customer_id) new_customer_each_Month
from(
select Customer_id,month(first_purchase_date) as month_no,
       datename(month,first_purchase_date) as months,year(first_purchase_date) as years
from(

select Customer_id,min(bill_date) as first_purchase_date
from orders_copy
group by Customer_id

) as x) as y
group by month_no,months,years
order by years,month_no

--(Slide No.19)

--Revenue from new customers on monthly basis

select month(bill_date) as month_no, year(bill_date) as years,
DATENAME(month, BILL_DATE) as month_name, sum(net_amt) as total_amt
from(
select bill_date, net_amt
from(
select Customer_id, bill_date, min(bill_date) over(partition by customer_id) as min_bill_date, 
net_amount as net_amt
from orders_copy
) as x
where bill_date=min_bill_date)as y
group by month(bill_date), year(bill_date), DATENAME(month, BILL_DATE)
order by year(bill_date), month(bill_date)

--(Slide No.20)

--Revenue from existing customers on monthly basis

select month(bill_date) as months_no, year(bill_date) as years,
DATENAME(month, BILL_DATE) month_name, sum(net_amt) as total_amt
from(
select bill_date, net_amt
from(
select Customer_id, bill_date, min(bill_date) over(partition by customer_id) as min_bill_date, 
net_amount as net_amt
from orders_copy
) as x
where bill_date>min_bill_date) as y
group by month(bill_date), year(bill_date), DATENAME(month, BILL_DATE)
order by year(bill_date), month(bill_date)


--(Slide No.21)

--Understand the retention of customers on month on month basis 


select month(this_month.bill_date) as month_no, datename(month,this_month.BILL_DATE) as months,
               year(this_month.BILL_DATE) as years,
           count(distinct last_month.Customer_id) as month_on_month_retention_of_customers
from orders_copy as this_month
left join orders_copy as last_month
on this_month.Customer_id=last_month.Customer_id 
          and
    datediff(month,last_month.bill_date,this_month.bill_date)=1
group by month(this_month.bill_date),datename(month,this_month.BILL_DATE),year(this_month.BILL_DATE)
order by years,month_no

--(Slide No.22)

--List the top 10 most expensive products sorted by price and their contribution to sales

 select top 10 o.product_id,category, MRP, 
  sum(net_amount)over(partition by o.product_id) as sales_amount,
 cast(sum(net_amount)over(partition by o.product_id)*100/sum(net_amount)over()as decimal(16,2)) as percent_contribution
 from orders_copy o
 join
 Products_Info p
 on o.product_id=p.product_id
 order by mrp desc




--(Slide No.23)

-- Top 10-performing & worst 10 performance stores in terms of sales--

 --top 10 stores

 select distinct top 10 Delivered_StoreID as top_stores, 
 sum(net_amount) over(partition by  Delivered_StoreID) as sales,
 cast(sum(net_amount) over(partition by  Delivered_StoreID)*100/sum(net_amount) over() as decimal(16,2)) as percent_contri
 from
 orders_copy
 order by sales desc

 --worst 10 stores

 select distinct top 10 Delivered_StoreID as worst_stores, 
 sum(net_amount) over(partition by  Delivered_StoreID) as sales,
 cast(sum(net_amount) over(partition by  Delivered_StoreID)*100/sum(net_amount) over() as decimal(16,2)) as percent_contri
 from
 orders_copy
 order by sales


 --(Slide No.24-26)

 

--Popular categories/Popular Products by store, state, region. 


--**product**
--region
select *
from(

select region,o.product_id,category,sum(net_amount) as total_sales,
       rank()over(partition by region order by sum(net_amount) desc) as rn
      
from orders_copy as o
inner join stores_info_new as s
on o.Delivered_StoreID=s.StoreID
inner join Products_Info as p
on o.product_id=p.product_id
group by region,o.product_id,category) as x
 where rn<=5

--seller State
 select *
from(

select seller_state,o.product_id, category, sum(net_amount) as total_sales,
       row_number()over(partition by seller_state order by sum(net_amount) desc) as rn
      from orders_copy as o
inner join stores_info_new as s
on o.Delivered_StoreID=s.StoreID
join
 Products_Info as p
 on o.product_id=p.product_id
group by seller_state,o.product_id, Category) as x
 where rn=1

  
--Store
select *
from(

select Delivered_StoreID,product_id,sum(net_amount) as total_sales,
       rank()over(partition by Delivered_StoreID order by sum(net_amount) desc) as rn
      

from orders_copy 

group by Delivered_StoreID,product_id) as x
 where rn<=5


 --**Category**--

--region
select *
from(

select region,category,sum(net_amount) as total_sales,
       rank()over(partition by region order by sum(net_amount) desc) as rn
      
from orders_copy as o
inner join stores_info_new as s
on o.Delivered_StoreID=s.StoreID
inner join Products_Info as p
on o.product_id=p.product_id
group by region,category) as x
 where rn<=1

--seller State
 select *
from(

select seller_state,category,sum(net_amount) as total_sales,
       rank()over(partition by seller_state order by sum(net_amount) desc) as rn
      

from orders_copy as o
inner join stores_info_new as s
on o.Delivered_StoreID=s.StoreID
inner join Products_Info as p
on o.product_id=p.product_id
group by seller_state,category) as x
 where rn<=1
 
--Store

select *
from(

select Delivered_StoreID,category,sum(net_amount) as total_sales,
       rank()over(partition by Delivered_StoreID order by sum(net_amount) desc) as rn
      

from orders_copy as o
inner join Products_Info as p
on o.product_id=p.product_id

group by Delivered_StoreID,category) as x
 where rn<=5


 
--(Slide No.27)

--Average number of days between two transactions (if the customer has more than one transaction)

SELECT  CUSTOMER_ID,AVG(DIFF_OF_DAYS) AS AVG_DAYS
FROM(

SELECT Customer_id,LAG(Bill_date_timestamp,1) OVER(PARTITION BY CUSTOMER_ID ORDER BY Bill_date_timestamp) 
       AS PREVIOUS_DATE,
	   DATEDIFF(DAY,LAG(Bill_date_timestamp,1) OVER(PARTITION BY CUSTOMER_ID ORDER BY Bill_date_timestamP),
	            Bill_date_timestamp) AS DIFF_OF_DAYS
FROM (SELECT DISTINCT CUSTOMER_ID,ORDER_ID,Bill_date_timestamp FROM orders_copy )AS Y)
AS X
WHERE DIFF_OF_DAYS IS NOT NULL
GROUP BY CUSTOMER_ID




 --Which products appeared in the transactions?

 select distinct product_id
 from orders_copy


----------------------------------------------------**--------------------------------------------------------
-----------------------------------------------------**---------------------------------------------------------

--(Slide No. 53-58)

--**Understand the trends/seasonality of sales**--
     

--Q1.seasonality sales - month-wise

select *,cast(sales*100/sum(sales)over() as decimal(20,2)) as percent_contribution
from(
select month(bill_date) as month_no,datename(month,BILL_DATE) as months,
       cast(sum(net_amount) as decimal(16,2)) as sales
from orders_copy
group by month(bill_date),datename(month,BILL_DATE)
) as x
order by percent_contribution desc


--Q2.seasonality sales - quarter_wise

select *,cast(sales*100/sum(sales)over() as decimal(20,2)) as percent_contribution
from(
select datename(quarter,BILL_DATE) as quarters,
       cast(sum(net_amount) as decimal(16,2)) as sales
from orders_copy
group by datename(quarter,BILL_DATE)
) as x
order by percent_contribution desc


--Q3.seasonality sales - day_wise

select *,cast(sales*100/sum(sales)over() as decimal(20,2)) as percent_contribution
from(
select datename(dw,BILL_DATE) as [days],
       cast(sum(net_amount) as decimal(16,2)) as sales
from orders_copy
group by datename(dw,bill_date)
) as x
order by percent_contribution desc


--Q4.seasonality sales - weekday and weekend_wise


select  distinct weekend_flag,cast(sum(net_amount)over(partition by weekend_flag) as decimal(16,2)) as sales,
    cast(sum(net_amount)over(partition by weekend_flag)*100/sum(net_amount)over() as decimal(16,2)) as percent_sales       
from(
select net_amount,
  CASE WHEN DATEPART(DW,BILL_DATE) IN(1,7)
          THEN 'weekend'
       ELSE 'weekdays' 
    end as weekend_flag
from orders_copy) as x



--Q5.Sales trend -week-wise

select *,cast(sales*100/sum(sales)over() as decimal(20,3)) as percent_contribution
from(
select year(bill_date) as years, datepart(week,BILL_DATE) as weeks,
       cast(sum(net_amount) as decimal(16,2)) as sales
from orders_copy
group by year(bill_date), datepart(week,bill_date)
) as x

order by sales


--Q6.Sales trend -month-wise

select *,cast(sales*100/sum(sales)over() as decimal(20,3)) as percent_contribution
from(
select year(bill_date) as years, month(bill_date) as month_no,datename(month,BILL_DATE) as months,
       cast(sum(net_amount) as decimal(16,2)) as sales
from orders_copy
group by year(bill_date), month(bill_date),datename(month,BILL_DATE)
order by year(bill_date), month(bill_date)
) as x



--Q7.Sales trend- year-wise

select *,cast(sales*100/sum(sales)over() as decimal(20,3)) as percent_contribution
from(
select year(bill_date) as years,
       cast(sum(net_amount) as decimal(16,2)) as sales
from orders_copy
group by year(bill_date)
) as x


----------------------------------------------------**--------------------------------------------------------
-----------------------------------------------------**--------------------------------------------------------


--**Customer behaviour analysis**--

--Create a new table 'customer_new with one record for each customer


SELECT DISTINCT Customer_id,COUNT(DISTINCT order_id)AS NO_OF_ORDERS,COUNT(DISTINCT PRODUCT_ID) AS TOTAL_PRODUCTS_PURCHASED,
                COUNT(DISTINCT DELIVERED_STOREID) AS TOTAL_STORES,SUM(NET_QUANTITY) AS TOTAL_QUANTITY,SUM(DISCOUNT) AS TOTAL_DISCOUNT,
				SUM(NET_AMOUNT) AS TOTAL_NET_AMOUNT,MAX(BILL_DATE) AS LATEST_BILLDATE,
				sum(MRP) as total_MRP,sum([cost per unit]) as total_cost
				
INTO CUSTOMER_NEW
FROM ORDERS_COPY
GROUP BY Customer_id

SELECT * FROM CUSTOMER_NEW


ALTER TABLE CUSTOMER_NEW
ADD CUSTOMER_CITY NVARCHAR(255), CUSTOMER_STATE NVARCHAR(255),GENDER NVARCHAR(255)

UPDATE CUSTOMER_NEW SET CUSTOMER_NEW.CUSTOMER_CITY=Customers.customer_city,
					  CUSTOMER_NEW.CUSTOMER_STATE=Customers.customer_STATE,
                      CUSTOMER_NEW.GENDER=CUSTOMERS.GENDER
FROM CUSTOMER_NEW,Customers
WHERE CUSTOMER_NEW.Customer_id=Customers.Custid

------------------------------------------------**--------------------------------------------------------------

--(Slide No.29-36)

--Q1.Segment the customers (divide the customers into groups) based on the revenue


select distinct segmentation,count(customer_id) over (partition by segmentation) as total_customer,
        
         sum(TOTAL_NET_AMOUNT) over (partition by segmentation) as total_sales,
		 sum(TOTAL_NET_AMOUNT) over (partition by segmentation)*100/sum(total_net_amount) over() as perc_contri,
        avg(TOTAL_NET_AMOUNT) over (partition by segmentation) as avg_sales
from(

select *,case when sales=1 then  '1'
            when sales=2 then '2'
			when sales=3 then  '3'
			else '4' end as segmentation
from(
select customer_id,gender,TOTAL_NET_AMOUNT,
       ntile(4)over(order by TOTAL_NET_AMOUNT desc) as sales
from CUSTOMER_NEW ) as x) as y
order by total_sales desc


--Q2.** RFM Segmentation ANALYSIS **--


WITH RFM_BASE
AS(
SELECT CUSTOMER_ID,DATEDIFF(DAY,LATEST_BILLDATE,GETDATE()) AS DAYS_SINCE_LAST_PURCHASED,
       NO_OF_ORDERS ,TOTAL_NET_AMOUNT
	    
FROM CUSTOMER_NEW
),
--Calculate score of Recency, Frequency and Monetary
RFM AS(
SELECT *,NTILE(4)OVER(ORDER BY DAYS_SINCE_LAST_PURCHASED DESC)AS RECENCY_SCORE,
        CASE WHEN 
		         NO_OF_ORDERS <4
              THEN 1
			  WHEN NO_OF_ORDERS<7
			  THEN 2
			  WHEN NO_OF_ORDERS<10
			  THEN 3
			  ELSE 4
       END AS FREQUENCY_SCORE,
		NTILE(4)OVER(ORDER BY  TOTAL_NET_AMOUNT ASC)AS MONETARY_SCORE

FROM RFM_BASE),
--Calculate combined RFM score
COMBINE_RFM AS(

SELECT *,(RECENCY_SCORE+FREQUENCY_SCORE+MONETARY_SCORE)*1.00/3 AS RFM_SCORE
FROM RFM),
--Segmentation of customer in Premium, Gold, Silver and Standard
RFM_SEGMENTATION AS(
SELECT *,
         CASE WHEN 
		         RFM_SCORE <=1
              THEN 'STANDARD'
			  WHEN RFM_SCORE >1 and RFM_SCORE<=2
			  THEN 'SILVER'
			  WHEN RFM_SCORE >2 and RFM_SCORE<=3
			  THEN 'GOLD'
			  ELSE 'PREMIUM'
         END AS RFM_SEGMENT
FROM COMBINE_RFM)
SELECT distinct RFM_SEGMENT,COUNT(CUSTOMER_ID) over(partition by RFM_SEGMENT) AS TOTAL_CUSTOMER ,
	    CAST(SUM(TOTAL_NET_AMOUNT) over(partition by RFM_SEGMENT) AS DECIMAL(16,2)) AS TOTAL_SALES,
		cast(SUM(TOTAL_NET_AMOUNT)over(partition by RFM_SEGMENT)*100/SUM(TOTAL_NET_AMOUNT)OVER() as decimal(16,2)) as Perc_contri,
        CAST(AVG(TOTAL_NET_AMOUNT) over(partition by RFM_SEGMENT) AS DECIMAL(12,2)) AS AVG_SALES
FROM RFM_SEGMENTATION

ORDER BY Total_sales DESC

 
 

--Q3.Find out the number of customers who purchased in all the channels and find the key metrics.

select count(customer_id) as total_customer,sum(no_of_orders) as no_of_orders, 
	   sum(total_sales) as total_sales,
       avg(avg_sales) as avg_sales,sum(total_discount) as total_discount,
	   sum(total_qty)as total_qty,sum(total_profit) as total_profit
	   from(
select customer_id, count(distinct order_id) as no_of_orders, sum(net_amount) as total_sales,
	   avg(net_amount) as avg_sales,
       sum(discount) as total_discount,
	   sum(quantity) as total_qty,sum(net_amount-[cost per unit]) as total_profit
	   
from orders_copy
group by customer_id
having count(distinct channel)=3) as x


--Q4.Understand the behavior of one time buyers and repeat buyers

select 'one_time_buyers' as types_of_customers,count(customer_id) as total_customers,
          cast(sum(TOTAL_NET_AMOUNT) as decimal(16,2)) as total_sales,
          cast(avg(TOTAL_NET_AMOUNT)as decimal(16,2)) as avg_sales,
        cast(sum(TOTAL_DISCOUNT)as decimal(16,2)) as total_discount,
		cast(avg(TOTAL_DISCOUNT)as decimal(16,2)) as avg_discount,
		cast(sum(total_discount)*100/sum(total_mrp) as decimal(16,2)) as dis_percent,
		cast(sum(TOTAL_NET_AMOUNT-total_cost)as decimal(16,2)) as profit

from CUSTOMER_NEW 
where NO_OF_ORDERS=1

union

select  'repeated_buyers' as types_of_customers,count(customer_id) as total_customers,
          cast(sum(TOTAL_NET_AMOUNT) as decimal(16,2)) as total_sales,
          cast(avg(TOTAL_NET_AMOUNT)as decimal(16,2)) as avg_sales,
        cast(sum(TOTAL_DISCOUNT)as decimal(16,2)) as total_discount,
		cast(avg(TOTAL_DISCOUNT)as decimal(16,2)) as avg_discount,
		cast(sum(total_discount)*100/sum(total_mrp) as decimal(16,2)) as dis_percent,
		cast(sum(TOTAL_NET_AMOUNT-total_cost)as decimal(16,2)) as profit

from CUSTOMER_NEW 
where NO_OF_ORDERS>1


--Q5.  Understand the behaviour of discount seeker and non-discount seeker

select  'non-discount seekers' as types_of_customers, count(customer_id) as total_customers,
        cast(sum(TOTAL_NET_AMOUNT) as decimal(16,2)) as total_sales,
        cast(avg(TOTAL_NET_AMOUNT)as decimal(16,2)) as avg_sales,
        cast(sum(TOTAL_NET_AMOUNT-total_cost)as decimal(16,2)) as profit
from CUSTOMER_NEW
where TOTAL_DISCOUNT=0

Union

select  'discount seekers' as types_of_customers, count(customer_id) as total_customers,
        cast(sum(TOTAL_NET_AMOUNT) as decimal(16,2)) as total_sales,
        cast(avg(TOTAL_NET_AMOUNT)as decimal(16,2)) as avg_sales,
        cast(sum(TOTAL_NET_AMOUNT-total_cost)as decimal(16,2)) as profit
from CUSTOMER_NEW
where TOTAL_DISCOUNT>0


--Q6. Understand preferences of customers (preferred channel, Preferred payment method, preferred store, 
-- preferred categories etc.)

--channel
select Channel as preferred_channel, count(customer_id) no_of_customer from
orders_copy
group by Channel
order by count(customer_id) desc

--payment method

select payment_type as payment_method, count(customer_id) no_of_customer
from orders_copy as OC
join
OrderPayments as OP
on oc.order_id=op.order_id
group by payment_type
order by count(customer_id) desc

--store
select top 5 Delivered_StoreID as preferred_store, count(customer_id) no_of_customer
from orders_copy
group by Delivered_StoreID
order by count(customer_id) desc

--preferred categories

select top 5 Category as preferred_categories, count(customer_id) no_of_customer
from orders_copy as OC
join
Products_Info as P
on oc.product_id=P.product_id
group by Category
order by count(customer_id) desc


--Q7. Understand the behavior of customers who purchased one category and purchased multiple categories

select *, total_sales*100/sum(total_sales)over() as perc_contri_sales,
	   profit*100/sum(profit)over() as per_contri_prfit
from(
-- one category
 select 'one_cat_cust' as customer_type, count( distinct customers) no_of_cust, sum(total_sales) total_sales, sum(total_sales)/count(customers) avg_sales,
		sum(total_discount) discount, sum(profit) profit
 from(
 select distinct o.Customer_id as customers, count(o.product_id) total_prod, count(category) total_cat,
				sum(net_amount) as total_sales,
				sum(discount) total_discount, sum(net_amount-[cost per unit])  profit from 
 orders_copy as O
 join
 Products_Info as P
 on O.product_id=P.product_id
 group by o.Customer_id
 having count(distinct category)=1) as x

 union

 --mulitple categories
  select 'multi_cat_cust' as customer_type, count(distinct customers) no_of_cust, sum(total_sales) as total_sales,  sum(total_sales)/count(customers) as avg_sales,
		sum(total_discount) as discount, sum(profit) as profit
 from(
 select distinct o.Customer_id as customers, count(o.product_id) total_prod, count(category) total_cat, 
				sum(net_amount) as total_sales, 
				sum(discount) total_discount, sum(net_amount-[cost per unit])  profit from 
 orders_copy as O
 join
 Products_Info as P
 on O.product_id=P.product_id
 group by o.Customer_id
 having count(distinct category)>1) as y
 ) as x



 --Q8. --**Gender analysis**--

 --overall buyers--

 select distinct gender,count(customer_id)over(partition by gender) as total_cust,
 sum(total_net_amount)over(partition by gender) as sales,
 sum(total_net_amount)over(partition by gender)*100/sum(total_net_amount)over()as percent_sales,
 sum(total_net_amount-total_cost)over(partition by gender)as profit, 
 sum(total_net_amount-total_cost)over(partition by gender)*100/sum(total_net_amount-total_cost)over() as percent_profit
 from CUSTOMER_NEW

 ---------
 --**One_time buyer**--
 select distinct gender,count(customer_id)over(partition by gender) as total_cust,
 sum(total_net_amount)over(partition by gender) as sales,
 sum(total_net_amount)over(partition by gender)*100/sum(total_net_amount)over()as percent_sales,
 sum(total_net_amount-total_cost)over(partition by gender)as profit, 
 sum(total_net_amount-total_cost)over(partition by gender)*100/sum(total_net_amount-total_cost)over() as percent_profit
 from CUSTOMER_NEW
 where NO_OF_ORDERS=1

  --**Repeated buyer**--
 select distinct gender,count(customer_id)over(partition by gender) as total_cust,
 sum(total_net_amount)over(partition by gender) as sales,
 sum(total_net_amount)over(partition by gender)*100/sum(total_net_amount)over()as percent_sales,
 sum(total_net_amount-total_cost)over(partition by gender)as profit, 
 sum(total_net_amount-total_cost)over(partition by gender)*100/sum(total_net_amount-total_cost)over() as percent_profit
 from CUSTOMER_NEW
 where NO_OF_ORDERS>1
 
 -----------------------------------------------------**-----------------------------------------------------------
 -----------------------------------------------------**-----------------------------------------------------------

--created a new table order_payment_new for total payment value for each order_id.One order_id has one record.
--Used to create Order_new table for order level record


 select distinct order_id,count(payment_type) as no_of_payment_type,sum(payment_value)  as total_payment
 into order_payment_new from OrderPayments
 group by order_id
 
 --**Orders table**--
 --created a new table order_new from orders_copy with one record for each order_id(at order level)

 select distinct o.order_id,
               COUNT(DISTINCT PRODUCT_ID) AS NO_OF_PRODUCTS_PURCHASED,
			   sum(quantity) as total_quantity,
			   sum([cost per unit])as total_cost,
			   sum(mrp) as total_MRP,
			   sum(discount) as total_discount,
			   cast(sum(net_amount) as decimal(16,2))as total_amount,
			   sum(net_amount-[cost per unit]) as total_profit,
			   no_of_payment_type,
			   cast(total_payment as decimal(16,2)) as total_payment
			   
 into orders_new
 from orders_copy as o
 left join Order_Payment_new as op
 on o.order_id=op.order_id
 group by o.order_id,no_of_payment_type,
			   total_payment
 

select *, total_amount-total_payment
from orders_new
where abs(total_amount-total_payment)>0.10


 ------------

 alter table orders_new
 add customer_id float

 update orders_new set orders_NEW.CUSTOMER_id=orders_copy.Customer_id
 from orders_NEW,orders_copy
 where orders_new.order_id=orders_copy.order_id

 -----------

 alter table orders_new
 add CUSTOMER_CITY NVARCHAR(255), CUSTOMER_STATE NVARCHAR(255),GENDER NVARCHAR(255)

 UPDATE orders_NEW SET orders_NEW.CUSTOMER_CITY=Customer_new.customer_city,
					  orders_NEW.CUSTOMER_STATE=Customer_new.customer_STATE,
                      orders_NEW.GENDER=CUSTOMER_new.GENDER
FROM orders_NEW,Customer_new
WHERE orders_new.Customer_id=CUSTOMER_NEW.Customer_id


---------

alter table orders_new
add delivered_storeid nvarchar(255)

UPDATE orders_NEW SET orders_NEW.delivered_storeid=orders_copy.Delivered_StoreID					  
FROM orders_NEW,orders_copy
where orders_new.order_id=orders_copy.order_id

---------

 alter table orders_new
 add seller_CITY NVARCHAR(255), seller_STATE NVARCHAR(255),region NVARCHAR(255)

 UPDATE orders_NEW SET orders_NEW.seller_CITY=stores_info_new.seller_city,
					  orders_NEW.seller_STATE=stores_info_new.seller_state,
                      orders_NEW.region=stores_info_new.Region
FROM orders_NEW,stores_info_new
WHERE orders_new.delivered_storeid=stores_info_NEW.StoreID

----------

alter table orders_new
add channel nvarchar(255),Bill_date_timestamp datetime,BILL_DATE date

UPDATE orders_NEW SET orders_NEW.channel=orders_copy.channel,
                      orders_new.bill_date_timestamp=orders_copy.Bill_date_timestamp,
					  orders_new.bill_date=orders_copy.bill_date
FROM orders_NEW,orders_copy
where orders_new.order_id=orders_copy.order_id

----

alter table orders_new
add   Customer_Satisfaction_Score int

UPDATE orders_NEW SET orders_NEw.Customer_Satisfaction_Score=orderReview_ratings_copy.Customer_Satisfaction_Score
                      
FROM orders_NEW,orderReview_ratings_copy
where orders_new.order_id=orderReview_ratings_copy.order_id
 
-------


-----------------------------------------------**--------------------------------------------------------
-----------------------------------------------**--------------------------------------------------------


--**Stores_new**--

--created a new table stores_new with one record for each 37 stores in orders_copy table

select StoreID,seller_city,seller_state,Region,count(distinct order_id) as total_order,
        count(distinct customer_id) as no_of_customer,sum(quantity) as total_quantity,
		 sum(net_amount) as total_amount,sum(net_amount-[cost per unit]) as total_profit
into stores_new
from stores_info_new as s
inner join orders_copy as o
on s.StoreID=o.Delivered_StoreID
group by StoreID,seller_city,seller_state,Region


------------------
select *
from stores_new

----------------------------------------------**--------------------------------------------------------------
-----------------------------------------------**--------------------------------------------------------------

--(Slide No.48-49)

--** Cross-Selling (two products are selling together) **--

with  CTE1 as(select order_id, product_id from orders_copy
group by order_id, product_id),
CTE2 as (select c1.order_id as orders, c1.product_id as p1,  c2.product_id as p2,
concat(c1.product_id, c2.product_id) as comb_prod
from
CTE1 as C1 
inner join
CTE1 as C2
on c1.order_id=c2.order_id and
c1.product_id>c2.product_id),
CTE3 as (select p1, p2, comb_prod from CTE2)
select  top 10 p1, p2, count(comb_prod) as frequency
from CTE3
group by p1, p2
order by frequency desc


----------------------


with  CTE1 as(select c1.order_id as orders, c1.product_id as p1,  c2.product_id as p2,
concat(c1.product_id, c2.product_id) as comb_prod
from
orders as C1 
inner join
orders as C2
on c1.order_id=c2.order_id and
c1.product_id>c2.product_id),
CTE2 as (select p1, p2, comb_prod from CTE1)
select  top 10 p1, p2, count(comb_prod) as frequency
from CTE2
group by p1, p2
order by frequency desc


----- 2 products cross selling record verification-----
select count(distinct orders) as orders from(
select o1.order_id as orders, o1.product_id as product_1, o2.product_id as product_2
from orders_copy as o1
join orders_copy as o2
on o1.Delivered_StoreID=o2.Delivered_StoreID
and o1.order_id=o2.order_id
and o1.product_id>o2.product_id
where o1.product_id='e53e557d5a159f5aa2c5e995dfdf244b' and o2.product_id='36f60d45225e60c7da4558b070ce4b60'
) as x
-----------------------------------------------------

--** Cross-Selling (three products are selling together) **--

with  CTE1 as(select order_id, product_id from orders_copy
group by order_id, product_id),
CTE2 as (select c1.order_id as orders, c1.product_id as p1, c2.product_id as p2,
c3.product_id as p3,
concat(c1.product_id, c2.product_id, c3.product_id) as comb_prod
from
CTE1 as C1 
inner join
CTE1 as C2
on c1.order_id=c2.order_id and
c1.product_id>c2.product_id
inner join
CTE1 as C3
on c1.order_id=c3.order_id and
c2.product_id>c3.product_id),
CTE3 as (select p1, p2, p3, comb_prod from CTE2)
select  top 11 p1, p2, p3, count(comb_prod) as frequency ----to show only top 10 combination has 2 or more frequency
from CTE3
group by p1, p2, p3
--having count(comb_prod)>=2
order by frequency desc

----- 3 products cross selling record verification-----
select o1.order_id, o1.product_id, o2.product_id,o3.product_id
from orders_copy as o1
join orders_copy as o2

on o1.Delivered_StoreID=o2.Delivered_StoreID
and o1.order_id=o2.order_id
and o1.product_id>o2.product_id
join orders_copy as o3
on o1.Delivered_StoreID=o2.Delivered_StoreID
and o1.order_id=o3.order_id
and o2.product_id>o3.product_id
where o1.product_id='e2cac69b319c0f8a21dbf04b925121bf' and 
o2.product_id='b9900407a55cb2b306ae612415c3340e' and
o3.product_id='55bfa0307d7a46bed72c492259921231'


-----------------------------------------------------

/* select top 10 o1.product_id,o2.product_id,count(*) as purchase_frequency
from orders_copy as o1
inner join orders_copy as o2
on o1.order_id=o2.order_id
  and
  o1.Customer_id=o2.Customer_id
  and
  o1.Delivered_StoreID=o2.Delivered_StoreID
     and
   o1.product_id<o2.product_id
group by o1.product_id,o2.product_id
order by purchase_frequency desc*/


---------------------------------------------**--------------------------------------------------------------
-----------------------------------------------**-------------------------------------------------------------

--(Slide No.38-42)
           
--**Understand the Category Behavior**--

--Q1.Total Sales & Percentage of sales by category (Perform Pareto Analysis)

select *, sum(percent_sales) over (order by percent_sales desc rows between unbounded preceding and current row) as cumulative_perc
from(
select distinct Category, sum(net_amount)over(partition by category) as total_sales, 
	   cast(sum(net_amount)over(partition by category)*100/sum(net_amount) over() as decimal(16,2)) as percent_sales
 
from
orders_copy as o
join
Products_Info as p
on o.product_id = p.product_id
) as x


--Q2.Most profitable category and its contribution

select distinct top 1 category,count(customer_id) over(partition by category) as no_of_cust,
		cast(sum(net_amount-[cost per unit]) over (partition by category)as decimal(16,2)) as profit,
        cast(sum(net_amount-[cost per unit]) over (partition by category)*100/sum(net_amount-[cost per unit]) over() as decimal(16,2)) as percent_sales,
		cast(sum(net_amount) over(partition by category) as decimal(16,2)) as total_sales
from orders_copy as o
inner join Products_Info as p
on o.product_id=p.product_id
--group by category
order by profit desc



--Q3.Category Penetration Analysis 
--   (Category Penetration = number of orders containing the category/number of orders)


select category,
       count(distinct order_id) as no_of_orders,
	   cast(count(distinct order_id)*1.00/(select count(distinct order_id) from orders_copy)as float) as penetration
from orders_copy as o
inner join Products_Info as p
on o.product_id=p.product_id
group by category
order by penetration desc


--Q5.Most popular category during first purchase of customer

--overall

select category, count(o.Customer_id) as total_cust
from orders_copy as o
inner join Products_Info as p
on o.product_id=p.product_id
group by category
order by total_cust desc

--first purchase

select category,count(customer_id) as total_cust
from(

select customer_id,category
from orders_copy as o
inner join Products_Info as p
on o.product_id=p.product_id
group by customer_id,category,BILL_DATE
having BILL_DATE= min(bill_date)) as x
group by Category
order by total_cust desc


---------------------------------------------------------------**-----------------------------------------------
--------------------------------------------------------------**------------------------------------------------

--(Slide No.44-46)

--** Customer satisfaction towards category & product **

--Q1.Which categories (top 10) are maximum rated & minimum rated and average rating score? 

select category,cast(sum(ratings)*1.00/count(product)as decimal(16,2)) as avg_ratings
from(
select Category,o.product_id as product,Customer_Satisfaction_Score as ratings
from orders_copy as o
inner join Products_Info as p
on o.product_id=p.product_id
inner join orderReview_ratings_copy as ocr
on o.order_id=ocr.order_id) as x
group by Category
order by avg_ratings desc

--Q2.Average rating by store & location, product,  month, etc.

--Product

select product,category,cast(sum(ratings)*1.00/count(product)as float) as avg_ratings
from(
select o.product_id as product,category,Customer_Satisfaction_Score as ratings
from orders_copy as o
inner join Products_Info as p
on o.product_id=p.product_id
inner join orderReview_ratings_copy as ocr
on o.order_id=ocr.order_id) as x
group by product,Category


--store & location
select o.Delivered_StoreID as store, seller_city as location,
sum(Customer_Satisfaction_Score)*1.00/count(o.order_id) as ratings
from orders_copy as o
inner join orderReview_ratings_copy as ocr
on o.order_id=ocr.order_id
inner join
stores_info_new as s
on o.Delivered_StoreID=s.StoreID
group by o.Delivered_StoreID, seller_city
order by ratings desc

--month
select  months,cast(sum(ratings)*1.00/count(months)as float) as avg_ratings
from(
select datename(month,bill_date) as months,Customer_Satisfaction_Score as ratings
from orders_copy as o
inner join orderReview_ratings_copy as ocr
on o.order_id=ocr.order_id) as x
group by months
order by avg_ratings desc


------------------------------------------------------**---------------------------------------------------
------------------------------------------------------**---------------------------------------------------

--(Slide No.50-51)

--Cohort analysis
with cohort as(
select Customer_id, bill_date, min(bill_date) over(partition by customer_id) as first_purchase_date,
		DATEFROMPARTS(year(min(bill_date) over(partition by customer_id)), 
		month(min(bill_date) over(partition by customer_id)), 1) as cohort_date
from orders_copy), 

cohort_1 as (
select *, (month(bill_date)-month(cohort_date))+
(year(bill_date)-year(cohort_date))*12+1 as cohort_index from cohort)

select cohort_date, cohort_index, count(distinct customer_id) as no_of_customer from cohort_1
group by cohort_date,cohort_index
order by cohort_date



--Cohort analysis
with cohort as(
select Customer_id, bill_date, net_amount, net_quantity, (net_amount-[cost per unit]) as profit,
min(bill_date) over(partition by customer_id) as first_purchase_date,
		DATEFROMPARTS(year(min(bill_date) over(partition by customer_id)), 
		month(min(bill_date) over(partition by customer_id)), 1) as cohort_date
from orders_copy),
cohort_1 as ( 
select 'first month' as groups, cohort_date, count(distinct Customer_id) as customers, 
sum(net_amount)  as sales,
sum(net_quantity) as total_quantity,
sum(profit) as profit
from cohort
where month(BILL_DATE)=month(first_purchase_date) and year(bill_date)=year(first_purchase_date)
group by cohort_date
union
select 'subsequent_month' as groups, cohort_date, count( distinct Customer_id) as customers, 
sum(net_amount) as sales,
sum(net_quantity) as total_quantity,
sum(profit) as profit
from cohort
where month(BILL_DATE)>month(first_purchase_date) or year(bill_date)>year(first_purchase_date)
group by cohort_date
) select * from cohort_1


------------------------------------------------------**---------------------------------------------------------
----------------------------------------------------END----------------------------------------------------------











-------For checking data------

--same product_id has different total amount
select order_id from orders
group by order_id
having count(distinct product_id)=1 and count(distinct [Total Amount])>1


/*two repeated customer had made repeat purchase in their first month of purchase (cohort month)
but didn't purchase in subsequent months*/

select  distinct customer_id from
(select *, min(bill_date) over(partition by customer_id) as min_bill_date
from orders_copy) as x
where month(bill_date)=month(min_bill_date) and year(bill_date)=year(min_bill_date)
group by customer_id
having count(distinct order_id)>1

select  distinct customer_id from
(select *, min(bill_date) over(partition by customer_id) as min_bill_date
from orders_copy) as x
where month(bill_date)>month(min_bill_date) or year(bill_date)>year(min_bill_date)
group by customer_id


--here in the data, there are two customers who have more than one order in their first month
--of purchase. Hence, these two customers have been counted in the repeated customers (35). But
--as they haven't made any purchase in the susequent months. So, haven't been counted in the
-- customers in subsequent months in the cohort(33 customers in subsequent months)
--customer_ids: 6324004366, 7341229049


select order_id
from orders 
group by order_id
having count(distinct  product_id)=1 and count(distinct mrp)>1