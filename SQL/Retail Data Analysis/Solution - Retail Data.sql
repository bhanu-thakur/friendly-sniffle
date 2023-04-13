

use retail_data

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

--      SECTION 1

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------








-- Q1		What is the total number of rows in each of the 3 tables in the database?


SELECT * FROM (
SELECT 'Customer' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM Customer UNION ALL
SELECT 'Transactions' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM Transactions UNION ALL
SELECT 'prod_cat_info' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM prod_cat_info
) TBL
----------------------------------------------------------------------------------------------------------------------------------------

--Q2	What is the total number of transactions that have a return?
SELECT COUNT(*)
FROM Transactions
WHERE total_amt<0

----------------------------------------------------------------------------------------------------------------------------------------

--Q3	As you would have noticed, the dates provided across the datasets are not in a
--		correct format. As first steps, pls convert the date variables into valid date formats
--		before proceeding ahead.


----------------------------------------------------------------------------------------------------------------------------------------

--Q4	What is the time range of the transaction data available for analysis?
--		Show the output in number of days, months and years simultaneously in different columns.


select
		DATEDIFF(YEAR, min(tran_date), max(tran_date)) AS 'Total Years',
		DATEDIFF(Month, min(tran_date), max(tran_date)) AS 'Total Months',
		DATEDIFF(day, min(tran_date), max(tran_date))  AS 'Total Days'
from Transactions



----------------------------------------------------------------------------------------------------------------------------------------

--Q5	Which product category does the sub-category “DIY” belong to?

SELECT prod_subcat, prod_cat
FROM prod_cat_info
WHERE prod_subcat = 'DIY'











----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

--      SECTION 2

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------





--Q1 Which channel is most frequently used for transactions


select Channel as 'Most frequently Channel'
from (
select
	Transactions.Store_type AS Channel, 
	COUNT(transaction_id) AS Num_Of_Transactions, 
	ROW_NUMBER() OVER (ORDER BY COUNT(transaction_id) DESC) AS 'Ranking'
from Transactions
GROUP BY Store_type
) as t
where Ranking = 1

----------------------------------------------------------------------------------------------------------------------------------------

--Q2 What is the count of Male and Female customers in the database

SELECT Gender, COUNT(GENDER) as 'Total Customers'
FROM Customer
where gender IN ('M', 'F')
GROUP BY Gender
order by [Total Customers] DESC

----------------------------------------------------------------------------------------------------------------------------------------


--Q3 From which city do we have the maximum number of customers and how many?

select TOP 1 city_code, count(customer_Id) AS Customers from Customer
GROUP BY city_code
ORDER BY count(city_code) DESC


----------------------------------------------------------------------------------------------------------------------------------------


--Q4 How many sub-categories are there under the Books category?

SELECT prod_cat_info.prod_cat, COUNT(prod_cat_info.prod_subcat) AS 'Number of sub categories'
FROM prod_cat_info
WHERE prod_cat_info.prod_cat = 'Books'
GROUP BY prod_cat_info.prod_cat


----------------------------------------------------------------------------------------------------------------------------------------


--Q5 What is the maximum quantity of products ever ordered?

SELECT TOP 1 prod_cat_info.prod_cat, SUM(Qty) AS 'Maximum_Quantity'
FROM Transactions
LEFT JOIN prod_cat_info ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code
and prod_sub_cat_code = Transactions.prod_subcat_code
GROUP BY prod_cat_info.prod_cat
ORDER BY Maximum_Quantity DESC


----------------------------------------------------------------------------------------------------------------------------------------


--Q6 What is the net total revenue generated in categories Electronics and Books?

SELECT 
	'Net total revenue is = ',
	ROUND(sum(total_amt), 2)

FROM prod_cat_info
LEFT JOIN Transactions 
	ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code
	AND prod_cat_info.prod_sub_cat_code = Transactions.prod_subcat_code
WHERE prod_cat IN ('Electronics', 'Books')


----------------------------------------------------------------------------------------------------------------------------------------


--Q7 How many customers have >10 transactions with us, excluding returns?

SELECT 'Customers with Transactions > 10 excluding returns', COUNT(*) FROM

(
SELECT cust_id, COUNT(cust_id) AS TRANSACTIONS_1
FROM Transactions
WHERE total_amt>0
GROUP BY cust_id
HAVING COUNT(cust_id)>10

) AS sub_table


----------------------------------------------------------------------------------------------------------------------------------------



--Q8 What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

SELECT 
	--prod_cat,
	'Combines Revenue is =',
	sum(total_amt)

