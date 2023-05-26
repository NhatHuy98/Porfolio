SELECT DISTINCT
  i.`item_id` AS 'Order Item ID',
  o.`created_at` AS 'Created Time',
  gr.`increment_id` AS 'PO Number',
  pos.`po_status` AS 'PO Status',
  ROUND(IFNULL(i.`qty_ordered`, 0), 0) AS 'SL',
  i.`name` AS 'Product Name',
  ROUND(i.`price`, 0) AS 'Product Price',
  IFNULL(o.`remote_ip`, '0.0.0.0') AS 'Customer IP',
  CASE 
   WHEN s.`telephone` IS NULL THEN 0
   ELSE TRIM(REPLACE(REPLACE(REPLACE(s.`telephone`,'+84',0),'+',''),"'",''))
  END AS 'Shipping Telephone',
  CASE WHEN o.`auto_checked_blacklist` = 0  THEN 'Magento' ELSE 'BI'
  END AS 'Blacklist'
FROM 
  mainbo.sales_order_item i
  LEFT JOIN mainbo.sales_order o
    ON i.`order_id` = o.`entity_id`
  LEFT JOIN mainbo.sales_order_address s
    ON o.`entity_id` = s.`parent_id`
  LEFT JOIN mainbo.udropship_po_item poi
    ON poi.`order_item_id` = i.`item_id`
  LEFT JOIN mainbo.udropship_po gr
    ON gr.`entity_id` = poi.`parent_id`
  LEFT JOIN aggregate.`po_status` pos
	ON pos.po_status_code = gr.udropship_status
  WHERE i.`price` > 0
  AND o.`created_at` >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
  AND o.`customer_email` LIKE '%hailai1990@gmail.com%'
  

GROUP BY 1
ORDER BY 2 DESC
LIMIT 1000000
       
  