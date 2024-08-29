use hotel
go

/*№5*/

/*Задача 1 Создание представлений*/

/*#1*/

create view client_booking_accomm as
select Clients.ClientName as Клиент, Clients.Contact as Номер_Телефона, Booking.RoomID as Номер, Accommodation.Arrival as Факт_заезд, Accommodation.Departure as Факт_выезд
from Clients
	join Booking ON Booking.ClientID = Clients.ClientID
	join Accommodation ON Accommodation.BookingID = Booking.BookingID

select * from client_booking_accomm
drop view client_booking_accomm

/*#2*/

create view room_booking as
select Rooms.RoomID as Номер, Booking.Arrival as Время_заезда, Booking.Departure as Время_выезда, RoomTypes.TypeName as ТипНомера
from Rooms
	join Booking on Booking.RoomID = Rooms.RoomID
	join RoomTypes on RoomTypes.TypeID = Rooms.TypeID
where RoomTypes.TypeName like 'Люкс%' or RoomTypes.TypeName like 'Полу%'

select * from room_booking
drop view room_booking

/*#3*/

create view fullinfo_acccomm as
select Accommodation.BookingID as НомерБрони, Accommodation.Arrival as Время_заезда, Accommodation.Departure as Время_выезда, Accommodation.LivingTime as ВремяПроживания, RoomServices.RoomServiceName as Услуга, RoomServices.RoomServiceCost as СтоимостьУслуги,
	   Cleaning.Date_Time as ВремяУборки, Cleaners.CleanerName as ИмяГорничной
from Accommodation
	full join OrderedServices on OrderedServices.LivingID = Accommodation.LivingID
	full join RoomServices on RoomServices.RoomServiceID = OrderedServices.ServiceID
	full join Cleaning on Cleaning.LivingID = Accommodation.LivingID
	full join Cleaners on Cleaners.CleanerID = Cleaning.CleanerID

select * from fullinfo_acccomm
drop view fullinfo_acccomm

/*Задача 2: Создание обновляемого представления*/

/*#1*/
create view checkoption_view1 as
select ClientName, Gender, Contact, Region, BirthDate, Car
from Clients
where Car > 0

insert into checkoption_view1
	(ClientName, Gender, Contact, Region, BirthDate, Car)
values 
	('Кузнецов Егор Дмитриевич', 'Ы', '+79873258599', 'Саратов', '2002-08-14', 0)

select * from checkoption_view1
drop view checkoption_view1

create view checkoption_view1_1 as
select ClientName, Gender, Contact, Region, BirthDate, Car
from Clients
where Car > 0
with check option

insert into checkoption_view1_1
	(ClientName, Gender, Contact, Region, BirthDate, Car)
values 
	('Кузнецов Егор Дмитриевич', 'Ы', '+79873258599', 'Саратов', '2002-08-14', 0)

select * from checkoption_view1_1
drop view checkoption_view1_1

/*#2*/
create view checkoption_view2 as
select TypeName, Area, DayCost, Fridge, Balcony, BathType
from RoomTypes
where DayCost > 4000

insert into checkoption_view2
	(TypeName, Area, DayCost, Fridge, Balcony, BathType)
values
	('Коробка', 10, 300, 0, 0, 'Слёзы')

select * from checkoption_view2
drop view checkoption_view2

--

create view checkoption_view2_2 as
select TypeName, Area, DayCost, Fridge, Balcony, BathType
from RoomTypes
where DayCost > 4000
with check option

insert into checkoption_view2_2
	(TypeName, Area, DayCost, Fridge, Balcony, BathType)
values
	('Коробка', 10, 300, 0, 0, 'Слёзы')

select * from checkoption_view2_2
drop view checkoption_view2_2

/*#3*/

SET NUMERIC_ROUNDABORT OFF; 
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

create view last_view with schemabinding as
select TypeName, Area, DayCost
from dbo.RoomTypes st
where st.DayCost = 5900

select * from last_view
drop view last_view

create unique clustered index index_view
on last_view (TypeName, Area, DayCost)

drop index index_view on last_view
select * from last_view with (noexpand)