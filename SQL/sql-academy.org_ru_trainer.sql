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

SELECT good_name,unit_price
FROM Payments, Goods, GoodTypes
WHERE good_type_id = type
AND good_type_name = 'delicacies'
AND good_id = good
AND unit_price =
    (
	SELECT MAX(unit_price)
	FROM Payments, Goods, GoodTypes
    WHERE good_id = good
	AND good_type_id = type
	AND good_type_name = 'delicacies'
	);

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

SELECT ROUND(
		(
			SELECT COUNT(*)
			FROM Student_in_class
				JOIN Class ON class = Class.id
			WHERE Class.name = '10 A'
		) / (
			SELECT COUNT(*)
			FROM Student_in_class
		) * 100,
		4
	) AS percent;

-- 50. Какой процент обучающихся родился в 2000 году? Результат округлить до целого в меньшую сторону:

SELECT FLOOR(
		(
			SELECT COUNT(*)
			FROM Student
			WHERE YEAR(birthday) = 2000
		) / (
			SELECT COUNT(*)
			FROM Student
		) * 100
	) AS percent;

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

WITH Company_trip_counts AS (
	SELECT company,
		COUNT(*) AS trip_count
	FROM Trip
	GROUP BY company
),
Company_min_count AS (
	SELECT MIN(trip_count) AS min_trip_count
	FROM Company_trip_counts
)
DELETE FROM Company
WHERE id IN (
		SELECT company
		FROM Company_trip_counts,
			Company_min_count
		WHERE trip_count = Company_min_count.min_trip_count
	)

-- 56. Удалить все перелеты, совершенные из Москвы (Moscow):

DELETE FROM Trip
WHERE town_from = "Moscow";

-- 57. Перенести расписание всех занятий на 30 мин. вперед:

UPDATE Timepair
SET start_pair = ADDTIME(start_pair, '00:30:00'), 
    end_pair = ADDTIME(end_pair, '00:30:00');
    
-- 58. Добавить отзыв с рейтингом 5 на жилье, находящиеся по адресу "11218, Friel Place, New York", от имени "George Clooney".
-- В качестве первичного ключа (id) укажите количество записей в таблице + 1.
-- Резервация комнаты, на которую вам нужно оставить отзыв, уже была сделана, нужно лишь ее найти.

INSERT INTO Reviews
SELECT COUNT(*) + 1,
	(
		SELECT id
		FROM Reservations
		WHERE user_id =(
				SELECT id
				FROM Users
				WHERE name = "George Clooney"
			)
			AND room_id =(
				SELECT id
				FROM Rooms
				WHERE address = "11218, Friel Place, New York"
			)
	),
	5
FROM Reviews;

-- 59. Вывести пользователей, указавших Белорусский номер телефона? Телефонный код Белоруссии +375:

# option 1
SELECT * FROM Users
WHERE phone_number LIKE "+375%";


# option 2
SELECT * FROM Users
WHERE LEFT(phone_number, 4) = +375;

-- 60. Выведите идентификаторы преподавателей, которые хотя бы один раз за всё время преподавали в каждом из одиннадцатых классов.

SELECT teacher FROM Schedule
WHERE class IN 
    (
    SELECT id FROM Class 
    WHERE name LIKE '11%'
    )
GROUP BY teacher
HAVING COUNT(DISTINCT class) = 
    ( 
    SELECT COUNT(*) FROM Class 
    WHERE name LIKE '11%' 
    );

-- 61. Выведите список комнат, которые были зарезервированы хотя бы на одни сутки в 12-ую неделю 2020 года. 
-- В данной задаче в качестве одной недели примите период из семи дней, первый из которых начинается 1 января 2020 года. 
-- Например, первая неделя года — 1–7 января, а третья — 15–21 января.

SELECT a.* FROM Rooms a
JOIN Reservations b
ON a.id = b.room_id
WHERE 
start_date >= "2020-01-01" + INTERVAL 11 WEEK
AND 
start_date < "2020-01-01" + INTERVAL 12 WEEK
GROUP BY b.room_id
HAVING COUNT(b.id) >= 1;

-- 62. Вывести в порядке убывания популярности доменные имена 2-го уровня, 
-- используемые пользователями для электронной почты. 
-- Полученный результат необходимо дополнительно отсортировать по возрастанию названий доменных имён.
-- Для эл. почты index@gmail.com доменным именем 2-го уровня будет "gmail.com":

