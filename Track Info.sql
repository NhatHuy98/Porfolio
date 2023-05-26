SELECT DISTINCT
  i.`item_id` AS 'Order Item ID',
  i.`order_id` AS 'Order ID',
  o.`increment_id` AS 'Order Number',
  o.`created_at` AS 'Created Time',
  o.`state` AS 'Order State',
  st.`label` AS 'Order Status',
  o.`sm_order_cancellation_note` AS 'Cancel Reason Comment',
  CASE
    WHEN o.`store_id` = 0
    THEN 'ADMIN'
    WHEN o.`store_id` = 1
    THEN 'PC_VI'
    WHEN o.`store_id` = 2
    THEN 'PC_EN'
    WHEN o.`store_id` = 9
    THEN 'APP_VI'
    ELSE NULL
   END AS 'Store',
   sst.shipment_status AS 'Shipment Status',
   UPPER(o.`coupon_code`)AS 'Coupon Code',
   gr.`entity_id` AS 'PO ID',
   gr.`increment_id` AS 'PO Number',
   pos.`po_status` AS 'PO Status',
   ss.increment_id AS 'Shipment Number',
   i.`product_id` AS 'Product ID',
   i.`name` AS 'Product Name',
   ROUND(
    IFNULL(vp.`vendor_price`, i.`original_price`),
    0
  ) AS 'RRP',
   ROUND(i.`price`, 0) AS 'Product Price',
   ROUND(IFNULL(i.`qty_ordered`, 0), 0) AS 'Quantity Ordered',
   v.`vendor_id` AS 'Seller ID',
   v.`vendor_name` AS 'Seller Name',
   v.`udmember_membership_title` AS 'Seller Membership',
   re.`region_name` AS 'Seller City' ,
   CASE
    WHEN o.`customer_id` IS NULL
    THEN 0
    ELSE o.`customer_id`
   END AS 'Customer ID',
   IFNULL(o.`remote_ip`, '0.0.0.0') AS 'Customer IP',
   o.`customer_email` AS 'Customer Email',
   cv.`value` AS 'Customer Phone',
   CASE 
    WHEN s.`telephone` IS NULL THEN 0
    ELSE TRIM(REPLACE(REPLACE(REPLACE(s.`telephone`,'+84',0),'+',''),"'",''))
   END AS 'Shipping Telephone',
   s.`street` AS 'Shipping Address',
   s.`district` AS 'Shipping District',
   s.`ward` AS 'Shipping Ward',
   o.`sm_payment_title` AS 'Payment Title',
   o.`vat_required` AS 'Red Invoice',
   o.`vat_company_name` AS 'Red Invoice Company',
   o.`vat_company_taxcode` AS 'Red Invoice Taxcode',
   CASE WHEN o.`auto_checked_blacklist` = 0  THEN 'Magento' ELSE 'BI'
   END AS 'Blacklist'
 FROM 
  mainbo.sales_order_item i
  LEFT JOIN mainbo.sales_order o
    ON i.`order_id` = o.`entity_id`
  LEFT JOIN mainbo.sales_order_address s
    ON o.`entity_id` = s.`parent_id`
 LEFT JOIN mainbo.sales_order_status st
    ON o.`status` = st.`status`
  LEFT JOIN mainbo.udropship_po_item poi
    ON poi.`order_item_id` = i.`item_id`
  LEFT JOIN mainbo.udropship_po gr
    ON gr.`entity_id` = poi.`parent_id`
	
  LEFT JOIN aggregate.`po_status` pos 
	ON pos.po_status_code = gr.udropship_status
  LEFT JOIN mainbo.udropship_vendor v
    ON v.`vendor_id` = i.`udropship_vendor`
  LEFT JOIN mainbo.customer_entity_varchar cv
    ON o.`customer_id` = cv.`entity_id`
    AND cv.`attribute_id` = 545
     LEFT JOIN mainbo.udropship_vendor_product vp
    ON i.`product_id` = vp.`product_id`
     LEFT JOIN aggregate.`region` re
  ON re.ward_id = v.`ward_id`
  LEFT JOIN mainbo.sales_shipment_item ssi
    ON ssi.`order_item_id` = i.`item_id`
  LEFT JOIN mainbo.sales_shipment ss
    ON ss.`entity_id`  = ssi.`parent_id`
    LEFT JOIN `aggregate`.`shipment_status` sst
ON sst.shipment_status_code = ss.udropship_status 
 
 WHERE i.`price` > 0 AND s.`telephone`=   0966558998
 GROUP BY i.`item_id`
ORDER BY i.`item_id` DESC
LIMIT 1000000
       
  