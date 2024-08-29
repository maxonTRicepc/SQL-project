USE Hotel
GO
 
SELECT r.RoomID, rt.TypeName, r.Side, r.BedType, r.NearLift, rt.Area, rt.DayCost, rt.Fridge, rt.Balcony, rt.BathType AS TypeName
FROM Rooms r 
INNER JOIN RoomTypes rt
ON r.TypeID = rt.TypeID			-- inner join
-- ������ ������ �� ����� ������� �������������� � ������ �� ������, ����� ���� ���������� �������� �������

SELECT cg.CleaningID, cs.CleanerName, cg.LivingID, cg.Date_Time AS CleanerName
FROM Cleaners cs
LEFT OUTER JOIN Cleaning cg ON cs.CleanerID = cg.CleanerID		-- left join 
-- ��������� null �� ������ �������, ���� ��� ������ �����

SELECT cg.CleaningID, cs.CleanerName, cg.LivingID, cg.Date_Time AS CleanerName
FROM Cleaners cs
RIGHT OUTER JOIN Cleaning cg ON cs.CleanerID = cg.CleanerID			-- right join
-- ���������� ��� ������ ������ �������, ���� ���� ��� �� ������������� ������� � ����� �������

SELECT cg.CleaningID, cs.CleanerName, cg.LivingID, cg.Date_Time
FROM Cleaners cs FULL JOIN Cleaning cg
ON cs.CleanerID = cg.CleanerID		-- full join
-- ����������� ������� �� ������ INNER JOIN; ����� ����������� left join - ��� ���������� �������� 
-- ��������������� ������ �� ������ ������� ����������� ���������� NULL; ����� ���������� RIGHT JOIN
-- ��� ���, ��������������� ������ �� ����� ������� ����������� NULL

--SELECT rt.*, rs.* FROM RoomTypes rt 
--CROSS APPLY (SELECT * FROM RoomServices rs) rs ON rt.TypeID = rs.TypeID		-- CROSS APPLY

SELECT * FROM RoomTypes 
CROSS APPLY (SELECT RoomServiceName, RoomServiceCost FROM RoomServices WHERE RoomServices.TypeID = RoomTypes.TypeID)
AS NewTable
-- ���������� ������������� ���������
-- ��� ������ ������ �� ����� ������� ������ ������� ����� ����.

SELECT TypeName, ServiceName FROM RoomTypes CROSS JOIN MainServices		-- CROSS JOIN
-- ��������� ������������: ������ ������ ����� ������� ����������� � ������ ������� ������ �������

SELECT A.ClientName AS ClientName1, B.ClientName AS ClientName2, A.Region
FROM Clients A, Clients B
WHERE A.ClientID <> B.ClientID
AND A.Region = B.Region
ORDER BY A.Region;	-- self join
-- � ������ ����� ����� ������� ����� ���� ���������� ��������

SELECT ServiceName, ServiceCost 
FROM MainServices
UNION
SELECT RoomServiceName, RoomServiceCost 
FROM RoomServices	-- ��������� ������������� ������ (���� ���� � �������� �������� ��� ���������� ������� �����������)

SELECT ServiceName, ServiceCost 
FROM MainServices
UNION ALL
SELECT RoomServiceName, RoomServiceCost 
FROM RoomServices 	-- ����������� ������ ������������� ������ 

SELECT ClientID FROM Clients
EXCEPT
SELECT ClientID FROM Booking	-- ������� ��, ��� ���� � ������ �������, �� ����������� �� ������

SELECT ClientID FROM Clients
INTERSECT
SELECT ClientID FROM Booking	-- ������� ����� �������� ���� ������

SELECT Parking.PlaceID,
CASE 
	WHEN Parking.PlaceID > 0 AND Parking.PlaceID  < 10 THEN N'�����'
    WHEN Parking.PlaceID > 9 AND Parking.PlaceID < 20 THEN N'��������'
    WHEN Parking.PlaceID > 19 THEN N'������'
    ELSE '��� ����������'
END AS Section FROM Parking

SELECT '������� ���� ������� = '+ CAST(AVG(DayCost) AS CHAR(5)) 
FROM RoomTypes;		-- CAST - �������������� ����� (���� as � ����� ���)

SELECT CONVERT(int, Rooms.NearLift) -- �������������� �����
FROM Rooms

SELECT ISNULL(Car, 0) AS Car -- �������� �� ����
FROM Clients

SELECT NULLIF((SELECT Arrival FROM Booking WHERE BookingID = 1), (SELECT Arrival FROM Accommodation WHERE BookingID = 1))
SELECT NULLIF((SELECT Arrival FROM Booking WHERE BookingID = 2), (SELECT Arrival FROM Accommodation WHERE BookingID = 2))
-- ������� NULL, ���� �������� �����; ����� ����� ������ ��������

SELECT COALESCE (CHOOSE (TotalCost, TotalCost), '-1') AS Result 
FROM Accommodation
-- ����� ������ �� ���������� ���������. �������������� �� ��������� ������� (������ ��������), ������� ��������� �������

SELECT *
FROM Clients
WHERE COALESCE (IIF(Clients.Region IS NULL, '��� ����������', '���������'), '��� ����������') != '��� ����������'
-- 

SELECT Date_Time
FROM Cleaning
WHERE EXISTS (SELECT CleanerName FROM Cleaners)
-- �������� �� �������������

SELECT * 
FROM Clients
WHERE Region IN ('�������', '�������')
-- �������� ��������

SELECT *
FROM Booking
WHERE GuestsNum = ANY (SELECT GuestsNum FROM Booking WHERE Arrival > '2022-15-06 00:00:00')
-- ���-�� ������������� �������

SELECT *
FROM Accommodation
WHERE LivingTime > ALL (SELECT LivingTime FROM Accommodation WHERE Arrival > '2022-15-06 12:00:00')
-- ��� ������������� �������
 
SELECT TypeName
FROM RoomTypes
WHERE DayCost BETWEEN 3000 AND 6000
-- ����� �������� � ���������

SELECT ClientID
FROM Clients
WHERE BirthDate LIKE '%02-14'
-- �������� ������������ �� ��������� �������

SELECT REPLACE (RoomTypes.BathType, N'������', N'�����')
FROM RoomTypes
-- ������ ��������

SELECT SUBSTRING(Clients.ClientName, 1, 3)
FROM Clients
-- ��������� ��������� ���������� �������� � �������� ����

SELECT STUFF(Clients.Gender, 1, 1, 'X')
FROM Clients
-- ������ ��������: �������, ������� ��������, �� ��� ��������

SELECT STR (RoomTypes.DayCost)
FROM RoomTypes
-- ������� � ���������� �������������

SELECT UNICODE (RoomTypes.TypeName)
FROM RoomTypes
-- �������� � �������

SELECT UPPER (RoomTypes.TypeName)
FROM RoomTypes
-- ������ ��� ����� � ������ ����������

SELECT LOWER (RoomTypes.TypeName)
FROM RoomTypes
-- ������ ��� ����� � ������ ����������

SELECT DATEPART(year, Clients.BirthDate)
FROM Clients
-- ���������� ������ ������� �� ����

SELECT DATEDIFF(day, '20220619', '20220623')
-- ���������� �������� ����� ������

SELECT GETDATE()
-- �������� ��������� �����

SELECT SYSDATETIMEOFFSET()
-- ��������� ����� � ������� ������

SELECT LivingTime FROM Accommodation GROUP BY LivingTime

SELECT LivingTime FROM Accommodation GROUP BY LivingTime HAVING LivingTime > 3