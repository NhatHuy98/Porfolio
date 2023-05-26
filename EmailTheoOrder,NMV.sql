SELECT *
FROM(
SELECT
	ce.`email` AS 'Email',
	so.`entity_id` AS 'Order Number',
	soi.`created_at` AS 'Created Time',
	ROUND(soi.`price` * soi.`qty_ordered`,0) AS 'NMV'
FROM
	`customer_entity` ce
	LEFT JOIN `sales_order` so
	ON ce.`entity_id` = so.`customer_id`
	LEFT JOIN `sales_order_item` soi
	ON so.`entity_id` = soi.`order_id`
WHERE 	
	soi.`created_at` >= '2019-07-18 00:00:00'
) AS f
-- WHERE f.`NMV` >= 350000

ORDER BY 3,1
LIMIT 1000000