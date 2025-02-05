/* Вопросы с таблицами доступны на сайте по ссылке https://sql-academy.org/ru/trainer и продублированы ниже */

-- 1. Вывести имена всех людей, которые есть в базе данных авиакомпаний:

SELECT name FROM passenger;

-- 2. Вывести названия всеx авиакомпаний:

SELECT name FROM Company; 

-- 3. Вывести все рейсы, совершенные из Москвы:

SELECT * FROM Trip
WHERE town_from = "Moscow";

-- 4. Вывести имена людей, которые заканчиваются на "man":

SELECT name FROM Passenger
WHERE name LIKE "%man";

-- 5. Вывести количество рейсов, совершенных на TU-134:

SELECT COUNT(id) AS count FROM Trip
WHERE plane = "TU-134";

-- 6. Какие компании совершали перелеты на Boeing:

SELECT DISTINCT(a.name) FROM Company a
JOIN Trip b ON a.id = b.company
WHERE plane = "Boeing";

-- 7. Вывести все названия самолётов, на которых можно улететь в Москву (Moscow): 

SELECT DISTINCT(plane) FROM Trip
WHERE town_to = "Moscow";

-- 8. В какие города можно улететь из Парижа (Paris) и сколько времени это займёт?:

SELECT town_to, TIMEDIFF(time_in, time_out) AS flight_time
FROM Trip
WHERE town_from = "Paris";

-- 9. Какие компании организуют перелеты из Владивостока (Vladivostok)?:

SELECT a.name FROM Company a
JOIN Trip b ON a.id = b.company
WHERE b.town_from = "Vladivostok";

-- 10. Вывести вылеты, совершенные с 10 ч. по 14 ч. 1 января 1900 г.:

SELECT * FROM Trip
WHERE time_out BETWEEN "1900-01-01T10:00:00.000Z" AND "1900-01-01T14:00:00.000Z";

-- 11. Выведите пассажиров с самым длинным ФИО. Пробелы, дефисы и точки считаются частью имени:

SELECT name FROM Passenger
WHERE LENGTH(name) = 
    (
    SELECT MAX(LENGTH(NAME)) 
    FROM Passenger
    );
    
-- 12. Выведите идентификаторы всех рейсов и количество пассажиров на них. 
-- Обратите внимание, что на каких-то рейсах пассажиров может не быть. 
-- В этом случае выведите число "0":

SELECT a.id, IFNULL(COUNT(b.passenger), 0) AS count 
FROM Trip a
LEFT JOIN Pass_in_trip b ON a.id = b.trip
GROUP BY a.id;

-- 13. Вывести имена людей, у которых есть полный тёзка среди пассажиров:

SELECT name FROM Passenger
GROUP BY name
HAVING COUNT(name) >= 2;

-- 14. В какие города летал Bruce Willis:

SELECT DISTINCT town_to FROM Trip
WHERE id IN 
    (SELECT trip FROM  Pass_in_trip
    WHERE passenger IN 
        (SELECT id FROM Passenger
        WHERE name = "Bruce Willis")
    );
    
-- 15. Выведите идентификатор пассажира Стив Мартин (Steve Martin) и дату и время его прилёта в Лондон (London): 

SELECT a.id AS id, c.time_in AS time_in
FROM Passenger a
JOIN Pass_in_trip b ON a.id = b.passenger
JOIN Trip c ON b.trip = c.id
WHERE a.name = "Steve Martin" AND town_to = "London";

-- 16. Вывести отсортированный по количеству перелетов (по убыванию) и имени (по возрастанию) список пассажиров, совершивших хотя бы 1 полет:

SELECT name,COUNT(*) AS count
FROM Passenger, Pass_in_trip
WHERE Pass_in_trip.passenger = Passenger.id
GROUP BY Passenger.id
ORDER BY COUNT(*) DESC, name ASC;

-- 17. Определить, сколько потратил в 2005 году каждый из членов семьи. В результирующей выборке не выводите тех членов семьи, которые ничего не потратили: 

SELECT a.member_name AS member_name, a.status AS status, 
SUM(b.amount * b.unit_price) AS costs    
FROM FamilyMembers a
JOIN Payments b
ON a.member_id = b.family_member
WHERE YEAR(b.date) = 2005
GROUP BY a.member_name, a.status
HAVING SUM(b.amount * b.unit_price) > 0; 

-- 18. Выведите имя самого старшего человека. Если таких несколько, то выведите их всех:

SELECT member_name
FROM FamilyMembers
WHERE YEAR(curdate()) - YEAR(birthday) = 
	(
    SELECT MAX(YEAR(curdate()) - YEAR(birthday))
    FROM FamilyMembers
    );

-- 19. Определить, кто из членов семьи покупал картошку (potato):

SELECT status FROM FamilyMembers
WHERE member_id IN
    (
    SELECT family_member FROM Payments
    WHERE good =
        (
        SELECT good_id FROM Goods
        WHERE good_name = "potato"
        )
    );
    
-- 20. Сколько и кто из семьи потратил на развлечения (entertainment). Вывести статус в семье, имя, сумму:

