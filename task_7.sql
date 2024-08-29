use Hotel;
go

create table AdminData(
	ID int IDENTITY(1,1) not null,
	login_user varchar(50) not null,
	password_user varchar(50) not null
)

INSERT AdminData
	(login_user, password_user)
VALUES 
	('admin', 'admin');

CREATE TABLE Users(
	ID int IDENTITY(1,1) not null,
	phone_number_user varchar(50) not null,
	password_user varchar(50) not null
)

INSERT Users
	(phone_number_user, password_user)
VALUES
	('12345','12345');

select * from AdminData
select * from Users

create view client_booking_accomm_ver2 as
select Clients.ClientName, Clients.Gender, Clients.Contact, Clients.Region, Clients.BirthDate, Clients.Car,
	   Booking.RoomID, Booking.GuestsNum, Booking.Arrival as Arr, Booking.Departure as Dep
from Clients
	join Booking ON Booking.ClientID = Clients.ClientID

select * from client_booking_accomm_ver2

drop view client_booking_accomm_ver2

create trigger trig_8_2
on client_booking_accomm_ver2
instead of insert
as
	begin
		declare @cl nvarchar(100) = (select ClientName from inserted)
		declare @gen nvarchar(3) = (select Gender from inserted)
		declare @con nvarchar(20) = (select Contact from inserted)
		declare @reg nvarchar(30) = (select Region from inserted)
		declare @birth date = (select BirthDate from inserted)
		declare @car bit = (select Car from inserted)
		declare @room int = (select RoomID from inserted)
		declare @ggg int = (select GuestsNum from inserted)
		declare @ar smalldatetime = (select Arr from inserted)
		declare @dep smalldatetime = (select Dep from inserted)
		begin
			insert into Clients 
				(ClientName, Gender, Contact, Region, BirthDate, Car)
			values
				(@cl, @gen, @con, @reg, @birth, @car)
			declare @cll int = (select ClientID from Clients where BirthDate = @birth)
			insert into Booking 
				(ClientID, RoomID, GuestsNum, Arrival, Departure)
			values
				(@cll, @room, @ggg, @ar, @dep)
		end
	end

drop trigger trig_8_2

insert into client_booking_accomm_ver2 
values
	('ya ne mogu', 'Ъ', '+79873258599', 'Саратов', '2002-08-14', 1, 28, 3, '2011-08-06 12:00:00', '2022-15-06 10:00:00')

select * from client_booking_accomm_ver2
select * from Clients
select * from Booking