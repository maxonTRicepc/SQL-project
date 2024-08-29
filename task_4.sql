use hotel
go

/*�5*/

/*������ 1 �������� �������������*/

/*#1*/

create view client_booking_accomm as
select Clients.ClientName as ������, Clients.Contact as �����_��������, Booking.RoomID as �����, Accommodation.Arrival as ����_�����, Accommodation.Departure as ����_�����
from Clients
	join Booking ON Booking.ClientID = Clients.ClientID
	join Accommodation ON Accommodation.BookingID = Booking.BookingID

select * from client_booking_accomm
drop view client_booking_accomm

/*#2*/

create view room_booking as
select Rooms.RoomID as �����, Booking.Arrival as �����_������, Booking.Departure as �����_������, RoomTypes.TypeName as ���������
from Rooms
	join Booking on Booking.RoomID = Rooms.RoomID
	join RoomTypes on RoomTypes.TypeID = Rooms.TypeID
where RoomTypes.TypeName like '����%' or RoomTypes.TypeName like '����%'

select * from room_booking
drop view room_booking

/*#3*/

create view fullinfo_acccomm as
select Accommodation.BookingID as ����������, Accommodation.Arrival as �����_������, Accommodation.Departure as �����_������, Accommodation.LivingTime as ���������������, RoomServices.RoomServiceName as ������, RoomServices.RoomServiceCost as ���������������,
	   Cleaning.Date_Time as �����������, Cleaners.CleanerName as ������������
from Accommodation
	full join OrderedServices on OrderedServices.LivingID = Accommodation.LivingID
	full join RoomServices on RoomServices.RoomServiceID = OrderedServices.ServiceID
	full join Cleaning on Cleaning.LivingID = Accommodation.LivingID
	full join Cleaners on Cleaners.CleanerID = Cleaning.CleanerID

select * from fullinfo_acccomm
drop view fullinfo_acccomm

/*������ 2: �������� ������������ �������������*/

/*#1*/
create view checkoption_view1 as
select ClientName, Gender, Contact, Region, BirthDate, Car
from Clients
where Car > 0

insert into checkoption_view1
	(ClientName, Gender, Contact, Region, BirthDate, Car)
values 
	('�������� ���� ����������', '�', '+79873258599', '�������', '2002-08-14', 0)

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
	('�������� ���� ����������', '�', '+79873258599', '�������', '2002-08-14', 0)

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
	('�������', 10, 300, 0, 0, '����')

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
	('�������', 10, 300, 0, 0, '����')

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