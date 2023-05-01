
## Mobile Manufacturer EDA Assignment by AnalytixLabs Noida

```
Q1. List all the states in which we have customers who have bought cellphones from 2005 till today.
```

```sql

select distinct(State)
from (

select l.State, year(t.Date) as 'Year_of_Transaction'
from DIM_LOCATION AS L
left join FACT_TRANSACTIONS as T on L.IDLocation = T.IDLocation
left join DIM_DATE AS D on T.Date = D.DATE
where year(t.Date) > 2004
group by L.State, year(T.date)

) as t
  ```
  
>Output


| State             |
|-------------------|
| Arizona           |
| California        |
| Delhi             |
| Haryana           |
| Karnataka         |
| Maharashtra       |
| Maryland          |





```
Q2. What state in the US is buying the most 'Samsung' cell phones?
```
```sql
select TOP 1 C.Manufacturer_Name, O.State, SUM(Quantity) as Total_Quantity_Sold
from DIM_MODEL as M
left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
left join DIM_LOCATION as O on F.IDLocation = O.IDLocation
where Manufacturer_Name = 'Samsung' and O.Country = 'US'
group by C.Manufacturer_Name, O.State
order by Total_Quantity_Sold DESC
```
  
>Output


| Manufacturer_Name | State   | Total_Quantity_Sold |
|-------------------|---------|---------------------|
| Samsung           | Arizona | 18                  |





```
Q3. Show the number of transactions for each model per zip code per state.
```

```sql
SELECT  M.Model_Name, O.ZipCode, O.State, count(*) as Num_of_Transactions
from DIM_MODEL as M
left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
left join DIM_LOCATION as O on F.IDLocation = O.IDLocation
group by O.ZipCode, M.Model_Name, O.State, O.City
order by ZipCode
```
  
>Output


| Model_Name   | ZipCode | State    | Num_of_Transactions |
|--------------|---------|----------|---------------------|
| 3310 (3330)  | 21163   | Maryland | 1                   |
| 5230         | 21163   | Maryland | 3                   |
| 6230 (6233)  | 21163   | Maryland | 1                   |
| C139         | 21163   | Maryland | 2                   |
| Droid Bionic | 21163   | Maryland | 2                   |





```
Q4. Show the cheapest cellphone (Output should contain the price also)
```

```sql
SELECT  TOP 1 A.Manufacturer_Name, Model_Name, Unit_price
from DIM_MODEL as D
left join DIM_MANUFACTURER as A on D.IDManufacturer = A.IDManufacturer
order by Unit_price
```
  
>Output


| Manufacturer_Name | Model_Name | Unit_price |
|-------------------|------------|------------|
| Nokia             | 3210       | 14.00      |





```
Q5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.
```

```sql
SELECT Manufacturer_Name as Top_5_Manufacturers, M.Model_Name, SUM(totalPrice) as Total_Sales, SUM(Quantity) as Quantity_Sold,  ROUND(sum(TotalPrice)/sum(quantity), 2) as Avg_price_per_quantity
from DIM_MODEL as M
left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
where Manufacturer_Name IN (
	select Manufacturer_Name
	from
	(
	SELECT TOP 5 Manufacturer_Name, SUM(quantity) as Quantity
	from DIM_MODEL as M
	left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
	left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
	group by Manufacturer_Name
	order by Quantity DESC
	) as t
	)
group by Manufacturer_Name,Model_Name
order by Avg_price_per_quantity DESC
```
  
>Output


| Top_5_Manufacturers | Model_Name | Total_Sales | Quantity_Sold Avg_price_per_quantity |        |
|---------------------|------------|-------------|--------------------------------------|--------|
| Samsung             | Galaxy S8  | 3325.00     | 5                                    | 665.00 |
| Apple               | iPhone 7   | 8872.00     | 16                                   | 554.50 |
| Apple               | iPhone 6   | 8561.00     | 17                                   | 503.59 |
| One Plus            | OnePlus 6T | 6477.00     | 13                                   | 498.23 |
| Apple               | iPhone 5   | 3673.00     | 8                                    | 459.13 |





