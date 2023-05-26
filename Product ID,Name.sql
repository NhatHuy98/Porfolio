SELECT
  u.product_id AS 'ProductID',
  na.value AS 'ProductName',
  br.`name` AS 'Brand',
  uv.vendor_name AS 'Seller'
FROM
  mainbo.`udropship_vendor_product` u
  LEFT JOIN mainbo.catalog_product_entity_varchar na
    ON u.`product_id` = na.`entity_id`
    AND na.`attribute_id` = 140
  LEFT JOIN `mainbo`.`catalog_product_entity_int` ci
    ON ci.`entity_id` = u.`product_id`
    AND ci.`attribute_id` = 447
    AND ci.store_id = 0
  LEFT JOIN `mainbo`.`ves_brand` br
    ON br.`brand_id` = ci.`value`
  LEFT JOIN mainbo.`udropship_vendor` uv
    ON u.`vendor_id` = uv.vendor_id
GROUP BY 1
LIMIT 1000