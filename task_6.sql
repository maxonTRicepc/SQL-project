
use Hotel
go


/*Процедура №1*/
go 
create procedure Paytype_var @cl_id int
as
	begin
		declare @num_booking int = (select BookingID from Booking where ClientID = @cl_id)
		declare @type nvarchar(10) = (select PaymentType from Accommodation where BookingID = @num_booking)
		declare @price int = (select TotalCost from Accommodation where BookingID = @num_booking)
		if (@type = 'Карта')
			return @price * 0.95
		else
			return @price * 0.9
	end

drop procedure Paytype_var

/*Проверка процедуры*/
declare @cl int = 1
declare @ans int

exec @ans = Paytype_var @cl
print @ans


/*Процедура №2*/
go
create procedure info_client @cl_id int, @inf_check nvarchar(20), @info nvarchar(100) output
as
	begin
		declare @num_booking int = (select BookingID from Booking where ClientID = @cl_id)
		if (@inf_check = 'Phone')
			begin
				declare @phone nvarchar(20) = (select Contact from Clients where ClientID = @cl_id)
				set @info = 'Phonenumber is ' + @phone
			end
		if (@inf_check = 'Birthdate')
			begin
				declare @bdate date = (select BirthDate from Clients where ClientID = @cl_id)
				set @info = 'Birthdate is ' + convert(nvarchar, @bdate)
			end
		if (@inf_check = 'Living Time')
			begin
				declare @time int = (select LivingTime from Accommodation where BookingID = @num_booking)
				set @info = 'Living Time is ' + convert(nvarchar, @time) + ' days'
			end
	end

drop procedure info_client

declare @cl int = 2
declare @check nvarchar(20) = 'Phone'
declare @ans nvarchar(100)
exec info_client @cl, @check, @ans output
print @ans

declare @cl2 int = 1
declare @check2 nvarchar(20) = 'Birthdate'
declare @ans2 nvarchar(100)
exec info_client @cl2, @check2, @ans2 output
print @ans2

declare @cl3 int = 1
declare @check3 nvarchar(20) = 'Living Time'
declare @ans3 nvarchar(100)
exec info_client @cl3, @check3, @ans3 output
print @ans3


/*Процедура №3*/
go
create procedure cleaners_work @ddate smalldatetime, @empl nvarchar(500) output
as
	begin
		declare @lastdate smalldatetime = dateadd(day, 1, @ddate)
		declare @check_date smalldatetime
		declare curs cursor local scroll for
		select Date_Time from Cleaning

		open curs
		fetch curs into @check_date
		while @@FETCH_STATUS = 0
			begin
				declare @date smalldatetime = (select top 1 Date_Time from Cleaning)
				if (@date > @ddate and @date < @lastdate)
					begin
						declare @id int = (select top 1 CleanerID from Cleaning where Date_Time = @date)
						declare @name nvarchar(100) = (select top 1 CleanerName from Cleaners where CleanerID = @id)
						set @empl = @name
					end
				fetch next from curs into @check_date
			end
	end

drop procedure cleaners_work

declare @chch smalldatetime = '2022-06-08 00:00:00'
declare @ans nvarchar(500)

exec cleaners_work @chch, @ans output
print @ans

/*Процедура №4*/
go
create procedure priceHike @idRoom int, @percent int
as
	begin
		declare @price int = (select DayCost from RoomTypes where TypeID = @idRoom)
		declare @name nvarchar(15) = (select TypeName from RoomTypes where TypeID = @idRoom)
		declare @newprice int = @price * (1 + @percent / 100.0)
		if (@idRoom != 4 and @idRoom != 5)
			begin
				print 'Цена для ' + @name + ' будет изменена на: ' + convert(nvarchar, @newprice)
			end
		else
			print 'Цена для ' + @name + ' не может быть изменена!'
	end

drop procedure priceHike

declare @id int = 1
declare @per int = 15
exec priceHike @id, @per

declare @id1 int = 4
declare @per1 int = 15
exec priceHike @id1, @per1

/*Процедура №5*/
go
create procedure accom_upd @accid int, @days int
as
	begin
		declare @bookid int = (select BookingID from Accommodation where LivingID = @accid)
		declare @idr int = (select RoomID from Booking where BookingID = @bookid)
		declare @typeRoom int = (select TypeID from Rooms where RoomID = @idr)
		declare @price int = (select DayCost from RoomTypes where TypeID = @typeRoom)

		update Accommodation
		set Departure = DATEADD(day, @days, Departure), 
			LivingTime = LivingTime + @days,
			TotalCost = TotalCost + @days * @price
		where LivingID = @accid
	end

drop procedure accom_upd

SELECT * FROM Accommodation

declare @id int = 9
declare @day int = 2
exec accom_upd @id, @day