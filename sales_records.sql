select * from sales_records.customer_records;
select * from sales_records.exchange_records;
select * from sales_records.product_records;
select * from sales_records.sales_records;
select * from sales_records.stores_records;


-- customer records
set autocommit=0;
SET SQL_SAFE_UPDATES = 0;

-- change datatypes to date 
-- customer records
update sales_records.customer_records set Birthday = str_to_date(Birthday,"%Y-%m-%d");
alter table sales_records.customer_records modify column Birthday DATE;

-- exchange records
update sales_records.exchange_records set Date = str_to_date(Date,"%Y-%m-%d");
alter table sales_records.exchange_records modify column Date DATE;

-- sales records
update sales_records.sales_records set Order_Date = str_to_date(Order_Date,"%Y-%m-%d");
alter table sales_records.sales_records modify column Order_Date DATE;

update sales_records.sales_records set Delivery_Date = str_to_date(Delivery_Date,"%Y-%m-%d");
alter table sales_records.sales_records modify column Delivery_Date DATE;

-- store records
update sales_records.stores_records set Open_Date = str_to_date(Open_Date,"%Y-%m-%d");
alter table sales_records.stores_records modify column Open_Date DATE;

-- Gender Count
select Gender, COUNT(Gender) as Gender_Count
from sales_records.customer_records
where Gender IN ('Male', 'Female')
group by Gender;

-- AgeGroup
select AgeGroup, COUNT(*) as Count
from sales_records.customer_records
group by AgeGroup
order by AgeGroup;

-- customers country wise
select sr.Country,count(distinct c.CustomerKey)  as customer_count 
from sales_records.sales_records c join sales_records.stores_records sr on c.StoreKey=sr.StoreKey
group by sr.Country order by customer_count desc;

-- stores country wise
select Country,count(StoreKey) from sales_records.stores_records
group by Country order by count(StoreKey) desc;

-- overall profit
select sum(Unit_Price_USD*sr.Quantity) as total_sales_amount from sales_records.product_records pr
join sales_records.sales_records sr on pr.ProductKey=sr.ProductKey ;

-- sales on each stores
select s.StoreKey,sr.Country,sum(Unit_Price_USD*s.Quantity) as total_sales_amount from sales_records.product_records pr
join sales_records.sales_records s on pr.ProductKey=s.ProductKey 
join sales_records.stores_records sr on s.StoreKey=sr.StoreKey group by s.StoreKey,sr.Country;

-- product sales count
select Subcategory,count(Subcategory) from sales_records.product_records group by Subcategory;

select Subcategory ,round(sum(Unit_price_USD*sr.Quantity),2) as TOTAL_SALES_AMOUNT
from sales_records.product_records pr join sales_records.sales_records sr on pr.ProductKey=sr.ProductKey
 group by Subcategory order by TOTAL_SALES_AMOUNT desc;
 
 -- sales on each country
select s.Country,sum(pr.Unit_price_USD*sr.Quantity) as total_sales from sales_records.product_records pr
join sales_records.sales_records sr on pr.ProductKey=sr.ProductKey 
join sales_records.stores_records s on sr.StoreKey=s.StoreKey group by s.Country;

-- brand profit yearly
select year(Order_Date),pr.Brand,round(SUM(Unit_price_USD*sr.Quantity),2) as year_sales FROM sales_records.sales_records sr
join sales_records.product_records pr on sr.ProductKey=pr.ProductKey group by year(Order_Date),pr.Brand;

-- overall sales with product count
select Brand,sum(Unit_Cost_USD*sr.Quantity) as buying_price,sum(Unit_Price_USD*sr.Quantity) as selling_price,
(SUM(Unit_Price_USD*sr.Quantity) - SUM(Unit_Cost_USD*sr.Quantity)) / SUM(Unit_Cost_USD*sr.Quantity) * 100 as profit 
from sales_records.product_records pr join sales_records.sales_records sr on sr.ProductKey=pr.ProductKey
group by Brand;


-- yearly sales

 select year(Order_Date) as year,
 SUM((Unit_Price_USD - Unit_Cost_USD) * sr.Quantity) as profit 
from sales_records.sales_records sr join sales_records.product_records pr 
on sr.ProductKey = pr.ProductKey
group by year(Order_Date);


-- year wise profit      
select YEAR(Order_Date) as Year ,(SUM(Unit_Price_USD*sr.Quantity) - SUM(Unit_Cost_USD*sr.Quantity)) as current_profit, 
LAG(sum(Unit_Price_USD*sr.Quantity) - SUM(Unit_Cost_USD*sr.Quantity))
OVER(order by YEAR(Order_Date)) AS Previous_year_Sales,
round(((SUM(Unit_Price_USD*sr.Quantity) - SUM(Unit_Cost_USD*sr.Quantity))-
LAG(sum(Unit_Price_USD*sr.Quantity) - SUM(Unit_Cost_USD*sr.Quantity))
OVER(order by YEAR(Order_Date)))/LAG(sum(Unit_Price_USD*sr.Quantity) - SUM(Unit_Cost_USD*sr.Quantity))
OVER(order by YEAR(Order_Date))*100,2) as profit_percent
from sales_records.sales_records sr join sales_records.product_records pr 
on sr.ProductKey=pr.ProductKey GROUP BY 
    YEAR(Order_Date);
  