SELECT SUBSTRING_INDEX(email, "@", -1) AS domain, 
COUNT(SUBSTRING_INDEX(email, "@", -1)) AS count
FROM users
GROUP BY SUBSTRING_INDEX(email, "@", -1)
ORDER BY COUNT(SUBSTRING_INDEX(email, "@", -1)) DESC,
SUBSTRING_INDEX(email, "@", -1) ASC;

-- 63. Выведите отсортированный список (по возрастанию) фамилий и имен студентов в виде Фамилия.И.:

SELECT CONCAT(last_name, ".", LEFT(first_name, 1), ".") AS name
FROM Student
ORDER BY CONCAT(last_name, ".", LEFT(first_name, 1), ".");

-- 64. Вывести количество бронирований по каждому месяцу каждого года, 
-- в которых было хотя бы 1 бронирование. 
-- Результат отсортируйте в порядке возрастания даты бронирования.

SELECT 
	YEAR(start_date) AS year,
	MONTH(start_date) AS month, 
	COUNT(id) AS amount
FROM Reservations
GROUP BY YEAR(start_date), MONTH(start_date)
HAVING COUNT(id) >= 1
ORDER BY YEAR(start_date), MONTH(start_date);

-- 65. Необходимо вывести рейтинг для комнат, которые хоть раз арендовали, 
-- как среднее значение рейтинга отзывов округленное до целого вниз.

SELECT
	a.room_id AS room_id, 
	FLOOR(AVG(b.rating)) AS rating
FROM Reservations a
JOIN Reviews b ON a.id = b.reservation_id
GROUP BY a.room_id
HAVING COUNT(a.id) >= 1;

-- 66. Вывести список комнат со всеми удобствами (наличие ТВ, интернета, кухни и кондиционера), 
-- а также общее количество дней и сумму за все дни аренды каждой из таких комнат: 

# Используйте конструкции "as days" и "as total_fee" для вывода количества дней и суммы аренды, соответственно.
# Если комната не сдавалась, то количество дней и сумму вывести как 0.

SELECT 
	a.home_type AS home_type, 
	a.address AS address, 
	IFNULL(SUM(DATEDIFF(b.end_date, b.start_date)), 0) AS days, 
	IFNULL(SUM(b.total), 0) AS total_fee
FROM Rooms a
LEFT JOIN Reservations b
ON a.id = b.room_id
WHERE a.has_tv = 1 
  AND a.has_internet = 1 
  AND a.has_kitchen = 1 
  AND a.has_air_con = 1
GROUP BY a.id;

-- 67. Вывести время отлета и время прилета для каждого перелета в формате 
-- "ЧЧ:ММ, ДД.ММ - ЧЧ:ММ, ДД.ММ", где часы и минуты с ведущим нулем, а день и месяц без.

# Используйте конструкции "as flight_time" для полученной строки с датами отлета и прилета:

SELECT 
    CONCAT(
        LPAD(HOUR(time_out), 2, '0'), ":", 
        LPAD(MINUTE(time_out), 2, '0'), ", ",
        DAY(time_out), ".", 
        MONTH(time_out), " - ",
        LPAD(HOUR(time_in), 2, '0'), ":", 
        LPAD(MINUTE(time_in), 2, '0'), ", ",
        DAY(time_in), ".", MONTH(time_in)
		) AS flight_time
FROM Trip;

-- 68. Для каждой комнаты, которую снимали как минимум 1 раз, найдите имя человека, 
-- снимавшего ее последний раз, и дату, когда он выехал:


# option 1

SELECT 
    a.room_id AS room_id,
    b.name AS name,
    a.end_date AS end_date
FROM Reservations a
JOIN Users b
    ON a.user_id = b.id
WHERE a.end_date = 
	(
    SELECT MAX(c.end_date) 
    FROM Reservations c
    WHERE c.room_id = a.room_id
	);

# option 2

SELECT 
    a.room_id AS room_id, 
    b.name AS name, 
    a.end_date AS end_date
FROM Reservations a
JOIN Users b
ON a.user_id = b.id
WHERE (a.room_id, a.end_date) IN
    (SELECT room_id, MAX(end_date)
    FROM Reservations
    GROUP BY room_id);
    
-- 69. Вывести идентификаторы всех владельцев комнат, что размещены на сервисе бронирования жилья и сумму, которую они заработали:

SELECT owner_id,
	SUM(COALESCE(total, 0)) AS total_earn
FROM Rooms
LEFT JOIN Reservations ON Rooms.id = room_id
GROUP BY owner_id
ORDER BY owner_id;

