create database BusinessLogics 
go
use BusinessLogics

CREATE TABLE Orders (
  CustomerID INT,
  OrderDate DATE
);

INSERT INTO Orders VALUES
(1, '2025-01-10'), (1, '2025-02-15'), (1, '2025-03-12'), (1, '2025-04-11'), (1, '2025-05-21'), (1, '2025-06-01'),
(2, '2025-01-05'), (2, '2025-02-20'), (2, '2025-03-10'), (2, '2025-05-15'), (2, '2025-06-02'),
(3, '2025-06-10'), (3, '2025-06-11'),
(4, '2025-01-02'), (4, '2025-02-03'), (4, '2025-03-04'), (4, '2025-04-05'), (4, '2025-05-06'), (4, '2025-06-07');

select * from Orders

--1. Customers who placed at least one order in EACH of the last 6 months
select CustomerID from Orders
where datediff(month, OrderDate, cast(getdate() as date)) <= 6
group by CustomerID
having count(distinct month(OrderDate)) = 6

--2. Customers who placed orders in AT LEAST 3 DIFFERENT months this year
select CustomerID from Orders
where year(OrderDate) = year(getdate())
group by CustomerID
having count(Distinct month(OrderDate)) > = 3

--3. Customers who placed orders ONLY in June 2025
select CustomerID from Orders
where year(OrderDate) = year(getdate()) and month(OrderDate) = 6
group by CustomerID;

--4. Customers who placed multiple orders in the SAME month (at least 2 orders in any month)
select CustomerID
from orders 
group by customerId, month(OrderDate)
having Count(*) >= 2

--5. Customers who placed orders in 2 CONSECUTIVE months at least once (e.g., Jan & Feb or Apr & May)
with temp as(
	select customerID , month(OrderDate) as Month from Orders
	group by CustomerID, month(OrderDate)
)

select distinct m1.CustomerID from temp m1
left join temp m2 on  m1.CustomerID = m2.CustomerID and abs(m1.Month - m2.Month) = 1




-- Sample Data for 7-Day Rolling Average of Sales (Join Method)
CREATE TABLE Sales (
  ProductID INT,
  SalesDate DATE,
  Amount DECIMAL(10,2)
);

INSERT INTO Sales VALUES
(1, '2025-06-11', 800.00),
(1, '2025-06-02', 150.00),
(1, '2025-06-04', 250.00),
(1, '2025-06-07', 300.00),
(1, '2025-06-08', 100.00),
(2, '2025-06-01', 500.00),
(2, '2025-06-03', 400.00),
(2, '2025-06-05', 300.00),
(2, '2025-06-07', 350.00),
(2, '2025-06-08', 450.00);

select * from Sales;

--Write a query that returns the 7-day rolling average of sales for each product.
--Assume the table: Sales(ProductID, SalesDate, Amount)

select s1.ProductID, s1.SalesDate, avg(s2.Amount) from Sales s1
inner join Sales s2 on s1.ProductID = s2.ProductID
where s2.SalesDate between dateadd(day, -6, s1.SalesDate) and s1.SalesDate
group by s1.ProductID , s1.SalesDate
order by s1.ProductID, s1.SalesDate

-- 30-Day Rolling Total of Sales per Product
-- For each ProductID and SalesDate, calculate the sum of Amount in the last 30 days.
select s1.ProductID , s1.SalesDate, sum(s2.Amount) from sales s1
inner join sales s2 on s1.ProductID = s2.ProductID
and s2.SalesDate between dateadd(day, -29, s1.SalesDate) and s1.SalesDate
group by s1.ProductID, s1.SalesDate
order by s1.ProductID, s1.SalesDate

--7-Day Rolling Count of Orders per Customer
--For each CustomerID and OrderDate, count how many orders they placed in the last 7 days.
CREATE TABLE Orders1 (
  OrderID INT,
  CustomerID INT,
  OrderDate DATE
);

INSERT INTO Orders1 VALUES
(1, 101, '2025-06-01'),
(2, 101, '2025-06-02'),
(3, 101, '2025-06-04'),
(4, 101, '2025-06-07'),
(5, 101, '2025-06-08'),
(6, 102, '2025-06-01'),
(7, 102, '2025-06-03'),
(8, 102, '2025-06-07'),
(9, 102, '2025-06-08'),
(10, 103, '2025-06-08');

select * from orders1;

select o1.CustomerID, o1.orderID , count(o2.OrderDate)  from orders1 o1
inner join orders1 o2 on o1.CustomerID = o2.CustomerID
where o2.OrderDate between dateadd(day, -6, o2.OrderDate) and o1.OrderDate
group by o1.CustomerID, o1.OrderID
order by o1.CustomerID,o1.orderID


--Find the CustomerID and OrderDate combinations where they placed at least 3 orders in the last 7 days.

select * from orders1;

select o1.CustomerID, o1.OrderDate, count(*) as counts from Orders1 o1
left join Orders1 o2 on o1.CustomerID = o2.CustomerID
where o2.OrderDate between dateadd(day, -6, o1.OrderDate) and o1.OrderDate
group by o1.CustomerID , o1.OrderDate
having count(*) >=3
order by o1.CustomerID,o1.OrderDate


-- 3. Show CustomerID, OrderDate, and 7-day order count, but only include customers who made their first order before June 3, 2025.
select o1.CustomerID, o1.OrderDate, count(*) from Orders1 o1
left join Orders1 o2 on o1.CustomerID = o2.CustomerID
where o2.OrderDate between dateadd(day, -6, o1.OrderDate) and o1.OrderDate
and o1.CustomerID in (select CustomerID from Orders1 where OrderDate < '2025-06-03' group by CustomerID )
group by o1.CustomerID , o1.OrderDate
order by o1.CustomerID, o1.OrderDate

select * from orders1;

--4. Identify the CustomerIDs who placed more orders in the last 7 days than the 7 days before that (rolling window comparison).
with temp1 as(

	select o1.CustomerID, 
		   o1.OrderDate,
		   sum(case when o2.OrderDate between dateadd(day, -6, o1.Orderdate) and o1.OrderDate then 1 else 0 end) as current7,
		   sum(case when o2.OrderDate between dateadd(day, -13, o1.Orderdate)and dateadd(day, -7, o1.Orderdate) then 1 else 0 end) as Previous7
	from Orders1 o1
	join Orders1 o2 on o1.CustomerID  = o2.CustomerID
	group by o1.CustomerID, o1.OrderDate

)
select CustomerID from temp1
where Previous7 < current7 and Previous7 <> 0;
