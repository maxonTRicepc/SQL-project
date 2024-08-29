use Hotel_orig
go

--#9
/*Запрос с использованием автономных подзапросов*/

select Arrival, Departure,TotalCost
from Accommodation
where TotalCost < (select avg(TotalCost)
				   from Accommodation
				   where PaymentType = 'Карта') 
	  and PaymentType = 'Карта' 

select * from Accommodation

/*Создание запроса с использованием коррелированных подзапросов в предложении SELECT и WHERE*/
select (select ClientName
		from Clients
		where Clients.ClientID = Booking.ClientID) as Name,
		Departure
from Booking
where GuestsNum = 2

/*Выводит имя клиента и время выезда, но только тех клиентов, котрые выехали раньше времени в брони*/
select (select ClientName
		from Clients
		where Clients.ClientID = Booking.ClientID) as Name,
		Departure
from Booking
where Departure > (select Departure
				   from Accommodation
				   where BookingID = Booking.BookingID)


/*Запрос с использованием временных таблиц*/
/*Создаём временную таблицу на основе таблицы клиентов, в запросе используем коррелированный подзапрос, который выводит имя, телефон, время заезда людей с машиной*/
select ClientID, ClientName, Contact, Region, Car
into #tempTable
from Clients

--drop table #tempTable

select ClientName as Имя,
	   Contact as Номер_телефона,
	   (select Arrival
	    from Booking
		where Booking.ClientID = #tempTable.ClientID) as Заезд
from #tempTable
where Car = 1

/*Запрос с использованием обобщенных табличных выражений (CTE)*/
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

/*Слияние данных (INSERT, UPDATE) c помощью инструкции MERGE*/
select *
into #tempAcc
from Accommodation
where PaymentType = 'Наличные'

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

/*Запрос с использованием оператора PIVOT*/
SELECT 'SumCost' AS Sorted_by_Payment,   
  [Наличные], [Карта] 
FROM
(
  SELECT PaymentType, TotalCost 
  FROM Accommodation
) AS SourceTable  
PIVOT  
(  
  sum(TotalCost)  
  FOR PaymentType IN ([Наличные], [Карта])
) AS PivotTable;

/*Запрос с использованием оператора UNPIVOT*/
select ClientName, info
from Clients
unpivot(
		info for col in ([Contact], [Region])
		) as UnpivotTable;

select * from Clients

/*Запрос с использованием GROUP BY с операторами ROLLUP, CUBE и GROUPING SETS*/

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

/*Секционирование с использованием OFFSET FETCH*/
select *
from RoomServices
order by RoomServiceCost
offset 1 rows fetch next 4 rows only

/*Запросы с использованием ранжирующих оконных функций. ROW_NUMBER() нумерация строк*/
--ROW_NUMBER()
/*Обычная нумерация строк*/
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
	   ntile(4) over (order by ServiceCost desc) as ЦеновойДиапазон
from MainServices

/*Реализовать обработчик ошибок в коде используя TRY/CATCH.
  Добавить в область блока CATCH возможность получения сведений об ошибке с использованием функций ERROR, приведшей к выполнению данного блока.*/

begin try
	insert Accommodation
		(BookingID, Arrival, Departure, LivingTime, PaymentType, TotalCost)
	values
		(3, NULL, NULL, 1, N'Карта', 4444);
end try
begin catch
	print 'Error ' + CONVERT(nvarchar, ERROR_NUMBER()) + ': ' + ERROR_MESSAGE()
	print 'Установлено текущее значение даты'
	insert Accommodation
		(BookingID, Arrival, Departure, LivingTime, PaymentType, TotalCost)
	values
		(3, getdate(), NULL, 1, N'Карта', 4444);
end catch

select * from Accommodation

--delete from Accommodation where TotalCost = 4444


/*Использование THROW, чтобы передать сообщение об ошибке клиенту*/
/*Инструкция, которая создаёт сообщение об ошибке*/
begin try
	insert Accommodation
		(BookingID, Arrival, Departure, LivingTime, PaymentType, TotalCost)
	values
		(3, NULL, NULL, 1, N'Карта', 4444);
end try
begin catch
	throw 77777, 'Время заезда не может быть NULL', 1;
	print 'Установлено текущее значение даты'
end catch

/*Контроль транзакций с BEGIN и COMMIT*/
INSERT Cleaning (CleanerID, LivingID, Date_Time) VALUES
	(4, 4, getdate());

select * from Accommodation
select * from Cleaning
select * from Cleaners

begin tran
	update Accommodation
	set PaymentType = 'Наличные'
	where BookingID = 9

	insert Cleaners
		(CleanerName)
	values
		('Иннокентий')

	delete from Cleaning 
	where CleanerID = 4 and LivingID = 4
commit tran

select * from Accommodation
select * from Cleaning
select * from Cleaners

/*
delete from Cleaning where CleanerID = 4 and LivingID = 4

delete from Cleaners where CleanerName = 'Иннокентий'

update Accommodation
set PaymentType = 'Карта'
where BookingID = 9
*/

/*Использование XACT_ABORT*/
select * from Accommodation

set xact_abort on;

begin tran
	update Accommodation
	set TotalCost = 11111
	where BookingID = 4

	insert Accommodation
		(BookingID, Arrival, Departure, LivingTime, PaymentType, TotalCost)
	values
		(3, NULL, NULL, 1, N'Карта', 1000);
commit tran

select * from Accommodation

/*Добавление логики обработки транзакций в блоке CATCH*/
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
	select ERROR_NUMBER() as Номер,
		   ERROR_MESSAGE() as Сообщение
	return
end catch
commit tran


begin try
	begin tran
	insert MainServices
		(ServiceName, ServiceCost)
	values
		('Аренда зонтика', NULL);
end try
begin catch
	rollback tran
	select ERROR_NUMBER() as Номер,
		   ERROR_MESSAGE() as Сообщение
	return
end catch
commit tran

select * from MainServices