FROM prod_cat_info AS p
LEFT JOIN Transactions AS t
	ON p.prod_cat_code = t.prod_cat_code
	AND p.prod_sub_cat_code = t.prod_subcat_code
WHERE
	prod_cat IN ('Electronics', 'Clothing') AND Store_type = 'Flagship Store'


----------------------------------------------------------------------------------------------------------------------------------------


--Q9 What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.

select  prod_cat, prod_subcat,
		ROUND(SUM(total_amt), 2) AS Total_Revenue

FROM Transactions AS T
	LEFT JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
	AND T.prod_subcat_code = P.prod_sub_cat_code

	LEFT JOIN Customer AS C ON C.customer_Id = T.cust_id

WHERE p.prod_cat = 'Electronics' AND C.Gender = 'M'
GROUP BY prod_cat, prod_subcat
ORDER BY Total_Revenue DESC;

----------------------------------------------------------------------------------------------------------------------------------------


--Q10 What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales

-- another way to solve without joins is by calculating columns required in the original Select statement only.

select * --Outer most select starts
from (
-- Left join is performed on t1.prod_subcat where t1 is table 1 (t1) and then it's prod_subcat is used to perform JOIN
select t1.prod_subcat AS 'Top 5 Sub Categories in Terms of Sales', Total_Sales, Percentage_Sales, Total_Returns, Percentage_Returns
from (
--  1A starts To get top 5 catgories by Total Sales
SELECT TOP 5
		prod_subcat,
		ROUND(SUM(total_amt), 2) as 'Total_Sales',
		ROUND((SUM(total_amt)/(select(SUM(total_amt)) from Transactions)*100), 2) AS 'Percentage_Sales'
FROM Transactions AS T
LEFT JOIN prod_cat_info AS P
ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
where total_amt > 0
GROUP BY prod_subcat
ORDER by Total_Sales DESC
 --1A ends
) as t1
left join (
-- 1B starts to calculate percentage returns
SELECT
		prod_subcat,
		ROUND(SUM(total_amt), 2) as 'Total_Returns',
		Round(ABS((SUM(total_amt)/(select(SUM(total_amt)) from Transactions)*100)), 2) AS 'Percentage_Returns'
FROM Transactions AS T
LEFT JOIN prod_cat_info AS P
ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
where total_amt < 0
GROUP BY prod_subcat
--1B ends
) as t2
ON t1.prod_subcat = t2.prod_subcat
) as t3 -- Outermost select ends


----------------------------------------------------------------------------------------------------------------------------------------

--Q11	For all customers aged between 25 to 35 years find what is the net total revenue
--		generated by these consumers in last 30 days of transactions from max transaction
--		date available in the data?



select ROUND(SUM(total_amt), 2) as Required_Revenue -- 1C Starts. Here, further WHERE is applied to filter transactions that took place in last 1 month using BETWEEN
from (
select * -- 1B Starts. It returns original table as-it-is for further filteration.
from (
select *
from Transactions as T
left join Customer as C on T.cust_id = c.customer_Id
-- BLOCK 1A Starts
-- This code feeds the column that inner query has returned
where customer_Id IN	(
						--  This query inside where will return a column that contains only IDs of customers whose age is b/w 25 and 30
						select customer_Id
						from (
						select *
						from Customer
						where DATEDIFF(year, DOB, (Select MAX(tran_date) from Transactions) ) > 24 AND DATEDIFF(year, DOB, (Select MAX(tran_date) from Transactions) ) < 36
						) as t
					) -- BLOCK 1A Ends
) as t2 -- 1B Ends
WHERE tran_date BETWEEN DATEADD(month, -1, (Select MAX(tran_date) from Transactions)) AND (Select MAX(tran_date) from Transactions) -- 1C filteration
) as t3 -- 1C ends

																														--select SUM(total_amt) as total_revenue from 
																														--(
																														--select * from Customer c
																														--left join Transactions t
																														--on t.cust_id=c.customer_Id
																														--where DATEDIFF(year, DOB, (Select MAX(tran_date) from Transactions) ) > 24 
																														--AND DATEDIFF(year, DOB, (Select MAX(tran_date) from Transactions) ) < 36
																														--) as t
																														--where tran_date BETWEEN DATEADD(month, -1, (Select MAX(tran_date) from Transactions)) AND (Select MAX(tran_date) from Transactions)


																													-- Finding last 30 days YTD

																													-- To get YTD :
																														--select *, SUM(revenue) OVER (ORDER BY tran_date) AS 'YTD'
																														--from
																														--(SELECT tran_date, SUM(total_amt) AS REVENUE
																														--FROM Transactions AS T
																														--WHERE tran_date BETWEEN '2014-01-28' AND '2014-02-28'
																														--GROUP BY tran_date) as t1