```
Q6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500
```

```sql
SELECT Customer_Name, AVG(TotalPrice) as Average_Sales
from DIM_MODEL as M
Left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
Left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
Left join DIM_LOCATION as O on F.IDLocation = O.IDLocation
Left join DIM_CUSTOMER as U on F.IDCustomer = U.IDCustomer
where YEAR(Date) = 2009
group by Customer_Name
having AVG(TotalPrice) > 500
order by Average_Sales DESC
```
  
>Output


| Customer_Name    | Average_Sales |
|------------------|---------------|
| Laurel Reitler   | 1528.00       |
| Lettie Isenhower | 870.00        |
| Moon Parlato     | 823.50        |
| Danica Bruschke  | 760.00        |
| Celeste Korando  | 613.00        |
| Shawna Palaspas  | 569.00        |





```
Q7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
```

```sql
select TOP 1 Model_Name, count(Model_Name) AS 'Common_in_Top_5_in_2008,09,10'
--select Model_Name, count(Model_Name) AS 'Common_in_Top_5_in_2008,09,10'
from
(

select * from (
SELECT TOP 5 YEAR(date) as Year, Model_Name, SUM(quantity) as Quantity_Sold_2008
from DIM_MODEL as M
Left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
Left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
where YEAR(date) = 2008
group by YEAR(date), Model_Name
order by Quantity_Sold_2008 DESC
) as t1

UNION

select * from (
SELECT TOP 5 YEAR(date) as Year, Model_Name, SUM(quantity) as Quantity_Sold_2009
from DIM_MODEL as M
Left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
Left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
where YEAR(date) = 2009
group by YEAR(date), Model_Name
order by Quantity_Sold_2009 DESC
) as t2

UNION

select * from (
SELECT TOP 5 YEAR(date) as Year, Model_Name, SUM(quantity) as Quantity_Sold_2010
from DIM_MODEL as M
Left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
Left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
where YEAR(date) = 2010
group by YEAR(date), Model_Name
order by Quantity_Sold_2010 DESC
) as t3

) as tt1

group by Model_Name
order by [Common_in_Top_5_in_2008,09,10] DESC
```
  
>Output


| Year_Sales | Manufacturer_Name | Ranking |
|------------|-------------------|---------|
| 2010       | Apple             | 2       |
| 2009       | Samsung           | 2       |





```
Q8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.
```

```sql
select Year_Sales, Manufacturer_Name, Ranking from (

SELECT TOP 5 YEAR(date) as Year_Sales, Manufacturer_Name, SUM(TotalPrice) as Total_Sales_2009,
ROW_NUMBER() OVER (ORDER BY SUM(TotalPrice) DESC) AS 'Ranking'
from DIM_MODEL as M
Left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
Left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
where YEAR(date) = 2009
group by YEAR(date), Manufacturer_Name
) as t1


where Ranking = 2

Union

select Year_Sales, Manufacturer_Name, Ranking from (

SELECT TOP 5 YEAR(date) as Year_Sales, Manufacturer_Name, SUM(TotalPrice) as Total_Sales_2009,
ROW_NUMBER() OVER (ORDER BY SUM(TotalPrice) DESC) AS 'Ranking'
from DIM_MODEL as M
Left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
Left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
where YEAR(date) = 2010
group by YEAR(date), Manufacturer_Name
) as t2

where Ranking = 2
```
  
>Output


| Manufacturer_Name | State   | Total_Quantity_Sold |
|-------------------|---------|---------------------|
| Samsung           | Arizona | 18                  |





```
Q9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.
```

