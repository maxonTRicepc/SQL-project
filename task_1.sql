USE Hotel
GO
 
SELECT r.RoomID, rt.TypeName, r.Side, r.BedType, r.NearLift, rt.Area, rt.DayCost, rt.Fridge, rt.Balcony, rt.BathType AS TypeName
FROM Rooms r 
INNER JOIN RoomTypes rt
ON r.TypeID = rt.TypeID			-- inner join
-- Каждая строка из левой таблицы сопоставляется с каждой из правой, после чего происходит проверка условия

SELECT cg.CleaningID, cs.CleanerName, cg.LivingID, cg.Date_Time AS CleanerName
FROM Cleaners cs
LEFT OUTER JOIN Cleaning cg ON cs.CleanerID = cg.CleanerID		-- left join 
-- Проставит null во второй таблице, если нет нужных строк

SELECT cg.CleaningID, cs.CleanerName, cg.LivingID, cg.Date_Time AS CleanerName
FROM Cleaners cs
RIGHT OUTER JOIN Cleaning cg ON cs.CleanerID = cg.CleanerID			-- right join
-- Выбираются все записи правой таблицы, даже если они не соответствуют записям в левой таблице

SELECT cg.CleaningID, cs.CleanerName, cg.LivingID, cg.Date_Time
FROM Cleaners cs FULL JOIN Cleaning cg
ON cs.CleanerID = cg.CleanerID		-- full join
-- формируется таблица на основе INNER JOIN; после добавляется left join - для полученных значений 
-- соответствующие записи из правой таблицы заполняются значениями NULL; затем добавляетя RIGHT JOIN
-- Для них, соответствующие записи из левой таблицы заполняются NULL

--SELECT rt.*, rs.* FROM RoomTypes rt 
--CROSS APPLY (SELECT * FROM RoomServices rs) rs ON rt.TypeID = rs.TypeID		-- CROSS APPLY

SELECT * FROM RoomTypes 
CROSS APPLY (SELECT RoomServiceName, RoomServiceCost FROM RoomServices WHERE RoomServices.TypeID = RoomTypes.TypeID)
AS NewTable
-- используем коррелирующий подзапрос
-- Для каждой строки из левой таблицы правая таблица будет своя.

SELECT TypeName, ServiceName FROM RoomTypes CROSS JOIN MainServices		-- CROSS JOIN
-- Декартово произведение: каждая строка левой таблицы соединяется с каждой строкой правой таблицы

SELECT A.ClientName AS ClientName1, B.ClientName AS ClientName2, A.Region
FROM Clients A, Clients B
WHERE A.ClientID <> B.ClientID
AND A.Region = B.Region
ORDER BY A.Region;	-- self join
-- У разных полей одной таблицы могут быть одинаковые значения

SELECT ServiceName, ServiceCost 
FROM MainServices
UNION
SELECT RoomServiceName, RoomServiceCost 
FROM RoomServices	-- исключены повторяющиеся строки (даже если в исходных таблицах они отличались другими параметрами)

SELECT ServiceName, ServiceCost 
FROM MainServices
UNION ALL
SELECT RoomServiceName, RoomServiceCost 
FROM RoomServices 	-- встречаются внешне повторяющиеся строки 

SELECT ClientID FROM Clients
EXCEPT
SELECT ClientID FROM Booking	-- выводит то, что есть в первой таблице, но отсутствует во второй

SELECT ClientID FROM Clients
INTERSECT
SELECT ClientID FROM Booking	-- выводит общие элементы двух таблиц

SELECT Parking.PlaceID,
CASE 
	WHEN Parking.PlaceID > 0 AND Parking.PlaceID  < 10 THEN N'Выезд'
    WHEN Parking.PlaceID > 9 AND Parking.PlaceID < 20 THEN N'Середина'
    WHEN Parking.PlaceID > 19 THEN N'Дальше'
    ELSE 'Нет информации'
END AS Section FROM Parking

SELECT 'Средняя цена номеров = '+ CAST(AVG(DayCost) AS CHAR(5)) 
FROM RoomTypes;		-- CAST - преобразование типов (поле as в какой тип)

SELECT CONVERT(int, Rooms.NearLift) -- преобразование типов
FROM Rooms

SELECT ISNULL(Car, 0) AS Car -- проверка на ноль
FROM Clients

SELECT NULLIF((SELECT Arrival FROM Booking WHERE BookingID = 1), (SELECT Arrival FROM Accommodation WHERE BookingID = 1))
SELECT NULLIF((SELECT Arrival FROM Booking WHERE BookingID = 2), (SELECT Arrival FROM Accommodation WHERE BookingID = 2))
-- вернётся NULL, если значения равны; иначе вернёт первое значение

SELECT COALESCE (CHOOSE (TotalCost, TotalCost), '-1') AS Result 
FROM Accommodation
-- выбор одного из нескольких вариантов. Осуществляется на основании индекса (номера варианта), первого параметра функции

SELECT *
FROM Clients
WHERE COALESCE (IIF(Clients.Region IS NULL, 'Нет информации', 'Заполнено'), 'Нет информации') != 'Нет информации'
-- 

SELECT Date_Time
FROM Cleaning
WHERE EXISTS (SELECT CleanerName FROM Cleaners)
-- проверка на существование

SELECT * 
FROM Clients
WHERE Region IN ('Саратов', 'Энгельс')
-- проверка значения

SELECT *
FROM Booking
WHERE GuestsNum = ANY (SELECT GuestsNum FROM Booking WHERE Arrival > '2022-15-06 00:00:00')
-- что-то удовлетворяет условию

SELECT *
FROM Accommodation
WHERE LivingTime > ALL (SELECT LivingTime FROM Accommodation WHERE Arrival > '2022-15-06 12:00:00')
-- все удовлетворяют условию
 
SELECT TypeName
FROM RoomTypes
WHERE DayCost BETWEEN 3000 AND 6000
-- поиск значения в диапазоне

SELECT ClientID
FROM Clients
WHERE BirthDate LIKE '%02-14'
-- значение оканчивается на указанные символы

SELECT REPLACE (RoomTypes.BathType, N'Кабина', N'Ванна')
FROM RoomTypes
-- замена значений

SELECT SUBSTRING(Clients.ClientName, 1, 3)
FROM Clients
-- оставляет указанное количество символов в значении поля

SELECT STUFF(Clients.Gender, 1, 1, 'X')
FROM Clients
-- замена значений: позиция, сколько заменяем, на что заменяем

SELECT STR (RoomTypes.DayCost)
FROM RoomTypes
-- перевод в символьное представление

SELECT UNICODE (RoomTypes.TypeName)
FROM RoomTypes
-- значения в юникоде

SELECT UPPER (RoomTypes.TypeName)
FROM RoomTypes
-- Делает все буквы в строке заглавными

SELECT LOWER (RoomTypes.TypeName)
FROM RoomTypes
-- Делает все буквы в строке маленькими

SELECT DATEPART(year, Clients.BirthDate)
FROM Clients
-- возвращает нужный элемент из даты

SELECT DATEDIFF(day, '20220619', '20220623')
-- определяет интервал между датами

SELECT GETDATE()
-- получает системное время

SELECT SYSDATETIMEOFFSET()
-- системное время с часовым поясом

SELECT LivingTime FROM Accommodation GROUP BY LivingTime

SELECT LivingTime FROM Accommodation GROUP BY LivingTime HAVING LivingTime > 3