SELECT a.status AS status, a.member_name AS member_name, 
SUM(b.amount * b.unit_price) AS costs
FROM FamilyMembers a
JOIN Payments b
ON a.member_id = b.family_member
WHERE b.good IN
    (
    SELECT good_id FROM Goods
    WHERE type IN 
        (
        SELECT good_type_id FROM GoodTypes
        WHERE good_type_name = "entertainment"
        )
    )
GROUP BY a.status, a.member_name;

-- 21. Определить товары, которые покупали более 1 раза:

SELECT good_name FROM Goods
WHERE good_id IN
    (
    SELECT good FROM Payments
    GROUP BY good
    HAVING COUNT(good) >1
    );
    
-- 22. Найти имена всех матерей (mother):

SELECT member_name FROM FamilyMembers
WHERE status = "mother";

-- 23. Найдите самый дорогой деликатес (delicacies) и выведите его цену:

-- 24. Определить кто и сколько потратил в июне 2005:

SELECT a.member_name AS member_name, 
SUM(b.amount * b.unit_price) AS costs
FROM FamilyMembers a
JOIN Payments b
ON a.member_id = b.family_member
WHERE MONTH(date) = 06 AND YEAR(date) = 2005
GROUP BY a.member_name;

-- 25. Определить, какие товары не покупались в 2005 году:  

SELECT good_name FROM Goods
WHERE good_id NOT IN
    (
    SELECT good FROM Payments
    WHERE YEAR(date) = 2005
    );

-- 26. Определить группы товаров, которые не приобретались в 2005 году:

SELECT good_type_name FROM GoodTypes
WHERE good_type_id NOT IN 
    (
    SELECT type FROM Goods
    WHERE good_id IN
        (
        SELECT good FROM Payments
        WHERE YEAR(date) = 2005
        )
    );
    
-- 27. Узнайте, сколько было потрачено на каждую из групп товаров в 2005 году. 
-- Выведите название группы и потраченную на неё сумму. 
-- Если потраченная сумма равна нулю, т.е. товары из этой группы не покупались в 2005 году, то не выводите её.

SELECT a.good_type_name AS good_type_name, SUM(c.amount * c.unit_price) AS costs 
FROM GoodTypes a
JOIN Goods b ON a.good_type_id = b.type
JOIN Payments c ON b.good_id = c.good
WHERE YEAR(c.date) = 2005 
GROUP BY a.good_type_name
HAVING SUM(c.amount * c.unit_price) > 0;

-- 28. Сколько рейсов совершили авиакомпании из Ростова (Rostov) в Москву (Moscow) ?:

SELECT COUNT(id) AS count FROM Trip
WHERE town_from = "Rostov" AND town_to = "Moscow";

-- 29. Выведите имена пассажиров улетевших в Москву (Moscow) на самолете TU-134. В ответе не должно быть дубликатов:

SELECT DISTINCT name FROM passenger 
WHERE id IN 
    (
    SELECT passenger FROM Pass_in_trip
    WHERE trip IN 
        (
        SELECT id FROM Trip
        WHERE plane = "TU-134" AND town_to = "Moscow" 
        )
    );
    
-- 30. Выведите нагруженность (число пассажиров) каждого рейса (trip). 
-- Результат вывести в отсортированном виде по убыванию нагруженности.

SELECT DISTINCT trip, COUNT(passenger) AS count
FROM Pass_in_trip
GROUP BY trip
ORDER BY COUNT(passenger) DESC; 

-- 31. Вывести всех членов семьи с фамилией Quincey:

SELECT * FROM FamilyMembers
WHERE member_name LIKE "%Quincey";

-- 32. Вывести средний возраст людей (в годах), хранящихся в базе данных. 
-- Результат округлите до целого в меньшую сторону.

SELECT FLOOR(AVG(TIMESTAMPDIFF(YEAR, birthday, NOW()))) AS age
FROM FamilyMembers; 

-- 33. Найдите среднюю цену икры на основе данных, хранящихся в таблице Payments. 
-- В базе данных хранятся данные о покупках красной (red caviar) и черной икры (black caviar). 
-- В ответе должна быть одна строка со средней ценой всей купленной когда-либо икры.

SELECT AVG(unit_price) AS cost FROM Payments
WHERE good IN 
    (
    SELECT good_id FROM Goods
    WHERE good_name LIKE '%caviar'
    );

-- 34. Сколько всего 10-ых классов:

SELECT COUNT(id) AS count FROM Class
WHERE name LIKE "10%";

-- 35. Сколько различных кабинетов школы использовались 2 сентября 2019 года для проведения занятий?:

SELECT COUNT(DISTINCT classroom) AS count FROM Schedule
WHERE date = "2019-09-02";

-- 36. Выведите информацию об обучающихся живущих на улице Пушкина (ul. Pushkina)?:

SELECT * FROM Student
WHERE address LIKE "%Pushkina%";

-- 37. Сколько лет самому молодому обучающемуся ?:

# option 1
SELECT TIMESTAMPDIFF(YEAR, birthday, CURDATE()) AS year
FROM Student
ORDER BY TIMESTAMPDIFF(YEAR, birthday, CURDATE()) ASC 
LIMIT 1;