----------------------------------------------------------------------------------------------------------------------------------------

--Q12  Which product category has seen the max value of returns in the last 3 months of
--	   transactions?

Select top 1 * from
(
SELECT prod_cat AS Category, ROUND(sum(total_amt), 2) as Total_Returns
--SELECT TOP 1 prod_cat AS Category, ROUND(sum(total_amt), 2) as Total_Returns
FROM Transactions AS T
LEFT JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE total_amt<0 AND tran_date BETWEEN DATEADD(month, -3, (Select MAX(tran_date) from Transactions)) AND (Select MAX(tran_date) from Transactions)
GROUP BY prod_cat
--ORDER BY Total_Returns
) as t
ORDER BY Total_Returns

----------------------------------------------------------------------------------------------------------------------------------------


--Q13  Which store-type sells the maximum products; by value of sales amount and by
--     quantity sold?

select 'Maximum Sales is from the store : ' AS 'Description', * 
from (select TOP 1 * from (select Store_type, ROUND(SUM(total_amt), 0) as 'Total'
FROM Transactions
WHERE total_amt > 0
GROUP BY Store_type) AS t
Order by Total DESC) as t2
UNION ALL
select 'Maximum Quantity overall is from the store : ',*
from (select TOP 1 * from (select Store_type, SUM(Qty) as 'Total'
FROM Transactions
GROUP BY Store_type) AS a
Order by Total DESC)a2


------------------------------------------------------------------------------------------------------------------


--Q14 What are the categories for which average revenue is above the overall average

SELECT prod_cat, ROUND(AVG(total_amt), 2) AS 'Average_Revenue'
FROM Transactions AS T
LEFT JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
GROUP BY prod_cat
Having AVG(total_amt) > (select ROUND(AVG(total_amt), 2)
from Transactions AS T
LEFT JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code)
ORDER BY Average_Revenue DESC

---- 1. Get overall Average to use it as output table.
--select ROUND(AVG(total_amt), 2)
--from Transactions AS T
--LEFT JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
--AND T.prod_subcat_code = P.prod_sub_cat_code

----2. Get result by hardcoding before making dynamic
--SELECT prod_cat, AVG(total_amt) AS Avrg
--FROM Transactions AS T
--LEFT JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
--AND T.prod_subcat_code = P.prod_sub_cat_code
--GROUP BY prod_cat
--Having AVG(total_amt) > 2107

--3 Substitute Dynamically





------------------------------------------------------------------------------------------------------------------
--Q15	Find the average and total revenue by each subcategory for the categories which
--		are among top 5 categories in terms of quantity sold.


SELECT prod_cat,prod_subcat, ROUND(AVG(total_amt), 2) AS 'Average_Revenue',ROUND(SUM(total_amt), 2) as 'Total_Revenue'
FROM Transactions AS T
LEFT JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE prod_cat IN
(

SELECT prod_cat FROM
(
SELECT TOP 5 prod_cat,SUM(Qty) AS 'Quantity_Sold'
FROM Transactions AS T
LEFT JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE Qty>0
GROUP BY prod_cat
ORDER BY Quantity_Sold DESC

) AS Top_category_by_Quantity
)

GROUP BY prod_cat,prod_subcat
ORDER BY prod_cat



---- 1. get a column as table for input into WHERE
--SELECT prod_cat FROM
--(SELECT TOP 5 prod_cat,SUM(Qty) AS 'Quantity_Sold'
--FROM Transactions AS T
--LEFT JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
--AND T.prod_subcat_code = P.prod_sub_cat_code
--WHERE Qty>0
--GROUP BY prod_cat
--ORDER BY Quantity_Sold DESC) AS Top_category_by_Quantity

---- 2. average and total revenue per subcategory 
--SELECT prod_cat,prod_subcat, ROUND(AVG(total_amt), 0) AS 'Average_Revenue',ROUND(SUM(total_amt), 0) as 'Total_Revenue'
--FROM Transactions AS T
--LEFT JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
--AND T.prod_subcat_code = P.prod_sub_cat_code
--GROUP BY prod_cat,prod_subcat
--ORDER BY Total_Revenue DESC

---- 3. Combine both




------------------------------------------------------------------------------------------------------------------


