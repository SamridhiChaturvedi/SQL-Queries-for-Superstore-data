
-- Q: Are my top 5 customers profitable?

Select TOP 5 F.[Customer ID], sum(Sales) as Sales, sum(profit) as Profit, sum(Sales)/sum(Profit) as PM 
from FT F
join Customers
on F.[Customer ID] = Customers.[Customer ID]
group by F.[Customer ID] order by sum(Sales) desc

-- Q: Find out the customer retention rate. 
-- The formula for the same is no. of repeat customers/number of total customers.

Select(
	Select count(*) as Customer_repeated
	from
		(select [Customer ID]
		from FT
		group by [Customer ID]
		having count([Order ID])>1)
		asrows)*1.0/(select count(distinct [Customer ID]) from FT)
as Customer_retention_rate

-- Q: Which are the Top 10 cities with maximum number of Customers?

Select TOP 10 City, Count(distinct [Customer ID]) as Cust_count
from Locations L
join FT F
on L.[Postal Code] = F.[Postal Code]
group by City
order by Cust_count desc

-- Q: Find out the Top 3 sub-categories of each category

Select * 
from (
select P.Category, P.[Sub-Category], sum(sales) as TS,
rank() over (partition by P.[Category]
order by sum(sales) desc) as Rank
from Products P 
join FT F
on P.[Product ID] = F.[Product ID]
group by P.[Sub-Category],P.[Category]) as a
where rank <=3

-- Q: 5)	Who are the customers who have not placed any orders in the last 2 months?

Select distinct [Customer ID],[Customer Name]
from Customers
except
select distinct C.[Customer ID],C.[Customer Name]
from Customers C
inner join FT F
on C.[Customer ID] = F.[Customer ID]
where F.[Order ID] in
(select [Order ID] from orders where
[Order Date] > (select DATEADD(month, -2, max([order date]))
from Orders
))
