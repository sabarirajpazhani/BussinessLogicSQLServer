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


--5.  Create a daily summary: for each OrderDate, how many CustomerIDs had at least one order in the last 7 days (unique customer count).
select o1.OrderDate, count(o1.CustomerID) as CustomerCount from Orders1 o1
left join orders1 o2 on o1.CustomerID = o2.CustomerID
where o2.OrderDate between dateadd(day, -6, o1.Orderdate) and o1.OrderDate
group by o1.OrderDate
order by o1.OrderDate;

select * from orders1;


--Get top 2 paid employees per department whose salary is above department average
--table(EmpID, EmpName, DeptID, Salary)
create table Employee (
	EmpID int primary key,
	EmpName varchar(80),
	DeptID int, 
	Salary decimal(10,2)
);

insert into Employee values
(101, 'Alice',     1, 72000.00),
(102, 'Bob',       1, 85000.00),
(103, 'Charlie',   1, 60000.00),
(104, 'Diana',     1, 95000.00),
(105, 'Ethan',     1, 50000.00),
 
-- Department 2
(106, 'Fiona',     2, 68000.00),
(107, 'George',    2, 75000.00),
(108, 'Hannah',    2, 82000.00),
(109, 'Ian',       2, 57000.00),
(110, 'Julia',     2, 61000.00),
 
-- Department 3
(111, 'Kevin',     3, 92000.00),
(112, 'Laura',     3, 98000.00),
(113, 'Mike',      3, 72000.00),
(114, 'Nina',      3, 55000.00),
(115, 'Oscar',     3, 64000.00);

select * from Employee;





with DepartmentAvg as (
	Select DeptID, avg(Salary)as DeptAvg from Employee
	group by DeptID
),
Salries as (
	select EmpID, EmpName, DeptID, salary, row_number() over (partition by DeptID order by Salary Desc) as rank from Employee

)
select e.EmpID, e.EmpName, e.DeptID, s.Salary from Employee e
inner join DepartmentAvg d on e.DeptID = d.DeptID
inner join Salries s on e.EmpID = s.EmpID
where d.DeptAvg < e.Salary and s.rank <=2
 




 Select DeptID, avg(Salary)as DeptAvg from Employee
	group by DeptID

/*select top 2 e.EmpName, d.DeptID, e.Salary  from Employee e
					inner join DepartmentAvg d on d.DeptID = e.DeptID
					group by e.EmpName, d.DeptID, e.Salary
					Order by e.salary desc*/






create table Orderss
(
	OrderID int primary key,
	CustomerID int,
	OrderDate date,
	PurchaseAmt decimal(10,2)
)
 
insert into Orderss values(101,1,'2025-06-10',100),(102,1,'2025-06-10',150),(103,2,'2025-06-10',500)
,(104,1,'2025-06-11',300),(105,2,'2025-06-11',100),(106,1,'2025-06-12',700)

select * from Orderss;



with Orders as(
	select CustomerID, OrderDate from Orderss
	group by CustomerID, OrderDate
)
select distinct o1.CustomerID from Orders o1
join Orders o2 on o1.CustomerID = o2.CustomerID
and datediff(day, o1.OrderDate, o2.OrderDate) = 1



--"Show running total of sales for each customer, reset when month changes."
 
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    CustomerID INT,
    SaleAmount DECIMAL(10, 2),
    SaleDate DATE
);
INSERT INTO Sales (SaleID, CustomerID, SaleAmount, SaleDate) VALUES
(1, 101, 1000.00, '2025-01-05'),
(2, 101, 1500.00, '2025-01-10'),
(3, 101, 2000.00, '2025-02-01'),
(4, 101, 1200.00, '2025-02-05'),
(5, 101, 1800.00, '2025-03-01'),
(6, 102, 500.00,  '2025-01-03'),
(7, 102, 700.00,  '2025-01-25'),
(8, 102, 300.00,  '2025-02-10'),
(9, 102, 600.00,  '2025-02-20'),
(10, 102, 400.00, '2025-03-05');
