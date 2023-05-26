 SELECT DISTINCT
  o.`increment_id` AS 'Order Number',
  o.`created_at` AS 'Created Time',
  v.`vendor_name` AS 'Seller Name',
  i.`sku` AS 'Product SKU',
  i.`name` AS 'Product Name',
  br.`name` AS 'Brand Name',
  pcf.category_id AS 'Category ID',
  ctm.`vertical` AS 'Cat Group',
  ctm.`cat_01_en` AS 'Cat 1',
  ROUND(i.`price`, 0) AS 'Product Price',
  ROUND(i.`qty_ordered` - poi.`qty_canceled`, 0) AS 'Item Sold',
  ROUND(i.`price` * (i.`qty_ordered` - poi.`qty_canceled`),0) AS 'NMV'

FROM
  mainbo.sales_order_item i
  LEFT JOIN mainbo.sales_order o
    ON i.`order_id` = o.`entity_id`
  LEFT JOIN mainbo.sales_order_payment p
    ON o.`entity_id` = p.`parent_id`
  LEFT JOIN mainbo.sales_order_status st
    ON o.`status` = st.`status`
  LEFT JOIN mainbo.udropship_po_item poi
    ON poi.`order_item_id` = i.`item_id`
  LEFT JOIN mainbo.udropship_po gr
    ON gr.`entity_id` = poi.`parent_id`
  LEFT JOIN aggregate.`po_status` pos 
    ON pos.po_status_code = gr.udropship_status
  LEFT JOIN `mainbo`.`catalog_product_entity_int` ci
    ON ci.`entity_id` = i.`product_id`
    AND ci.`attribute_id` = 447
    AND ci.store_id = 0
  LEFT JOIN `mainbo`.`ves_brand` br
    ON br.`brand_id` = ci.`value`
  LEFT JOIN mainbo.udropship_vendor_product vp
    ON i.`product_id` = vp.`product_id`
  LEFT JOIN mainbo.udropship_vendor v
    ON v.`vendor_id` = i.`udropship_vendor`
  LEFT JOIN mainbo.customer_entity ce
    ON ce.`entity_id` = o.`customer_id`
  LEFT JOIN `aggregate`.`product_cat_final` pcf
    ON pcf.product_id = i.`product_id`
  LEFT JOIN aggregate.`category_tree_manual` ctm
    ON pcf.`category_id` = ctm.`category_id`

WHERE i.`price` > 0
   AND i.`created_at` >= '2018-01-01 00:00:00'
   AND ctm.`division` = 'LOTTEVN'
   AND st.`label` IN ('Comeplete','Partial Complete')
   AND pos.po_status IN ('Comepleted','Partial Completed')
 
ORDER BY 2 DESC
LIMIT 1000000