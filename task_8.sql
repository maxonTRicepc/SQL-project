use Hotel_orig
go

--#9
/*������ � �������������� ���������� �����������*/

select Arrival, Departure,TotalCost
from Accommodation
where TotalCost < (select avg(TotalCost)
				   from Accommodation
				   where PaymentType = '�����') 
	  and PaymentType = '�����' 

select * from Accommodation

/*�������� ������� � �������������� ��������������� ����������� � ����������� SELECT � WHERE*/
select (select ClientName
		from Clients
		where Clients.ClientID = Booking.ClientID) as Name,
		Departure
from Booking
where GuestsNum = 2

/*������� ��� ������� � ����� ������, �� ������ ��� ��������, ������ ������� ������ ������� � �����*/
select (select ClientName
		from Clients
		where Clients.ClientID = Booking.ClientID) as Name,
		Departure
from Booking
where Departure > (select Departure
				   from Accommodation
				   where BookingID = Booking.BookingID)


/*������ � �������������� ��������� ������*/
/*������ ��������� ������� �� ������ ������� ��������, � ������� ���������� ��������������� ���������, ������� ������� ���, �������, ����� ������ ����� � �������*/
select ClientID, ClientName, Contact, Region, Car
into #tempTable
from Clients

--drop table #tempTable

