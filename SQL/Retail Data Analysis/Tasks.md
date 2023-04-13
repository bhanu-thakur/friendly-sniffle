
```sql

	select distinct(State)
	from (

	select l.State, year(t.Date) as 'Year_of_Transaction'
	from DIM_LOCATION AS L
	left join FACT_TRANSACTIONS as T on l.IDLocation = T.IDLocation
	left join DIM_DATE AS D on t.Date = d.DATE
	where year(t.Date) > 2004
	group by L.State, year(t.date)

	) as t
  ```
