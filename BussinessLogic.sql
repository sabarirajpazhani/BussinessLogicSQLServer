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

-
-- Sample Data for 7-Day Rolling Average of Sales (Join Method)
CREATE TABLE Sales (
  ProductID INT,
  SalesDate DATE,
  Amount DECIMAL(10,2)
);

INSERT INTO Sales VALUES
(1, '2025-06-01', 200.00),
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

select s1.ProductID, s1.SalesDate, avg(s2.Amount) from  Sales s1
join Sales s2 on s1.ProductID = s2.ProductID and s2.SalesDate BETWEEN DATEADD(DAY, -6, S1.SalesDate) AND S1.SalesDate

group by s1.ProductID, s1.SalesDate
order by s1.ProductID, s1.SalesDate