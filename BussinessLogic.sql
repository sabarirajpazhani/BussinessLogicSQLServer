create database Exam
use Exam;
--Section - A
--Q1
create table Patients(	
	PatientID int identity(101, 1) primary key,
	PatientName varchar(80),
	PatientEmail varchar(90) unique,
	PatientAge int,
	PatientPhone varchar(20) unique
);

create table Doctors (
	DoctorID int identity(201, 1) primary key,
	DoctorName varchar(80),
	DoctorEmail varchar(90) unique,
	DepartmentID int,
	DoctorPhone varchar(90) unique
	foreign key (DepartmentID) references Departments (DepartmentID)
);

create table Departments (
	DepartmentID int identity(301, 1) primary key,
	DepartmentName varchar(70)
);

create table Specialization (
	SpecializationID int identity(401,1) primary key,
	DoctorID int,
	DepartmentID int, 
	unique(DoctorID, DepartmentID),
	foreign key (DoctorID) references Doctors(DoctorID),
	foreign key (DepartmentID ) references Departments(DepartmentID)
);

create table Appointments (
	AppointmentID int identity(501,1) primary key,
	PatientID int, 
	DoctorID int,
	AppointmentDate date,
	AppointmentTime time,
	Status varchar(30),
	foreign key (PatientID) references Patients(PatientID),
	foreign key (DoctorID) references Doctors(DoctorID)
);

create index ix_IndexForPatientname on Patients (PatientName) include (PatientEmail, PatientPhone)




--Q2
--Normalizating the table
-- | OrderID | CustomerName | Product1 | Product2 | Product3 | Address | TotalAmount | 

create table Customers (	
	CustomerID int identity(101,1) primary key,
	CustomerName varchar(80),
	CustomerEmail Varchar(90),
	CustomerPhone varchar (20),
	AddressID int,
	foreign key (AddressID) references Addresses(AddressID)
);

create table Addresses(
	AddressID int identity(201,1) primary key,
	StreetName varchar(80),
	CityAndPostalCodeID int,
	Foreign key (CityAndPostalCodeID) references CityAndPostal(CityAndPostalCodeID)
);

create table CityAndPostal(
	CityAndPostalCodeID int identity(301,1) primary key,
	CityName varchar(70),
	PostalCode int
);

create table Products (
	ProductID int identity(301,1) primary key,
	ProductName varchar(80),
	Prices decimal(10,2)
);

create table Orders(
	OrderID int identity(401,1) primary key,
	CustomerID int,
	OrderDate date,
	TotalAmount decimal(10,2),
	foreign key (CustomerID) references Customers(CustomerID)
);

create table OrderDetails(
	OrderDetailsID int identity(501,1) primary key,
	OrderID int,
	ProductID int,
	SubPrice decimal(10,2),
	foreign key (OrderID) references Orders(OrderID),
	foreign key (ProductID) references Products(ProductID)
);





--Section B
--Q3
--Sample table
create table Orders1(
	CustomerID int,
	OrderDate date
);
insert into Orders1 values
(1, '2025-01-05'),
(1, '2025-02-10'),
(1, '2025-03-12'),
(1, '2025-04-09'),
(1, '2025-05-15'),
(1, '2025-06-01'),
(2, '2025-01-15'),
(2, '2025-02-20'),
(2, '2025-03-18'),
(2, '2025-04-10'),
(2, '2025-05-22'),
(3, '2025-02-11'),
(3, '2025-03-11'),
(3, '2025-04-11'),
(3, '2025-05-11'),
(3, '2025-06-11');


select CustomerID from Orders1 
where datediff(MONTH,OrderDate, Getdate()) <=6
group by CustomerID
having Count(distinct month(OrderDate)) = 6




--Q4
create table Employee (
	EmployeeID int,
	ManagerID int,
	Name varchar(80)
);

insert into Employee values
(101, null, 'Alice'),
(102, 101, 'Bob'),
(103, 101, 'Charles'),
(104, 102, 'David');

with Relation AS (
    select EmployeeID, Name, ManagerId
    from Employee
    where ManagerId is null
 
    union all
 
    select e.EmployeeId, e.Name, e.ManagerId
    FROM Employee e
    join Relation r on e.ManagerId = r.EmployeeId
)

select * from Relation;




--Q5
-- Smaple Table with data
Create table Employees1(
	EmplooyeID int, 
	Name varchar(80),
	Salary Decimal(10,2)
);

insert into Employees1 values
(101, 'Alice', 55000),
(102, 'Bob', 65000),
(103, 'Charles', 75000),
(104, 'Dravid', 50000);

select max(Salary) from Employees1
where Salary < (select max(Salary)from Employees1)




--Q6
--create table 
Create table Sales (
	ProductID int,
	SalesDate date, 
	Amount decimal(10,2)
);





--Section C
--Q7 
create table OrderDetails1(
	OrderDetailsID int primary key,
	OrderID int,
	ProductID int,
	Quantity int,
);
insert into OrderDetails1 values
(101, 5001, 1, 2),
(102, 5001, 3, 1),
(103, 5002, 2, 1),
(104, 5002, 4, 1),
(105, 5003, 1, 1),
(106, 5004, 3, 3);