-- 70. Необходимо категоризовать жилье на economy, comfort, premium по цене соответственно 
-- <= 100, 100 < цена < 200, >= 200. 
-- В качестве результата вывести таблицу с названием категории и количеством жилья, попадающего в данную категорию:

SELECT CASE  
    WHEN price >= 200 THEN "premium"
    WHEN price > 100 THEN "comfort"
    ELSE "economy"
END AS category, 
COUNT(id) AS count
FROM Rooms
GROUP BY category;

-- 71. Найдите какой процент пользователей, зарегистрированных на сервисе бронирования, 
-- хоть раз арендовали или сдавали в аренду жилье. Результат округлите до сотых

WITH Active_users AS (
	SELECT DISTINCT user_id
	FROM (
			SELECT user_id
			FROM Reservations
			UNION
			SELECT DISTINCT owner_id AS user_id
			FROM Rooms
				INNER JOIN Reservations ON Rooms.id = Reservations.room_id
		) AS Active_users
)
SELECT ROUND((COUNT(user_id) / COUNT(id)) * 100, 2) AS percent
FROM Users
	LEFT JOIN Active_users ON id = user_id;
    
-- 72. Выведите среднюю цену бронирования за сутки для каждой из комнат, которую бронировали хотя бы один раз. 
-- Среднюю цену необходимо округлить до целого значения вверх:

SELECT room_id, CEILING(AVG(price)) AS avg_price
FROM Reservations
GROUP BY room_id;

-- 73. Выведите id тех комнат, которые арендовали нечетное количество раз:

SELECT room_id, COUNT(id) AS count
FROM Reservations
GROUP BY room_id
HAVING MOD(COUNT(id), 2) = 1;

-- 74. Выведите идентификатор и признак наличия интернета в помещении. 
-- Если интернет в сдаваемом жилье присутствует, то выведите «YES», иначе «NO».

SELECT id, IF(has_internet = 1, "YES", "NO") AS has_internet
FROM Rooms;

-- 75. Выведите фамилию, имя и дату рождения студентов, кто был рожден в мае:

SELECT last_name, first_name, birthday
FROM Student
WHERE MONTH(birthday) = 5;

-- 76. Вывести имена всех пользователей сервиса бронирования жилья, а также два признака: 
-- является ли пользователь собственником какого-либо жилья (is_owner) и 
-- является ли пользователь арендатором (is_tenant). 
-- В случае наличия у пользователя признака необходимо вывести в соответствующее поле 1, иначе 0.

SELECT a.name,
CASE 
    WHEN b.owner_id IS NOT NULL THEN 1 ELSE 0 
END AS is_owner,
    
CASE 
    WHEN c.user_id IS NOT NULL THEN 1 ELSE 0 
END AS is_tenant
FROM Users a
LEFT JOIN Rooms b ON a.id = b.owner_id
LEFT JOIN Reservations c ON a.id = c.user_id
GROUP BY a.id, a.name;

-- 77. Создайте представление с именем "People", которое будет содержать список имен (first_name) 
-- и фамилий (last_name) всех студентов (Student) и преподавателей(Teacher)

CREATE VIEW People AS
    SELECT first_name, last_name 
    FROM Student
UNION ALL
    SELECT first_name, last_name
    FROM Teacher;
    
-- 78. Выведите всех пользователей с электронной почтой в «hotmail.com»:

SELECT * FROM Users
WHERE email LIKE "%@hotmail.com";

-- 79. Выведите поля id, home_type, price у всего жилья из таблицы Rooms. 
-- Если комната имеет телевизор и интернет одновременно, 
-- то в качестве цены в поле price выведите цену, применив скидку 10%.

SELECT id, home_type, 
CASE 
    WHEN has_tv = 1 AND has_internet = 1 THEN price * 0.9
    ELSE price
END AS price
FROM Rooms;

-- 80. Создайте представление «Verified_Users» с полями id, name и email, 
-- которое будет показывает только тех пользователей, у которых подтвержден адрес электронной почты.

CREATE VIEW Verified_Users AS 
SELECT id, name, email
FROM Users
WHERE email_verified_at IS NOT NULL;

-- 81. Предположим, вам дана таблица данных твитов Twitter. 
-- Напишите запрос, чтобы получить гистограмму твитов, опубликованных каждым пользователем в 2022 году. 
-- Выведите количество твитов на пользователя как группу и количество пользователей Twitter, которые попадают в эту группу.
-- Другими словами, сгруппируйте пользователей по количеству твитов (tweet_bucket), 
-- которые они опубликовали в 2022 году, и подсчитайте количество пользователей в каждой группе (users_num).