# option 2
SELECT MIN(TIMESTAMPDIFF(YEAR, birthday, CURDATE())) AS year
FROM Student;

-- 38. Сколько Анн (Anna) учится в школе ?:

SELECT COUNT(*) AS count FROM Student
WHERE first_name = "Anna";

-- 39. Сколько обучающихся в 10 B классе ?

SELECT COUNT(id) AS count FROM Student_in_class
WHERE class = 
    (
    SELECT id FROM Class
    WHERE name = "10 B"
    );
    
-- 40. Выведите название предметов, которые преподает Ромашкин П.П. (Romashkin P.P.). 
-- Обратите внимание, что в базе данных есть несколько учителей с такой фамилией.

SELECT DISTINCT name AS subjects FROM subject
WHERE id IN
    (
    SELECT subject FROM Schedule
    WHERE teacher = 
        (
        SELECT id FROM Teacher
        WHERE last_name = "Romashkin" 
        AND LEFT(first_name, 1) = "P" 
        AND LEFT(middle_name, 1) = "P"
        )
    );
    
-- 41. Выясните, во сколько по расписанию начинается четвёртое занятие:

SELECT start_pair FROM Timepair
WHERE id = 4;

-- 42. Сколько времени обучающийся будет находиться в школе, учась со 2-го по 4-ый уч. предмет?:

SELECT TIMEDIFF(
    (SELECT end_pair FROM Timepair 
    WHERE id = 4),
    (SELECT start_pair FROM Timepair
    WHERE id = 2)
    ) AS time;

-- 43. Выведите фамилии преподавателей, которые ведут физическую культуру (Physical Culture). 
-- Отсортируйте преподавателей по фамилии в алфавитном порядке.

SELECT last_name FROM Teacher
WHERE id IN
    (
    SELECT teacher FROM Schedule
    WHERE subject =
        (
        SELECT id FROM Subject
        WHERE name = "Physical Culture"
        )
    )
ORDER BY last_name ASC;

-- 44. Найдите максимальный возраст (количество лет) среди обучающихся 10 классов на сегодняшний день. 
-- Для получения текущих даты и времени используйте функцию NOW().

SELECT MAX(TIMESTAMPDIFF(YEAR, birthday, NOW())) AS max_year FROM Student
WHERE id IN
    (
    SELECT student FROM Student_in_class
    WHERE class IN 
        (
        SELECT id FROM Class
        WHERE name LIKE "10%"
        )
    );
    
-- 45. Какие кабинеты чаще всего использовались для проведения занятий? 
-- Выведите те, которые использовались максимальное количество раз:

SELECT classroom FROM Schedule
GROUP BY classroom
HAVING COUNT(classroom) = 
    (
    SELECT COUNT(classroom) FROM Schedule
    GROUP BY classroom
    ORDER BY COUNT(classroom) DESC
    LIMIT 1
    );

-- 46. В каких классах введет занятия преподаватель "Krauze" ?:

SELECT DISTINCT name FROM Class
WHERE id IN 
    (
    SELECT class FROM Schedule
    WHERE teacher = 
        (
        SELECT id FROM Teacher
        WHERE last_name = "Krauze"
        )
    );
    
-- 47. Сколько занятий провел Krauze 30 августа 2019 г.?:

SELECT COUNT(id) AS count FROM Schedule
WHERE date = "2019-08-30" AND teacher = 
    (
    SELECT id FROM Teacher
    WHERE last_name = "Krauze"
    );
    
-- 48. Выведите заполненность классов в порядке убывания:

SELECT a.name AS name, COUNT(b.student) AS count
FROM Class a
JOIN Student_in_class b ON a.id = b.class
GROUP BY a.name
ORDER BY COUNT(b.student) DESC; 

-- 49. Какой процент обучающихся учится в "10 A" классе? 
-- Выведите ответ в диапазоне от 0 до 100 с округлением до четырёх знаков после запятой, например, 96.0201.



-- 50. 

-- 51. Добавьте товар с именем "Cheese" и типом "food" в список товаров (Goods).
-- В качестве первичного ключа (good_id) укажите количество записей в таблице + 1.

INSERT INTO Goods (good_id, good_name, type)
SELECT 
    (SELECT MAX(good_id) + 1 FROM Goods), 
    'Cheese', 
    (SELECT good_type_id FROM GoodTypes 
    WHERE good_type_name = 'food');
    
-- 52. Добавьте в список типов товаров (GoodTypes) новый тип "auto":

INSERT INTO GoodTypes (good_type_id, good_type_name)
SELECT (SELECT MAX(good_type_id) + 1 FROM GoodTypes), "auto";

-- 53. Измените имя "Andie Quincey" на новое "Andie Anthony":

UPDATE FamilyMembers
SET member_name = 'Andie Anthony'
WHERE member_name = 'Andie Quincey';

-- 54. Удалить всех членов семьи с фамилией "Quincey":

DELETE FROM FamilyMembers
WHERE member_name LIKE "%Quincey";

-- 55. Удалить компании, совершившие наименьшее количество рейсов:































































    
    














































    





























































