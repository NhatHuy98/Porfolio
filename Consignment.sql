SELECT DISTINCT
	gr.`created_at` AS 'po_created_at',
	gr.`increment_id` AS 'po_increment_id',
	poi.`seller_barcode` AS 'seller_barcode',
	gr.udropship_status AS 'udropship_status',
	pos.`po_status` AS 'PO_Status',
	gr.`base_total_value` AS 'total_value',
	gr.`shipping_amount` AS 'shipping_amount',
	o.shipping_description AS 'shipping_description',
	v.`vendor_id` AS 'vendor_id',
	v.`vendor_name` AS 'vendor_name',
	v.`udmember_membership_code` AS 'udmember_membership_code',
	p.`method` AS 'method',
	o.`increment_id` AS 'so_increment_id',						
	o.`created_at` AS 'so_created_at',
	o.`updated_at` AS 'so_updated_at',
	o.`status` AS 'status',
	o.`customer_email` AS 'customer_email',
	o.`customer_firstname` AS 'customer_firstname',
	o.`customer_lastname` AS 'customer_lastname',
	o.`coupon_code` AS 'coupon_code',
	o.`approve_date` AS'approve_date',
	b.`city` AS 'billing_city',
	b.`district` AS 'billing_district',
	b.`region` AS 'billing_region',
	b.`telephone` AS 'billing_telephone',
	b.`ward` AS 'billing_ward',
	b.`street` AS 'billing_street',
	poi.`sku` AS 'sku',
	poi.`product_id` AS 'product_id',
	poi.`vendor_sku` AS 'vendor_sku',
	poi.`name` AS 'name',
	poi.`price` AS 'price',
	poi.`qty` AS 'qty',
	poi.`qty_canceled` AS 'qty_canceled',
	poi.`qty_shipped` AS 'qty_shipped',
	poi.`raw_total` AS 'raw_total',
	poi.`commission_percent` AS 'commission',
	poi.`base_discount_amount` AS 'discount_amount'
	
FROM
	mainbo.sales_order_item i
	LEFT JOIN mainbo.sales_order o
	ON i.`order_id` = o.`entity_id`
	LEFT JOIN mainbo.udropship_vendor v
	ON v.`vendor_id` = i.`udropship_vendor`
	LEFT JOIN mainbo.`udropship_vendor_product` vp
	ON v.`vendor_id` = vp.`vendor_id`
	LEFT JOIN mainbo.`udropship_po_item` poi
	ON vp.`product_id` = poi.`product_id`
	LEFT JOIN mainbo.`udropship_po` gr
	ON gr.`entity_id` = poi.`parent_id`
	LEFT JOIN `aggregate`.`po_status` pos
	ON pos.`po_status_code` = gr.`udropship_status`
	LEFT JOIN mainbo.sales_order_address b
	ON o.`entity_id` = b.`parent_id`
	AND b.`address_type` = 'billing'
	LEFT JOIN mainbo.sales_order_payment p
	ON o.`entity_id` = p.`parent_id`
	
WHERE
	poi.`price` >= 0
	AND v.`udmember_membership_code` = 'Lotte_consignment'

ORDER BY 1