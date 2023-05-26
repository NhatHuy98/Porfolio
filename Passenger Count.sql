WITH sub AS(
	SELECT p.id AS id1, b.id AS id2, b.origin AS org, b.destination AS des, p.time AS p_time , b.time AS b_time
	FROM bus AS b
	JOIN passengers p 
	ON b.origin = p.origin AND b.destination = p.destination AND b.time >= p.time)
		
SELECT b.id, COUNT(sub2.pass_id) AS passengers_on_board
FROM bus AS b
LEFT JOIN
	(SELECT MIN(sub.b_time) AS TIME, sub.id1 AS pass_id, sub.org, sub.des 
	FROM sub
	GROUP BY sub.id1, sub.org, sub.des) AS sub2 
ON b.origin = sub2.org AND b.destination = sub2.des  AND b.time = sub2.time
GROUP BY b.id
ORDER BY b.id