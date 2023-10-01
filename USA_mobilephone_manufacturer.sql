
--SQL Case Study (Advance) : Mobile_manufacturer Data Analysis 

--Q1--BEGIN 

select distinct
[State]
from
DIM_LOCATION T1
left join FACT_TRANSACTIONS T2 on T1.IDLocation = T2.IDLocation
where
datepart(year,[Date]) > 2005;


--Q1--END

--Q2--BEGIN

select TOP 1 
[State],sum(Quantity) as Qty
from
DIM_LOCATION T1
left join FACT_TRANSACTIONS T2 on T1.IDLocation = T2.IDLocation
Left join DIM_MODEL T3 on T2.IDModel = T3.IDModel
left join DIM_MANUFACTURER T4 on T3.IDManufacturer = T4.IDManufacturer
where
[Country] = 'US' AND Manufacturer_Name = 'Samsung'
group by
[State]
order by
sum(Quantity) desc;

--Q2--END

--Q3--BEGIN       

Select
[State],ZipCode,IDModel,count(IDCustomer) as Num_Trans
from
DIM_LOCATION T1
left join FACT_TRANSACTIONS T2 on T1.IDLocation = T2.IDLocation
group by
[State],ZipCode,IDModel;

--Q3--END

--Q4--BEGIN

select
Manufacturer_Name, Model_Name, Unit_price as [Price]
from
DIM_MANUFACTURER T1
left join DIM_MODEL T2 on T1.IDManufacturer = T2.IDManufacturer
where
Unit_price = (select Min(Unit_price) from DIM_MODEL);

--Q4--END

--Q5--BEGIN

select
Manufacturer_Name,T3.IDModel,Avg(TotalPrice) as [Average price]
from
DIM_MANUFACTURER T1
left join DIM_MODEL T2  on T1.IDManufacturer = T2.IDManufacturer
left join FACT_TRANSACTIONS T3 on T2.IDModel = T3.IDModel
where
Manufacturer_Name in
(select top 5
Manufacturer_Name
from
DIM_MANUFACTURER T1
left join DIM_MODEL T2  on T1.IDManufacturer = T2.IDManufacturer
left join FACT_TRANSACTIONS T3 on T2.IDModel = T3.IDModel
group by
Manufacturer_Name
order by
sum(Quantity) desc)
group by
Manufacturer_Name,T3.IDModel
order by
Avg(TotalPrice) desc;

--Q5--END

--Q6--BEGIN
-- List the names of the customers and the average amount spent in 2009, 
--where the average is higher than 500 

Select
Customer_Name, Avg(TotalPrice) as Avg_amt_spend
from
DIM_CUSTOMER T1
left join FACT_TRANSACTIONS T2 on T1.IDCustomer = T2.IDCustomer
where
datepart(year,[Date]) = 2009
group by
Customer_Name
having
Avg(TotalPrice)>500;

--Q6--END

--Q7--BEGIN  
		
Select * From
	(Select Top 5 Manufacturer_Name,Model_Name
	From FACT_TRANSACTIONS T1
	LEFT JOIN DIM_Model T2 ON T1.IDModel = T2.IDModel
	LEFT JOIN DIM_MANUFACTURER T3  ON T2.IDManufacturer = T3.IDManufacturer
    Where DATEPART(Year,[Date])='2008' 
    group by Manufacturer_Name, Model_Name
    Order by  SUM(Quantity) DESC  
    intersect
	Select Top 5 Manufacturer_Name,Model_Name
    From FACT_TRANSACTIONS T1
    LEFT JOIN DIM_Model T2 ON T1.IDModel = T2.IDModel
    LEFT JOIN DIM_MANUFACTURER T3  ON T2.IDManufacturer = T3.IDManufacturer
    Where DATEPART(Year,[Date])='2009' 
    group by Manufacturer_name, Model_Name
    Order by  SUM(Quantity) DESC 
    intersect
	select Top 5 Manufacturer_Name,Model_Name
    From FACT_TRANSACTIONS T1
    LEFT JOIN DIM_Model T2 ON T1.IDModel = T2.IDModel
    LEFT JOIN DIM_MANUFACTURER T3  ON T2.IDManufacturer = T3.IDManufacturer
    Where DATEPART(Year,[Date])='2010' 
    group by Manufacturer_Name, Model_Name
    Order by  SUM(Quantity) DESC) as A;

--Q7--END	

--Q8--BEGIN

With cte as (
select
Manufacturer_Name,YEAR([date]) as [Year], Sum(TotalPrice) as [Sales],
ROW_NUMBER() OVER(PARTITION BY YEAR([date]) ORDER BY sum(TotalPrice) DESC) as RN
from FACT_TRANSACTIONS T1
LEFT JOIN DIM_Model T2 ON T1.IDModel = T2.IDModel
LEFT JOIN DIM_MANUFACTURER T3  ON T2.IDManufacturer = T3.IDManufacturer
where
YEAR([date]) in (2009,2010)
group by Manufacturer_Name,YEAR([date])
)
Select
Manufacturer_Name, [Year], [Sales]
from
cte
where
RN=2;

--Q8--END

--Q9--BEGIN
	
select
Manufacturer_Name
from FACT_TRANSACTIONS T1
LEFT JOIN DIM_Model T2 ON T1.IDModel = T2.IDModel
LEFT JOIN DIM_MANUFACTURER T3  ON T2.IDManufacturer = T3.IDManufacturer
where
YEAR([date]) = 2010
except
select
Manufacturer_Name
from FACT_TRANSACTIONS T1
LEFT JOIN DIM_Model T2 ON T1.IDModel = T2.IDModel
LEFT JOIN DIM_MANUFACTURER T3  ON T2.IDManufacturer = T3.IDManufacturer
where
YEAR([date]) = 2009;

--Q9--END

--Q10--BEGIN

with cte as(
select
Customer_Name,YEAR([date]) as [Year],Avg(Quantity) as Avg_Quantity,Avg(TotalPrice) as Avg_Spend,
lag(Avg(TotalPrice),1) over (partition by Customer_Name order by YEAR([date])) as previous_spend
from
DIM_CUSTOMER T1
left join FACT_TRANSACTIONS T2 on T1.IDCustomer = T2.IDCustomer
WHERE
Customer_Name in 
(select TOP 100
Customer_Name
FROM
DIM_CUSTOMER T1
left join FACT_TRANSACTIONS T2 on T1.IDCustomer = T2.IDCustomer
group by Customer_Name
order by Avg(Quantity) desc)
group by Customer_Name,YEAR([date])
)
select 
Customer_Name,[YEAR],Avg_Quantity,Avg_Spend, previous_spend,
FORMAT((Avg_Spend - previous_spend)  /previous_spend,'P') AS  [Change]
from
cte;

--Q10--END
	