WITH total_tweets AS (
	SELECT COUNT(tweet_id) AS tweet_count_per_user
	FROM tweets
	WHERE YEAR(tweet_date) = 2022
	GROUP BY user_id
)
SELECT tweet_count_per_user AS tweet_bucket,
	COUNT(*) AS users_num
FROM total_tweets
GROUP BY tweet_count_per_user;

-- 82. Предположим, вам даны две таблицы, содержащие данные о страницах Facebook и соответствующим им лайкам.
-- Напишите запрос, возвращающий идентификаторы страниц Facebook, на которых нет лайков. 
-- Вывод должен быть отсортирован в порядке возрастания на основе идентификаторов страниц.

SELECT page_id FROM pages
WHERE page_id NOT IN
    (
    SELECT page_id FROM page_likes
    )
ORDER BY page_id;

-- 83. Вывести имена клиентов по городу Moscow, у которых суммарный остаток по счетам 
-- на последнюю дату составляет от 20 000.

SELECT a.client_name FROM Clients a
JOIN Accounts b ON a.account_num = b.account_num
WHERE a.region = 'Moscow'
AND b.date = 
    (
    SELECT MAX(b2.date) FROM Accounts b2
    WHERE b2.account_num = b.account_num
    )
GROUP BY a.client_name
HAVING SUM(b.amount_USD) >= 20000;

-- 84. Новые пользователи TikTok регистрируются, используя свои адреса электронной почты. 
-- Они подтверждают свою регистрацию, переходя по ссылке в текстовом email сообщении 
-- об активации своих учетных записей. Пользователи могут получать несколько email сообщений 
-- для подтверждения учетной записи, пока они не подтвердят свою новую учетную запись.
-- Старшему аналитику интересно узнать процент подтверждения регистрации для 
-- конкретного списка пользователей из таблицы «emails». 
-- Напишите запрос, чтобы узнать процент подтверждения. 
-- Округлите процент до 3 знаков после запятой.

/* 
Допущения:
- Аналитика интересует процент подтверждений конкретных пользователей из таблицы «emails», 
которая может включать не всех пользователей, которых потенциально можно найти в таблице «texts».

- Например, user_id=1 из таблицы «emails» может отсутствовать в таблице «texts» и наоборот.
*/ 

# «Confirmed» в «signup_action» означает, что пользователь подтвердил свою учетную запись и успешно завершил процесс регистрации.

SELECT ROUND(
		COUNT(texts.email_id) / COUNT(DISTINCT emails.email_id),
		3
	) AS activation_rate
FROM emails
	LEFT JOIN texts ON emails.email_id = texts.email_id
	AND texts.signup_action = 'Confirmed';

-- 85. Есть три таблицы Spotify: «artists», «songs» и «global_song_rank», которые содержат информацию об исполнителях, песнях и музыкальных чартах соответственно.
-- Напишите запрос, чтобы найти 5 лучших исполнителей, чьи песни чаще всего появляются в первой десятке таблицы «global_song_rank». 
-- Отобразите имена 5 лучших исполнителей в порядке возрастания вместе с рангом появления песен в чартах.
-- Если у двух или более артистов одинаковое количество появлений песен в первой десятке, им следует присвоить одинаковый ранг. 
-- Номера рангов должны быть непрерывными (например, 1, 2, 2, 3, 4, 5). 
-- Если вы никогда раньше не видели подобного порядка ранжирования, ознакомьтесь с функцией DENSE_RANK. Больше об оконных функциях.

WITH top_10_cte AS (
	SELECT artists.artist_name,
		DENSE_RANK() OVER (
			ORDER BY COUNT(songs.song_id) DESC
		) AS artist_rank
	FROM artists
		INNER JOIN songs ON artists.artist_id = songs.artist_id
		INNER JOIN global_song_rank AS ranking ON songs.song_id = ranking.song_id
	WHERE ranking.song_rank <= 10
	GROUP BY artists.artist_id
)
SELECT artist_name,
	artist_rank
FROM top_10_cte
WHERE artist_rank <= 5;

-- 86. Tesla расследует узкие места производства, и им нужна ваша помощь для извлечения соответствующих данных. 
-- Напишите запрос, чтобы определить, над какими деталями уже начали процесс сборки, но еще не завершили.