```sql
select 'Company that sold in 2010 but not in 2009' as 'Question', Manufacturer_Name as 'Answer' from (
SELECT TOP 5 YEAR(date) as Year_Sales, Manufacturer_Name, SUM(TotalPrice) as Total_Sales_2009,
ROW_NUMBER() OVER (ORDER BY SUM(TotalPrice) DESC) AS 'Ranking'
from DIM_MODEL as M
Left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
Left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
where YEAR(date) = 2010
group by YEAR(date), Manufacturer_Name
) as t2

EXCEPT

select 'Company that sold in 2010 but not in 2009' as 'Question', Manufacturer_Name from (
SELECT TOP 5 YEAR(date) as Year_Sales, Manufacturer_Name, SUM(TotalPrice) as Total_Sales_2009,
ROW_NUMBER() OVER (ORDER BY SUM(TotalPrice) DESC) AS 'Ranking'
from DIM_MODEL as M
Left join DIM_MANUFACTURER as C on m.IDManufacturer = c.IDManufacturer
Left join FACT_TRANSACTIONS as F on M.IDModel = F.IDModel
where YEAR(date) = 2009
group by YEAR(date), Manufacturer_Name
) as t2
```
  
>Output


| Question                                      | Answer |
|-----------------------------------------------|--------|
| Company that sold in 2010 but not in 2009 HTC | Apple  |





```
Q10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.
```

```sql

SELECT
	Customer_Name,
	YEAR(date) as Year_of_Purchase,
	ROUND(AVG(TotalPrice), 2) as Average_Spend,
	AVG(TotalPrice) - LAG(AVG(TotalPrice)) OVER (PARTITION BY Customer_Name order by Year(date)) AS Change,

	--	To calculate percent change : 
	--		To calculate Year on Year Change, first take your current year’s revenue and subtract the previous year’s revenue. This
	--		gives you a total change in revenue. Then, take that amount and divide it by last year’s total revenue.
	--		Take that sum and multiply it by 100 to get your YoY percentage.
		
	--		Theory as demo formula : 
	--	    (sales - LAG(sales) OVER (ORDER BY year)) / LAG(sales) OVER (ORDER BY year) * 100 AS percent_change
	
	--	Substituting as per our needs: YOY = (New Price - Old Price)/Old Price
	--	
	CONCAT(ISNULL((Avg(TotalPrice) - LAG(Avg(TotalPrice)) OVER (PARTITION BY Customer_Name ORDER BY year(date)))
	/ -- (divided by last year's total revenue
	LAG(Avg(TotalPrice)) OVER (PARTITION BY Customer_Name ORDER BY year(date)) * 100, '0'), ' %') AS percent_change,

	AVG(Quantity) as Average_Quantity

from DIM_CUSTOMER as C
left join FACT_TRANSACTIONS as T on C.IDCustomer = T.IDCustomer
group by Customer_Name, Year(date)
```
  
>Output


| Customer_Name     | Year_of_Purchase Average_Spend | Change | percent_change | Average_Quantity |   |
|-------------------|--------------------------------|--------|----------------|------------------|---|
| Alease Buemi      | 2007                           | 436.00 | NULL           | 0.00 %           | 1 |
| Angella Cetta     | 2003                           | 170.00 | NULL           | 0.00 %           | 1 |
| Angella Cetta     | 2004                           | 282.50 | 112.50         | 66.17 %          | 1 |
| Angella Cetta     | 2007                           | 300.00 | 17.50          | 6.19 %           | 1 |
| Angella Cetta     | 2010                           | 173.00 | -127.00        | -42.33 %         | 1 |
| Arlene Klusman    | 2004                           | 665.00 | NULL           | 0.00 %           | 1 |
| Arlene Klusman    | 2006                           | 415.00 | -250.00        | -37.59 %         | 1 |
| Arlene Klusman    | 2008                           | 347.00 | -68.00         | -16.38 %         | 1 |
| Arlene Klusman    | 2010                           | 476.00 | 129.00         | 37.17 %          | 1 |
| Arlette Honeywell | 2004                           | 189.00 | NULL           | 0.00 %           | 1 |
| Arlette Honeywell | 2005                           | 269.00 | 80.00          | 42.32 %          | 1 |
| Arlette Honeywell | 2006                           | 233.00 | -36.00         | -13.38 %         | 1 |
| Arlette Honeywell | 2007                           | 76.67  | -156.3334      | -67.09 %         | 1 |
| Arlette Honeywell | 2008                           | 502.00 | 425.3334       | 554.78 %         | 1 |
| Bobbye Rhym       | 2005                           | 319.00 | NULL           | 0.00 %           | 1 |
