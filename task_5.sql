/*№6*/

/*Разработать и реализовать триггеры AFTER для операций INSERT, UPDATE, DELETE*/

--after insert trigger

create trigger insert_accomm
on Accommodation
after insert
as
	begin
		declare @Book_id int = (select BookingID from inserted)
		declare @Arr smalldatetime = (select Arrival from inserted)
		declare @Dep smalldatetime = (select Departure from inserted)
		declare @Live int = (select LivingTime from inserted)
		declare @PayType nvarchar(10) = (select PaymentType from inserted)
		if (@dep < @arr)
			begin
				rollback tran
				raiserror ('Ошибка заполнения даты выезда! Дата выезда не может идти раньше даты заезда - будет установлено значение NULL', 1, 1)
				declare @new_dep smalldatetime = null
				insert Accommodation
					(BookingID, Arrival, Departure, LivingTime, PaymentType)
				values
					(@Book_id, @Arr, @new_dep, @Live, @PayType)
			end
	end

insert Accommodation
	(BookingID, Arrival, Departure, LivingTime, PaymentType)
values
	(4, '2022-07-06 12:00:00', '2022-05-06 09:30:00', 4, N'Наличные')

select * from Accommodation

drop trigger insert_accomm


--after update trigger

select * from Clients

create trigger update_clients
on Clients
after update
as
	begin
		declare @Client_id int = (select ClientID from inserted)
		declare @Car_count int = (select Car from inserted)
		declare @Bk_id int = (select BookingID from Booking where ClientID = @Client_id)
		declare @car_client bit = (select Car from Clients where ClientID = @Client_id)
		declare @Accomm_id int = (select LivingID from Accommodation where BookingID = @Bk_id)
		if (@Car_count = 1)
			begin
				rollback tran
				raiserror ('Никакие значения не были изменены!', 1, 2)
			end
		else
			update Parking
			set CarNum = 'отсутствует'
			where LivingID = @Accomm_id
	end

update Clients
set Car = 1 
where ClientID = 1

update Clients
set Car = 0 
where ClientID = 1

select * from Clients
select * from Parking

drop trigger update_clients


--after delete trigger

create trigger delete_orderedserv
on OrderedServices
after delete
as
	begin
		declare @idserv int = (select ServiceID from deleted)
		declare @idbook int = (select LivingID from deleted)
		declare @price int = (select ServiceCost from MainServices where ServiceID = @idserv)

		update Accommodation
		set TotalCost = TotalCost - @price
		where LivingID = @idbook
	end


delete from OrderedServices where LivingID = 5

select * from OrderedServices
select * from Accommodation

drop trigger delete_orderedserv



/*Создайте представление на основе нескольких базовых таблиц и сделайте его обновляемым с помощью триггера INSTEAD OF*/

create view Accom_serv_parking
as
	select Accommodation.BookingID, Accommodation.Arrival, Accommodation.Departure, Accommodation.LivingTime, Accommodation.PaymentType,
	       Accommodation.TotalCost, OrderedServices.ServiceID, OrderedServices.Date_Time, Parking.PlaceID, Parking.CarNum
	from Accommodation
		inner join OrderedServices on OrderedServices.LivingID = Accommodation.LivingID
		inner join Parking on Parking.LivingID = Accommodation.LivingID

select * from Accom_serv_parking
drop view Accom_serv_parking

--instead of insert trigger

create trigger trigger_view1
on Accom_serv_parking
instead of insert
as
	begin
		declare @BookId int = (select BookingID from inserted)
		declare @Arr smalldatetime = (select Arrival from inserted)
		declare @Dep smalldatetime = (select Departure from inserted)
		declare @Liv int = (select LivingTime from inserted)
		declare @Pay nvarchar(10) = (select PaymentType from inserted)
		declare @Cost int = (select TotalCost from inserted)
		declare @Serv int = (select ServiceID from inserted)
		declare @Date smalldatetime = (select Date_Time from inserted)
		declare @Place int = (select PlaceID from inserted)
		declare @Car nvarchar(10) = (select CarNum from inserted)
		begin
			insert into Accommodation
				(BookingID, Arrival, Departure, LivingTime, PaymentType, TotalCost)
			values
				(@BookId, @Arr, @Dep, @Liv, @Pay, @Cost)
			insert into OrderedServices
				(LivingID, ServiceID, Date_Time)
			values
				(@BookId, @Serv, @Date)
			insert into Parking
				(PlaceID, LivingID, CarNum)
			values
				(@Place, @BookId, @Car)
		end
	end

select * from Accommodation
select * from OrderedServices
select * from Parking
select * from Accom_serv_parking

insert into Accom_serv_parking
values
	(3, '2022-16-12 12:00:00', '2022-21-12 12:00:00', 5, 'Карта', 5000, 10, '2022-17-12 10:00:00', 44, 'н444нн 164')

drop trigger trigger_view1

--instead of update

create trigger trigger_view2
on Accom_serv_parking
instead of update
as
	begin
		declare @BookId int = (select BookingID from inserted)
		declare @Pay nvarchar(10) = (select PaymentType from inserted)
		begin
			update Accommodation
			set PaymentType = @Pay
			where BookingID = @BookId
		end
	end

select * from Accommodation
select * from Accom_serv_parking

update Accom_serv_parking
set PaymentType = 'Оплата'
where BookingID = 3

drop trigger trigger_view2

--instead of delete

/*Удаление строки из представления*/
create trigger trigger_view3
on Accom_serv_parking
instead of delete
as 
	begin
		declare @BookId int = (select BookingID from deleted)
		delete from OrderedServices where LivingID = @BookId
		delete from Parking where LivingID = @BookId
		delete from Accommodation where BookingID = @BookId
	end

select * from Accommodation
select * from OrderedServices
select * from Parking
select * from Accom_serv_parking

delete from Accom_serv_parking where BookingID = 3

drop trigger trigger_view3