create table Products1(
	ProductID int primary key,
	Price decimal(10,2)
);

insert into Products1 values
(1, 99.99),
(2, 149.50),
(3, 50.00),
(4, 199.00);

create table AuditLog(
	AuditLog int identity(1,1) primary key,
	OrderID int, 
	TotalAmount decimal(10,2),
	TimeStamp time
);

select * from OrderDetails1;
select * from Products;
select * from AuditLog;
Alter procedure sp_OrderDetails
	@OrderID int
as
begin
	declare @TotalAmount decimal(10,2)

	select @TotalAmount = sum(o.Quantity * p.Price) from OrderDetails1 o
	inner join Products1 p on o.ProductID = p.ProductID
	where o.OrderID = @OrderID

	insert into  AuditLog (OrderID, TotalAmount, TimeStamp) values
	(@OrderID, @TotalAmount, cast(getdate() as time ))

	select @TotalAmount;
end;

EXEC sp_OrderDetails @OrderID = 5001;





--Q8. 
create table Customers2 (
	CustomerID int primary key,
	CustomerName varchar(80)
);

create table Orders2 (
	OrderID int primary key,
	CustomerID int, 
	Orderdate date
)

insert into Customers2 (CustomerID, CustomerName) values
(1, 'Arjun Kumar'),
(2, 'Meera Sharma'),
(3, 'Ravi Patel'),
(4, 'Divya Singh');

insert into Orders2 (OrderID, CustomerID, OrderDate) values
(101, 1, '2025-03-01'),   
(102, 2, '2025-02-20'),   
(103, 3, '2025-05-20'),   
(104, 1, '2025-03-05'),   
(105, 4, '2025-03-15');   

	

select * from Orders2
select * from Customers2


alter function getCustomerNotPlaced(
	@Month int
)
returns table
as
return (
	select c.CustomerName from Customers2 c
	inner join Orders2 o on c.CustomerID = o.CustomerID 
	where o.Orderdate > = dateadd(Month, -@Month, cast(getdate() as date))
);	

SELECT * FROM dbo.getCustomerNotPlaced(2);




--Q9
create table Orders3 (
	OrderID int primary key, 
	CustomerID int, 
	OrderDate date,
	TotalAmount decimal (10,2)
);

insert into Orders3 values
(1, 101, '2025-06-09', 1000),
(2, 102, '2025-06-10', 2500),
(3, 103, '2025-06-17', 3500),
(4, 101, '2025-06-10', 500),
(5, 101, '2025-06-11', 2000),
(6, 101, '2025-06-12', 300),
(7, 101, '2025-06-13', 800),
(8, 101, '2025-06-14', 900);


select * from Orders3

alter view vw_CustomerRecentOrder
as
with CTE_Customer as(
	select CustomerID from Orders3
	group by CustomerID
	having count(CustomerID) > 5
)
select CustomerID,  max(OrderDate) as OrderDate, TotalAmount from Orders3 
where CustomerID in (select CustomerID from CTE_Customer) 
group by CustomerID, TotalAmount;




--10
alter function GetSquare (
	@Number int
)
returns int with schemabinding
as
begin
	return @Number * @Number 
end

select dbo.GetSquare(2)





--Q11 
alter trigger tr_PreventProductPrice
on Products1
after update
as 
begin
	if exists (
		select 1 from inserted i
		inner join deleted d on i.ProductID = d.ProductID
		where i.Price < d.Price * 0.8
	)	
	begin
		raiserror('Product price must not be reduced more than 20%',16,1);
		rollback
	end
end

update Products1
set Price = 99.99
where ProductID = 1;

select * from Products1;





--Q12
create table Employee2(
	EmployeeID int primary key,
	EmployeeName varchar(80),
	EmpEmail varchar(80),
	EmpPhone varchar(90)
);
create table EmployeeArchive(
	EmployeeArchiveID int identity(1,1) primary key,
	EmployeeID int, 
	TimeStamps datetime
);

insert into Employee2 values 
(1, 'Alice', 'Alice@gmail.com', '9987875678'),
(2, 'Bob', 'Bob@gmail.com', '9965445667');

select * from Employee2;
select * from EmployeeArchive

create trigger tr_PreventDeleteRow
on Employee2
after delete 
as
begin
	declare @Date datetime , @EmployeeID int
	select @EmployeeID = EmployeeID from deleted
	set @Date = getdate()
	insert into EmployeeArchive values
	(@EmployeeID, @Date);

	print 'Deletion of Row is Successfull'
end

delete from Employee2
where EmployeeID = 1;




--Q13. UDDT
create type PhoneType from varchar(20) not null;

create table Students (
	StudentID int primary key,
	StudentName varchar(80),
	StudentPhone PhoneType check(StudentPhone like '+%' and len(StudentPhone) >= 10)
);

insert into Students values
(1, 'Alice', '+9987876753')




--Q14. 
select * from Students;

create table ErrorLog(
	ErrorLog int identity(1,1) primary key,
	ErrorNumber int,
	ErrorMessage varchar(max),
	Timestamp time
);
select * from ErrorLog;


