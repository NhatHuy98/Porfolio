SELECT
    i.product_id AS 'Product ID',
    na.`value` AS 'Product Name',
    ct.`value` AS 'Info'
  FROM  mainbo.udropship_vendor v
	LEFT JOIN mainbo.`udropship_vendor_product` i
	ON v.vendor_id = i.vendor_id
  LEFT JOIN `catalog_product_entity_text` ct
  ON i.product_id = ct.`entity_id`
	LEFT JOIN catalog_product_entity_varchar na
	ON i.product_id = na.entity_id
      WHERE v.vendor_name = 'The Face Mall'
			GROUP BY 1
LIMIT 10000000