/* 
Уточнения:
Таблица «parts_assembly» содержит все детали, находящиеся в настоящее время в производстве, каждая из которых находится на разных стадиях процесса сборки.
Незавершенной деталью считается деталь, у которой нет даты окончания («finish_date»). 
*/

SELECT part,
	assembly_step
FROM parts_assembly
WHERE finish_date IS NULL;

-- 87. Напишите запрос для определения двух наиболее активных пользователей, 
-- которые отправили наибольшее количество сообщений в Microsoft Teams в августе 2022 года. 
-- Отобразите идентификаторы этих двух пользователей вместе с общим количеством отправленных ими сообщений. 
-- Выведите результаты в порядке убывания на основе количества сообщений.

/* 
Уточнения:
В августе 2022 года ни один пользователь не отправил одинаковое количество сообщений.
*/ 

SELECT 
	sender_id, 
	COUNT(message_id) AS message_count
FROM messages
WHERE YEAR(sent_date) = 2022 AND MONTH(sent_date) = 8
GROUP BY sender_id
ORDER BY COUNT(message_id) DESC 
LIMIT 2;

-- 88. Вам предоставлена таблица транзакций Uber, совершенных пользователями. 
-- Напишите запрос для получения третьей транзакции каждого пользователя, если такая существует. 
-- Если такой транзакции нет, то выводить пользователя не нужно. 
-- Выведите идентификатор пользователя, сколько он потратил и дату транзакции.

WITH trans_num AS (
	SELECT user_id,
		spend,
		transaction_date,
		ROW_NUMBER() OVER (
			PARTITION BY user_id
			ORDER BY transaction_date
		) AS row_num
	FROM transactions
)
SELECT user_id,
	spend,
	transaction_date
FROM trans_num
WHERE row_num = 3;

-- 89. Есть таблица transact с транзакциями клиентов. 
-- Посчитать траты каждого клиента за последние 30 дней от текущего числа 
-- (период, который начинается 30 дней назад от текущей даты и заканчивается текущей датой включительно).

SELECT 
    id_client, SUM(sum_tran) AS total_spent_last_30_days
FROM transact
WHERE tran_time BETWEEN CURDATE()- INTERVAL 30 DAY AND CURDATE()   
GROUP BY id_client;

/*  90. В нашей компании замеряется такой показатель, как “30-дневная активная база”. 
Для любого дня — это число клиентов за предыдущие 30 дней. 
(Например, для 2022-01-01 — это число уникальных клиентов, совершивших визит за 30 дней до 2022-01-01, 
включая 2022-01-01. Для 2022-01-02 - это число уникальных клиентов, совершивших визит за 30 дней до 2022-01-02, включая 2022-01-02 и т.д.).

Допустим у вас есть таблица с чековыми данными по двум городам со следующими полями: 
cityname - наименование города, date - дата чека, orderid - id чека, clientid - id клиента, sales - сумма чека в рублях. 

Данные в таблице с 2022-01-01 по 2022-06-30.

Посчитайте подневную динамику 30-дневной активной базы по каждому городу, отсортируйте по городу и дате по возрастанию.

В результирующий таблице должны присутствовать данные для каждого дня с 2022-01-01 по 2022-06-30 для каждого города. */

WITH RECURSIVE DateRange AS (
	SELECT '2022-01-01' AS date
	UNION ALL
	SELECT DATE_ADD(date, INTERVAL 1 DAY)
	FROM DateRange
	WHERE date < '2022-06-30'
)
SELECT cityname,
	dr.date,
	COUNT(DISTINCT clientid) active_base
FROM daterange dr
	LEFT JOIN sales ON sales.date BETWEEN SUBDATE(dr.date, INTERVAL 29 DAY)
	AND dr.date
GROUP BY cityname,
	dr.date
ORDER BY cityname,
	dr.date;

-- 91. В Учи.ру дети решают задания, доступ к заданиям платный. 
-- Однако учитель может включить функцию «Урок», и в течение часа все задания станут бесплатными.
-- Написать SQL-запрос, чтобы посчитать количество учеников, у которых доля заданий, 
-- решённых во время функции «Урок» составляет больше 50% от общего числа решенных заданий.

WITH LessonSolved AS (
	SELECT s.user_id,
		COUNT(s.task_id) AS solved_during_lesson,
		(
			SELECT COUNT(*)
			FROM sessions
			WHERE user_id = s.user_id
		) AS total_solved
	FROM sessions s
		JOIN lessons l ON s.teacher_id = l.teacher_id
		AND s.session_time BETWEEN l.lesson_start AND l.lesson_end
	GROUP BY s.user_id
)
SELECT COUNT(*) AS amount_students
FROM LessonSolved
WHERE (solved_during_lesson / total_solved) > 0.5;