select ClientName as ���,
	   Contact as �����_��������,
	   (select Arrival
	    from Booking
		where Booking.ClientID = #tempTable.ClientID) as �����
from #tempTable
where Car = 1

/*������ � �������������� ���������� ��������� ��������� (CTE)*/
select Region
into #tempCity
from Clients

select * from #tempCity

drop table #tempCity

with tempCTE
as
	(
	select ROW_NUMBER () over (
		   PARTITION BY Region
		   order by Region) as checkp,
	*
	from #tempCity
	)
delete from tempCTE where checkp > 1 or Region is null

select * from #tempCity

/*������� ������ (INSERT, UPDATE) c ������� ���������� MERGE*/
select *
into #tempAcc
from Accommodation
where PaymentType = '��������'

select * from #tempAcc
--drop table #tempAcc

merge #tempAcc
using Accommodation
on (#tempAcc.LivingID = Accommodation.LivingID)
when matched then
	update set #tempAcc.TotalCost = #tempAcc.TotalCost * 0.95
when not matched then
	insert 
		(BookingID, Arrival, Departure, LivingTime, PaymentType, TotalCost) 
	values
		(Accommodation.BookingID, Accommodation.Arrival, Accommodation.Departure, Accommodation.LivingTime, Accommodation.PaymentType, Accommodation.TotalCost);

select * from #tempAcc

/*������ � �������������� ��������� PIVOT*/
SELECT 'SumCost' AS Sorted_by_Payment,   
  [��������], [�����] 
FROM
(
  SELECT PaymentType, TotalCost 
  FROM Accommodation
) AS SourceTable  
PIVOT  
(  
  sum(TotalCost)  
  FOR PaymentType IN ([��������], [�����])
) AS PivotTable;

/*������ � �������������� ��������� UNPIVOT*/
select ClientName, info
from Clients
unpivot(
		info for col in ([Contact], [Region])
		) as UnpivotTable;

select * from Clients

/*������ � �������������� GROUP BY � ����������� ROLLUP, CUBE � GROUPING SETS*/

--Rollup
select DATEPART(day, Arrival) as Day,
	   PaymentType,
	   sum(TotalCost) as sumDay
from Accommodation
group by
rollup (DATEPART(day, Arrival), PaymentType)

--Cube
select DATEPART(day, Arrival) as Day,
	   PaymentType,
	   sum(TotalCost) as sumDay
from Accommodation
group by
cube (DATEPART(day, Arrival), PaymentType)

--Grouping sets
select DATEPART(day, Arrival) as Day,
	   PaymentType,
	   sum(TotalCost) as sumDay
from Accommodation
group by
grouping sets (DATEPART(day, Arrival), PaymentType)

/*��������������� � �������������� OFFSET FETCH*/
select *
from RoomServices
order by RoomServiceCost
offset 1 rows fetch next 4 rows only

/*������� � �������������� ����������� ������� �������. ROW_NUMBER() ��������� �����*/
--ROW_NUMBER()
/*������� ��������� �����*/
select TypeName, 
	   Area,
	   Fridge,
	   DayCost,
	   ROW_NUMBER () over (order by DayCost desc) as Rows
from RoomTypes

--RANK()
select TypeName, 
	   Area,
	   Fridge,
	   DayCost,
	   rank () over (order by DayCost desc) as Rows
from RoomTypes

--DENSE_RANK()
select TypeName, 
	   Area,
	   Fridge,
	   DayCost,
	   dense_rank () over (order by DayCost desc) as Rows
from RoomTypes

--NTILE()
select ServiceName,
	   ServiceCost,
	   ntile(4) over (order by ServiceCost desc) as ���������������
from MainServices

/*����������� ���������� ������ � ���� ��������� TRY/CATCH.
  �������� � ������� ����� CATCH ����������� ��������� �������� �� ������ � �������������� ������� ERROR, ��������� � ���������� ������� �����.*/

begin try
	insert Accommodation
		(BookingID, Arrival, Departure, LivingTime, PaymentType, TotalCost)
	values
		(3, NULL, NULL, 1, N'�����', 4444);
end try
begin catch
	print 'Error ' + CONVERT(nvarchar, ERROR_NUMBER()) + ': ' + ERROR_MESSAGE()
	print '����������� ������� �������� ����'
	insert Accommodation
		(BookingID, Arrival, Departure, LivingTime, PaymentType, TotalCost)
	values
		(3, getdate(), NULL, 1, N'�����', 4444);
end catch

select * from Accommodation

--delete from Accommodation where TotalCost = 4444


/*������������� THROW, ����� �������� ��������� �� ������ �������*/
/*����������, ������� ������ ��������� �� ������*/
begin try
	insert Accommodation
		(BookingID, Arrival, Departure, LivingTime, PaymentType, TotalCost)
	values
		(3, NULL, NULL, 1, N'�����', 4444);
end try
begin catch
	throw 77777, '����� ������ �� ����� ���� NULL', 1;
	print '����������� ������� �������� ����'
end catch

/*�������� ���������� � BEGIN � COMMIT*/
INSERT Cleaning (CleanerID, LivingID, Date_Time) VALUES
	(4, 4, getdate());

select * from Accommodation
select * from Cleaning
select * from Cleaners

begin tran
	update Accommodation
	set PaymentType = '��������'
	where BookingID = 9

	insert Cleaners
		(CleanerName)
	values
		('����������')

	delete from Cleaning 
	where CleanerID = 4 and LivingID = 4
commit tran

select * from Accommodation
select * from Cleaning
select * from Cleaners

/*
delete from Cleaning where CleanerID = 4 and LivingID = 4

delete from Cleaners where CleanerName = '����������'

update Accommodation
set PaymentType = '�����'
where BookingID = 9
*/

/*������������� XACT_ABORT*/
select * from Accommodation

set xact_abort on;

begin tran
	update Accommodation
	set TotalCost = 11111
	where BookingID = 4

	insert Accommodation
		(BookingID, Arrival, Departure, LivingTime, PaymentType, TotalCost)
	values
		(3, NULL, NULL, 1, N'�����', 1000);
commit tran

select * from Accommodation

/*���������� ������ ��������� ���������� � ����� CATCH*/
begin try
	begin tran
		select (select RoomID
				from Booking
				where Booking.BookingID = Accommodation.BookingID) as Room,
				PaymentType,
				TotalCost,
				ntile(3) over (order by TotalCost desc) as Groups
		from Accommodation
end try
begin catch
	rollback tran
	select ERROR_NUMBER() as �����,
		   ERROR_MESSAGE() as ���������
	return
end catch
commit tran


begin try
	begin tran
	insert MainServices
		(ServiceName, ServiceCost)
	values
		('������ �������', NULL);
end try
begin catch
	rollback tran
	select ERROR_NUMBER() as �����,
		   ERROR_MESSAGE() as ���������
	return
end catch
commit tran

select * from MainServices