begin transaction
begin try
	insert into Students values 
	(2, 'Bob', '9987876545')
	commit transaction
end try
begin catch 
	rollback transaction
	print 'Error - occurre - '+ error_message()
	insert into ErrorLog values
	(ERROR_NUMBER(), ERROR_MESSAGE(), cast(getdate() as time))
end catch



--Section E
--Q15.
Create table Trainees(
	TraineeID int identity(1,1) primary key,
	TraineeName varchar(90),
	TraineeEmail varchar(90),
	TraineePhone varchar(30),
	JoinDate date
);

create table Trainers(
	TrainerID int identity(101, 1) primary key, 
	TrainerName varchar(90),
	DomainID int,
	TrainerEmail varchar(90),
	TrainerPhone varchar(30),
	foreign key (DomainID) references Domains(DomainID)
);

create table Domains(
	DomainID int identity(201, 1) primary key,
	DomainName varchar(70)
);

create table Sessions (
	SessionID int identity(301,1) primary key,
	SessionDate date,
	SessionTime time,
	TraineriD int,
	TraineeID int,
	TopicID int,
	foreign key (TrainerID) references Trainers(TrainerID),
	foreign key (TraineeID) references Trainees(TraineeID),
	foreign key (TopicID) references Topics(TopicID)
);

create table Topics(
	TopicID int identity(401,1) primary key,
	TopicName varchar(80)
);

create table Attendance(
	AttendanceID int identity(501,1) primary key,
	AttendanceDate date,
	SessionID int,
	TraineeID int, 
	StatusID int,

	foreign key (SessionID) references Sessions(SessionID),
	foreign key (TraineeID) references Trainees(TraineeID),
	foreign key (StatusID) references A_Status(StatusID)
);

create table A_Status(
	StatusID int identity(601,1) primary key,
	StatusName varchar(60)
);



insert into Domains (DomainName)
values 
('Full Stack Development'),
('Data Science'),
('Cloud Computing');

insert into Topics (TopicName)
values 
('HTML & CSS Basics'),
('Python Programming'),
('AWS Introduction');

insert into Trainees (TraineeName, TraineeEmail, TraineePhone, JoinDate)
values 
('Sabari Raj', 'sabari@example.com', '9876543210', '2025-06-01'),
('JS', 'JS@example.com', '9123456780', '2025-06-03');

insert into Trainers (TrainerName, DomainID, TrainerEmail, TrainerPhone)
values
('Subha', 201, 'subha@trainers.com', '9000012345'),
('Sharmila', 202, 'sharmila@trainers.com', '9000098765');

insert into Sessions (SessionDate, SessionTime, TrainerID, TraineeID, TopicID)
values 
('2025-06-10', '10:00:00', 101, 1, 401),
('2025-06-11', '14:00:00', 102, 2, 402),
('2025-06-12', '11:30:00', 101, 2, 403);

insert into A_Status (StatusName)
values 
('Present'),
('Absent');

insert into Attendance (AttendanceDate, SessionID, TraineeID, StatusID)
values
('2025-06-10', 301, 1, 601),
('2025-06-11', 302, 2, 602),
('2025-06-12', 303, 2, 601);


select * from Domains
select * from Topics
select * from Trainees
select * from Trainers
select * from Sessions
select * from A_Status
Select * from Attendance

-- Q15 *(2)
create procedure sp_Attendance 
	@SessionID int,
	@TraineeID int,
	@StatusID int
as
begin
	insert into Attendance values 
	(Getdate(), @SessionID, @TraineeID, @StatusID, cast(getdate() as time))

	print 'Success'
end;

exec sp_attendance 303, 2, 601


--Q15 (3)
create or alter view vw_TraineeAttendanceReport
as
	select a.TraineeID, t.TraineeName, (cast(count(*) as float)/s.TotalSession)*100 as AttendanceRate from Attendance a
	join (select TraineeID, count(*) as TotalSession from Attendance group by TraineeID) s on a.TraineeID = s.TraineeID
	join Trainees t on t.TraineeID = a.TraineeID
	where a.StatusID = 601 
	group by a.TraineeID, t.TraineeName, s.TotalSession;

select * from vw_TraineeAttendanceReport;


--Q15 (4) 
create table warning (
	WarningID int identity(4001, 1) primary key,
	TraineeID int,
	Percentage int
);

create function GetPrecentage()
returns table
as
return(
	select a.TraineeID, t.TraineeName, (cast(count(*) as float)/s.TotalSession)*100 as AttendanceRate from Attendance a
	join (select TraineeID, count(*) as TotalSession from Attendance group by TraineeID) s on a.TraineeID = s.TraineeID
	join Trainees t on t.TraineeID = a.TraineeID
	where a.StatusID = 601 
	group by a.TraineeID, t.TraineeName, s.TotalSession
)

create trigger tr_Warning
on Attendance
after insert 
as
begin
	insert into Warning (TraineeID, Percentage)
	select TraineeID, AttendanceRate from dbo.GetPrecentage()
	where AttendanceRate < 70
end

select * from Warning;

insert into Attendance values('2025-06-20', 301, 1, 601,'10:07:11.6966667')
