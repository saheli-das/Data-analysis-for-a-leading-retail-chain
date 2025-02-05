**Business Context:** A leading Retail Chains in India provided the Point of Sales data of 37 stores across 7 States for a period of 2 years (Sept, 2021 to Oct, 2023) to define CRM/marketing/Campaign/Sales strategies for the upcoming year

**Data Availability:** The client provided data in six tables:
a.	Customer table – Containing customer level data consists of 4 columns – customer_id, city, State and Gender
b.	Stored_info table: Containing store level data consists of 4 columns – store_id, seller_city, State and region
c.	Products_info table: Containing product level data consists of 9 columns - Product-id, category, product name length and description length, product photos quantity, product dimensions and weight
d.	Orders table: Containing orders level point of sales data consists of 11 columns - Customer-id (foreign key), order-id, product-id (foreign key), channel, store-id (foreign key), bill date time stamp, quantity, unit cost, MRP, discount and total amount
e.	Order payment table: Consists of 3 columns - Order-id, payment type and payment value
f.	Order_reivew_ratings table: Consists of 2 columns - Order-id, customer satisfaction score

**Tools used:** Excel, SQL and MS PPT

**Techniques used:** Data Cleaning, Exploratory Data Analysis, Trend and Seasonality analysis, Customer Behaviour Analysis, Category Behaviour Analysis, Cross Selling Analysis, Creation of Charts showing results of the analysis, and Insights Generation
Types of Charts Used: Line Chart, Column Chart, Bar Chart, Pie Chart, Pareto Chart, table etc.

**Detailed Steps:**
1.	As part of this project, I analyzed 1,12,650 orders provided by the Retail Company alongwith other details of product_id, store_id, bill_date time, cost, MRP and discount, etc.
2.	Initially, I performed data cleaning steps viz.
	removal of duplicate store_id from store table (3 duplicate stores removed)
	for multiple custome_ratings for a single order, average of ratings has been taken
	the data type of bill_date_timestamp has been changed to date_time
	The orders with multiple products, the quantity and price has been given cumulatively. To address this, net_quantity and net_price have been calculated against each product sold
	Excluded the order_ids which were available in orders_payment table but not in orders table.
	Excluded the order_ids for which total price in orders table is not matching with the total price in order_payment table
3.	After cleaning of the data, calculated the high-level metrics like total revenue, total profit, profit percentage, total orders, total customer, total stores, etc.
4.	Also analyzed the Sales trend i.e. year on year, quarter on quarter, month on month and week on week sales and profit and seasonality analysis such as by month, quarter, days of week, weekdays vs. weekend analysis, etc.
5.	Performed customer behaviour analysis, such as one time vs. repeat customer, first time vs. repeat purchase behaviour, customer segmentation (RFM), customer cohort analysis, etc.
6.	Analyzed the top ten products cross-sold together. Also analyzed, top selling categories, products with highest and lowest customer ratings
7.	Also performed region and State wise analysis for the above analysis

**Findings:**
1.	Yearly trend shows steady growth from 2020 to 2023
2.	Quarterly and monthly trend also shows growth over the period except in last 4-5 months and in last quarter of the given period where sales were decreased
3.	August, 2023 has highest new customers and highest revenue from new customers
4.	August 2023 has the highest retention i.e. 4
5.	Week 49 of 2022 has highest sales
6.	Month with highest sales: August and month with lowest sales: September
7.	Quarter 2 has highest sales (28.29%) and quarter 4 has lowest sales (21.29%)
8.	Weekdays has 76.48% of total sales and weekend has 23.52% of total sales
9.	Wednesday has highest sales (23.29%) and Friday has lowest sales (4.4%)
10.	Total contribution in sales by top 10 expensive products together is 0.35%
11.	Total contribution in sales by top 10 performing stores is 53.14% and by bottom 10 stores is 13.07%
12.	Top performing store – ST 103, city – Akkarampalle, State – Andhra Pradesh (21.37% contribution in sales)
13.	Least performing store – ST 354, city – Farakhpur, State – Haryana (1.02% contribution in sales)
14.	South region has highest sales (74.73%)
15.	Onetime buyers – 98,280 (99.97%)
16.	Onetime buyers – 35 (0.03%)
17.	Most preferred channel: instore, most preferred payment method: credit card, most preferred store: ST 103, most preferred category: Toys & gifts
18.	60% sales contributed by top 5 categories (35% of total categories) and 76% sales contributed by top 7 categories (50% of total categories)
19.	Most profitable category – Home appliances
20.	Highest no. of orders – Toys & gifts
21.	‘Home Appliances’ is the most preferred category in case of cross selling of both 2 products together and 3 products together
22.	The Jan 2022 cohort has the longest retention of customers having cohort index – 24
23.	Though, the Aug 2023 cohort has the highest no of initial customers (6,617) but no further purchased was made from this cohort
24.	Only, 0.
25.	07% customers were in the highest segment of customer RFM Segmentation (Revenue, Frequency and monetary)

**Insights and recommendations:**
•	Weekdays sales are around 3 times of the weekend sales. Hence, to increase weekend sales some promotion, offers may be given during the weekends
•	Female customers are more than two times of male customers. Even retention rate for female customers is slightly higher than that of male. Hence, male customers may be targeted to increase the sales
•	No. of repeated buyers is only 35 out of total 98,315 customers analyzed. Hence, focus to be given on retention of customers by analyzing customers feedback and giving some offers, promotion for subsequent purchases
•	Yearend (December) sales and festive season (September-October) sales are low in comparison to the sales in other months, which are usually high priority season for buyers for purchasing. Hence, promotional activities for these seasons can be done to see increase in sales


