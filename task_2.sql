use Hotel_orig
go
alter database Hotel_orig set single_user with rollback immediate
go 
use master
go
DROP DATABASE Hotel_orig
GO
    CREATE DATABASE Hotel_orig
GO
    USE Hotel_orig
GO

    DROP TABLE IF EXISTS [Rooms] 
    DROP TABLE IF EXISTS [RoomTypes] 
    DROP TABLE IF EXISTS [RoomServices] 
    DROP TABLE IF EXISTS [Booking] 
    DROP TABLE IF EXISTS [Accommodation] 
    DROP TABLE IF EXISTS [Cleaning] 
    DROP TABLE IF EXISTS [Cleaners]
    DROP TABLE IF EXISTS [MainServices] 
	DROP TABLE IF EXISTS [Clients]
    DROP TABLE IF EXISTS [OrderedServices] 
    DROP TABLE IF EXISTS [Parking]

CREATE TABLE RoomTypes
	(TypeID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Type PRIMARY KEY, 
	TypeName nvarchar(15) NOT NULL,
	Area float NOT NULL,
	DayCost int NOT NULL,
	Fridge bit NOT NULL,
	Balcony bit NOT NULL,
	BathType nvarchar(10) NOT NULL)
GO

CREATE TABLE Rooms
   (RoomID int NOT NULL CONSTRAINT PK_Rooms PRIMARY KEY,  
   TypeID int NOT NULL,
   Side nvarchar(4) NOT NULL,  
   BedType text NOT NULL,  
   NearLift bit NOT NULL,
   CONSTRAINT FK_Rooms_TypeID FOREIGN KEY (TypeID) REFERENCES RoomTypes (TypeID))
GO  

CREATE TABLE RoomServices
	(RoomServiceID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_RoomServices PRIMARY KEY, 
	RoomServiceName nvarchar(30) NOT NULL,
	TypeID int NOT NULL,
	RoomServiceCost int,
	CONSTRAINT FK_RoomServices_TypeID FOREIGN KEY (TypeID) REFERENCES RoomTypes (TypeID))
GO

CREATE TABLE Clients
	(ClientID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Clients PRIMARY KEY, 
	ClientName nvarchar(100) NOT NULL,
	keyClientsDem int not null,
	Gender bit NOT NULL,
	Contact nvarchar(30) NOT NULL,
	Region nvarchar(30) NULL,
	BirthDate date,
	Car bit)
GO

CREATE TABLE Booking
	(BookingID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Booking PRIMARY KEY, 
	ClientID int NOT NULL,
	RoomID int NOT NULL,
	GuestsNum int NOT NULL,
	Arrival smalldatetime NOT NULL,
	Departure smalldatetime NOT NULL,
	CONSTRAINT FK_Booking_RoomID FOREIGN KEY (RoomID) REFERENCES Rooms (RoomID),
	CONSTRAINT FK_Booking_ClientID FOREIGN KEY (ClientID) REFERENCES Clients (ClientID))
GO

CREATE TABLE Payment_option(
ID int IDENTITY(1,1) PRIMARY KEY,
_Option nvarchar(10) NOT NULL
)


CREATE TABLE Accommodation
	(LivingID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Living PRIMARY KEY, 
	BookingID int NOT NULL,
	Arrival bigint NOT NULL,
	Departure bigint,
	LivingTime int,
	PaymentType int NOT NULL,
	TotalCost int,
	keyAccommodationAlt nvarchar(30) not null,
	keyGeography int not null, 
	numberOfResidents int not null,
	quantity int not null,
	personalDiscount int not null, 
	TAX int not null,
	FOREIGN KEY(PaymentType) REFERENCES Payment_option(ID),
	CONSTRAINT FK_Accomodation_BookingID FOREIGN KEY (BookingID) REFERENCES Booking (BookingID))
GO


CREATE TABLE Cleaners
	(CleanerID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Cleaners PRIMARY KEY, 
	CleanerName text NOT NULL)
GO

CREATE TABLE Cleaning
	(CleaningID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Cleaning PRIMARY KEY, 
	CleanerID int NOT NULL,
	LivingID int NOT NULL,
	Date_Time smalldatetime NOT NULL,
	CONSTRAINT FK_Cleaning_LivingID FOREIGN KEY (LivingID) REFERENCES Accommodation (LivingID),
	CONSTRAINT FK_Cleaning_CleanerID FOREIGN KEY (CleanerID) REFERENCES Cleaners (CleanerID))
GO

CREATE TABLE MainServices
	(ServiceID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Service PRIMARY KEY, 
	ServiceName nvarchar(30) NOT NULL,
	ServiceCost int NOT NULL)
GO

CREATE TABLE OrderedServices
	(LivingID int NOT NULL,
	ServiceID int NOT NULL,
	Date_Time smalldatetime NOT NULL,
	CONSTRAINT FK_OrederedServices_ServiceID FOREIGN KEY (ServiceID) REFERENCES MainServices (ServiceID),
	CONSTRAINT FK_OrderedServices_LivingID FOREIGN KEY (LivingID) REFERENCES Accommodation (LivingID))
GO

CREATE TABLE Parking
	(PlaceID int PRIMARY KEY NOT NULL,
	LivingID int NOT NULL,
	CarNum text NOT NULL,
	Section nvarchar(10),
	CONSTRAINT FK_Accommodation_LivingID FOREIGN KEY (LivingID) REFERENCES Accommodation (LivingID))
GO

select * from Accommodation

select Accommodation.LivingID, Accommodation.Arrival, Accommodation.Departure, Accommodation.PaymentType, Accommodation.TotalCost, Accommodation.keyAccommodationAlt, Accommodation.keyGeography,
		Accommodation.numberOfResidents, Accommodation.quantity, Accommodation.personalDiscount, Accommodation.TAX, Clients.keyClientsDem, RoomTypes.TypeID, Rooms.RoomID, Booking.ClientID, RoomServices.RoomServiceID
from Accommodation
	inner join Booking on Booking.BookingID = Accommodation.BookingID
	inner join Clients on Clients.ClientID = Booking.ClientID
	inner join Rooms on Rooms.RoomID = Booking.RoomID
	inner join RoomTypes on RoomTypes.TypeID = Rooms.TypeID
	inner join RoomServices on RoomServices.TypeID = RoomTypes.TypeID