-- 92. Показать категорию (или категории), по которой(ым) было введено наибольшее число кодов. 
-- Cтатус ввода кода неважен, важен только факт ввода.

SELECT category FROM otp
GROUP BY category
HAVING COUNT(sessionId)
ORDER BY COUNT(sessionId) DESC 
LIMIT 1;

-- 93. Какой средний возраст клиентов, купивших Smartwatch (использовать наименование товара product.name) в 2024 году?

SELECT AVG(DISTINCT a.age) AS average_age 
FROM Customer a
JOIN Purchase b
ON a.customer_key = b.customer_key
JOIN Product c
ON b.product_key = c.product_key
WHERE YEAR(b.date) = 2024 
AND c.name = "Smartwatch";

-- 94. Вывести имена покупателей, каждый из которых приобрёл Laptop и Monitor 
-- (использовать наименование товара product.name) в марте 2024 года?

SELECT a.name AS name
FROM Customer a
JOIN Purchase b ON a.customer_key = b.customer_key
JOIN Product c ON b.product_key = c.product_key
WHERE YEAR(b.date) = 2024 AND MONTH(b.date) = 3
AND c.name IN ('Laptop', 'Monitor')
GROUP BY a.name
HAVING COUNT(DISTINCT c.name) = 2;

-- 95. Вывести имена клиентов, у которых сумма покупок за март и апрель 2024 превышает 9200, 
-- и итоговую потраченную сумму за эти 2 месяца:

SELECT a.name, SUM(b.quantity * c.price) AS total_spent 
FROM Customer a
JOIN Purchase b USING(customer_key)
JOIN Product c USING(product_key)
WHERE YEAR(b.date) = 2024 
AND MONTH(date) IN (03, 04)
GROUP BY a.name
HAVING SUM(b.quantity * c.price) > 9200;

-- 96. Вывести все товары, в наименовании которых содержится «самокат» (без учета регистра), 
-- и срок годности которых не превышает 7 суток.

SELECT product FROM Products
WHERE LOWER(product) LIKE "%самокат%" AND shelf_life <= 7;

-- 97. Посчитать количество работающих складов на текущую дату по каждому городу. 
-- Вывести только те города, у которых количество складов более 80. 
-- Данные на выходе - город, количество складов.

SELECT city, COUNT(warehouse_id) AS warehouse_count
FROM Warehouses
WHERE date_close IS NULL
GROUP BY city
HAVING COUNT(warehouse_id) > 80;

-- 98. Найти наибольшую зарплату по департаментам и отсортировать департаменты по убыванию максимальной зарплаты:

SELECT 
a.name AS DepartmentName, 
MAX(b.Salary) AS HighestSalary
FROM Departments a
JOIN Employees b ON a.id = b.Dep_id
GROUP BY a.name
ORDER BY MAX(b.Salary) DESC;

-- 99. Посчитай доход с женской аудитории (доход = сумма(price * items)). 
-- Обратите внимание, что в таблице женская аудитория имеет поле user_gender «female» или «f».

SELECT SUM(items * price) AS income_from_female
FROM Purchases
WHERE user_gender IN("female", "f");

-- 100. Посчитай кол-во уникальных пользователей-мужчин, заказавших более чем три вещи (items) 
-- суммарно за все заказы. Обратите внимание, что в таблице мужская аудитория имеет поле user_gender «male» или «m».

SELECT COUNT(DISTINCT user_id) AS unique_male_users
FROM 
	(
    SELECT user_id
    FROM Purchases
    WHERE LEFT(user_gender, 1) = 'm'
    GROUP BY user_id
    HAVING SUM(items) > 3
	) AS filtered_users;

-- 101. Выведи для каждого пользователя первое наименование, которое он заказал (первое по времени транзакции):

SELECT t1.user_id, t1.item
FROM Transactions t1
JOIN 
    (
    SELECT user_id, 
    MIN(transaction_ts) AS first_transaction
    FROM Transactions
    GROUP BY user_id
    ) t2
ON t1.user_id = t2.user_id 
AND t1.transaction_ts = t2.first_transaction;

-- 102. Посчитай сколько транзакций в среднем делают пользователи в течение 72-ух часов с момента первой транзакции:

