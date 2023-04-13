Q1: List all the states in which we have customers who have bought cellphones from 2005 till today.

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
| Manufacturer_Name | State   | Total_Quantity_Sold |
|-------------------|---------|---------------------|
| Samsung           | Arizona | 18                  |

>(1 row affected)