WITH FirstTransaction AS (
	SELECT user_id,
		MIN(transaction_ts) AS first_ts
	FROM Transactions
	GROUP BY user_id
),
TransactionsWithin72Hours AS (
	SELECT ft.user_id,
		COUNT(*) AS transaction_count
	FROM Transactions t
		JOIN FirstTransaction ft ON t.user_id = ft.user_id
	WHERE TIMESTAMPDIFF(HOUR, ft.first_ts, t.transaction_ts) BETWEEN 0 AND 72
	GROUP BY ft.user_id
)
SELECT AVG(transaction_count) AS avg_transactions
FROM TransactionsWithin72Hours; 

-- 103. Вывести список имён сотрудников, получающих большую заработную плату, чем у непосредственного руководителя.

SELECT a.name FROM Employee a
WHERE a.salary > 
    (
    SELECT b.salary FROM Employee b 
    WHERE b.id = a.chief_id
    );


-- 104. Вывести список имён сотрудников, получающих максимальную заработную плату в своем отделе:

SELECT a.name FROM Employee a
JOIN 
    (
    SELECT department_id, MAX(salary) AS max_salary
    FROM Employee
    GROUP BY department_id
    ) b 
ON a.department_id = b.department_id 
AND a.salary = b.max_salary;

-- 105. Вывести список имён сотрудников, не имеющих назначенного руководителя, работающего в том же отделе:

SELECT employees.name
FROM Employee AS employees
	LEFT JOIN Employee AS chieves ON (
		employees.chief_id = chieves.Id
		AND employees.department_id = chieves.department_id
	)
WHERE chieves.id IS NULL;

-- 106. Выведите сумму выручки по каждому курсу за последний месяц.
-- Если сейчас 11 июля 10:15, то вы должны вывести сумму выручки 
-- за промежуток 11 июня 10:15 - 11 июля 10:15.

SELECT course_id, SUM(price) AS revenue FROM Orders
WHERE order_date BETWEEN CURRENT_TIMESTAMP()- INTERVAL 1 MONTH AND CURRENT_TIMESTAMP()
GROUP BY course_id;

-- 107. Выведите название курса и среднюю оценку для каждого курса с количеством оценок больше 10:

SELECT a.course_name, AVG(b.rating) AS average_rating
FROM Courses a
JOIN Ratings b USING(course_id)
GROUP BY a.course_name
HAVING COUNT(b.user_id) > 10;

-- 108. Выведите количество пользователей, которые совершили покупку курса, 
-- но не завершили его в течение 30 дней после покупки. 
-- Каждый пользователь может сделать только одну покупку.

SELECT COUNT(DISTINCT p.user_id) AS amount_users_not_completed
FROM Events p
WHERE p.event_type = 'course_purchase'
AND NOT EXISTS 
    (
	SELECT 1 FROM Events c
	WHERE c.user_id = p.user_id
	AND c.event_type = 'course_complete'
	AND c.event_date BETWEEN p.event_date AND DATE_ADD(p.event_date, INTERVAL 30 DAY)
	);
    
-- 109. Выведите название страны, где находится город «Salzburg»:

SELECT name AS country_name FROM Countries
WHERE id = 
    (
    SELECT countryid FROM Regions
    WHERE id = 
        (
        SELECT regionid FROM Cities
        WHERE name = "Salzburg"
        )
    );

-- 110. Выведите названия городов, расположенных в регионе «Bavaria»:

SELECT name AS city_name FROM Cities
WHERE regionid = 
    (
    SELECT id FROM Regions
    WHERE name = "Bavaria"
    );
    
-- 111. Посчитайте население каждого региона. 
-- В качестве результата выведите название региона и его численность населения.

SELECT a.name AS region_name, SUM(b.population) AS total_population
FROM Regions a
JOIN Cities b ON a.id = b.regionid
GROUP BY a.id;

-- 112. Подсчитайте средние траты на каждый тип события в городе «Hamburg». 
-- Если каких-то типов событий не было в этом городе, то необходимо вывести 0 в качестве средних трат.

WITH HamburgEventTypes AS 
(
	SELECT EventType.id,costs
	FROM EventType
	JOIN EVENTS ON typeid = EventType.id
	JOIN Cities ON cityid = Cities.id
	WHERE Cities.name = "Hamburg"
)
SELECT EventType.name AS event_type,
	(
	SELECT COALESCE(AVG(costs), 0)
	FROM HamburgEventTypes
	WHERE EventType.id = HamburgEventTypes.id
	) AS average_costs
FROM EventType;

-- 113. Supercloud Microsoft Azure клиент - это клиент, который приобрел хотя бы 
-- один продукт из каждой категории продуктов, указанной в таблице Products.
-- Напишите запрос, который определяет идентификаторы клиентов, являющихся такими Supercloud клиентами.

SELECT a.customer_id FROM CustomerContracts a
JOIN Products b USING(product_id)
GROUP BY a.customer_id
HAVING COUNT(DISTINCT b.product_category) = 
    (
	SELECT COUNT(DISTINCT c.product_category)
	FROM Products c
	);
    
-- 114. Напишите запрос, который выведет имена пилотов, которые в качестве второго пилота (second_pilot_id) в августе 2023 года летали в New York:

SELECT name FROM Pilots
WHERE pilot_id IN
    (
    SELECT second_pilot_id FROM Flights
    WHERE YEAR(flight_date) = 2023 AND 
    MONTH(flight_date) = 08 AND destination = "New York"
    );
    
-- 115. Выведите пилотов старше 45 лет, которые совершили больше 2 полётов на грузовых самолетах:

SELECT name FROM Pilots
WHERE age > 45 AND pilot_id IN 
    (
    SELECT pilot_id FROM 
        (
        SELECT first_pilot_id AS pilot_id 
        FROM Flights 
        WHERE plane_id IN 
            (
            SELECT plane_id 
            FROM Planes 
            WHERE cargo_flag = 1
            )
        
        UNION ALL
        
        SELECT second_pilot_id AS pilot_id 
        FROM Flights 
        WHERE plane_id IN 
            (
            SELECT plane_id 
            FROM Planes 
            WHERE cargo_flag = 1
            )
        ) AS all_pilots
    GROUP BY pilot_id
    HAVING COUNT(*) > 2
	);
    
-- 116. Выведите топ 3 пилотов-капитанов (first_pilot_id), которые перевезли наибольшее число пассажиров. 
-- В качестве количества пассажиров используйте вместимость самолёта (поле capacity). 
-- Выведите имена пилотов-капитанов и количество перевезённых пассажиров, 
-- результат отсортируйте по количеству перевезённых пассажиров в порядке убывания.

SELECT a.name, SUM(c.capacity) AS total_passengers
FROM Pilots a
LEFT JOIN Flights b ON a.pilot_id = b.first_pilot_id   
LEFT JOIN Planes c ON b.plane_id = c.plane_id
GROUP BY a.name
ORDER BY SUM(c.capacity) DESC 
LIMIT 3;

-- 117. Напишите SQL-запрос, который вычисляет время доставки (в целых часах) для заказов, соответствующих следующим условиям:
-- Заказ был принят (Accepted) 1 января 2024 года (2024-01-01)
-- Заказ не был отменен (Canceled) или возвращен (Returned)
-- Время доставки рассчитывается как разница между временем первого статуса Accepted и временем статуса Delivered для каждого подходящего заказа.
-- Результат должен содержать только целое количество часов, без учета минут. 
-- Например, если время доставки составляет 47 часов и 59 минут, результатом будет 47 часов.

SELECT o1.order_id,
TIMESTAMPDIFF(HOUR, o1.status_datetime, o2.status_datetime) AS delivery_time_hours
FROM OrderStatus o1
JOIN OrderStatus o2 ON o1.order_id = o2.order_id
WHERE o1.status = 'Accepted'
AND DATE(o1.status_datetime) = '2024-01-01'
AND o2.status = 'Delivered'
AND o1.order_id NOT IN 
    (
	SELECT DISTINCT order_id
	FROM OrderStatus
	WHERE status IN ('Canceled', 'Returned')
	)
GROUP BY o1.order_id, delivery_time_hours;

-- 118. Необходимо написать SQL-запрос, который вернёт по 5 самых «разговорчивых» абонентов 
-- (с наибольшей суммарной длительностью звонков) в каждом филиале. В результирующем наборе для каждого абонента нужно вывести:
-- название филиала (region),
-- идентификатор пользователя (user_id),
-- суммарную продолжительность его звонков (total_duration).

WITH user_sums AS 
(
	SELECT user_id,
		region,
		SUM(duration) AS total_duration
	FROM Calls
	GROUP BY user_id,
		region
),
ranked AS (
	SELECT user_id,
		region,
		total_duration,
		ROW_NUMBER() OVER (
			PARTITION BY region
			ORDER BY total_duration DESC
		) AS rn
	FROM user_sums
)
SELECT region,
	user_id,
	total_duration
FROM ranked
WHERE rn <= 5
ORDER BY region,
	total_duration DESC;






































    
    














































    





























































