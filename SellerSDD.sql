SELECT DISTINCT
v.vendor_id AS 'Seller ID',
v.vendor_name AS 'Seller Name',
CASE WHEN v.`carrier_code` LIKE '%sdd%' THEN 'SDD'
WHEN v.`carrier_code` LIKE '%kerry%' THEN '3PL'
WHEN v.`carrier_code` LIKE '%vnpost%' THEN '3PL'
WHEN v.`carrier_code` LIKE '%dhl%' THEN '3PL'
WHEN v.`carrier_code` LIKE '%ghn%' THEN '3PL'
WHEN v.`carrier_code` LIKE '%lotteexpress%' THEN '3PL*'
WHEN v.`carrier_code` LIKE '%sixty%' THEN '3PL'
WHEN v.`carrier_code` LIKE '%ninjavan%' THEN '3PL'
WHEN v.`carrier_code` LIKE '%vecedelivery%' THEN 'E-DELIVERY'
WHEN v.`carrier_code` LIKE '%lvs%' THEN 'Evoucher'
WHEN v.`carrier_code` LIKE '%pickup%' THEN 'Pickup In Store'
WHEN v.`carrier_code` LIKE '%sbp%' THEN '3PL'
ELSE 'Other'
 END AS 'Shipping_Type',
CASE 
WHEN v.`STATUS` LIKE '%A%' THEN 'Active' 
WHEN v.`STATUS` LIKE '%I%' THEN 'Inactive'
WHEN v.`STATUS` LIKE '%D%' THEN 'Disabled'
WHEN v.`STATUS` LIKE '%R%' THEN 'Rejected'
WHEN v.`STATUS` LIKE '%Y%' THEN 'Pending Approve'
WHEN v.`STATUS` LIKE '%Z%' THEN 'Submit Change'
WHEN v.`STATUS` LIKE '%M%' THEN 'MD Confirm'
  ELSE 'Other' END AS 'Status',
ctm.category_id AS 'Cat ID',
ctm.cat_01_en AS 'Cat Group',
ctm.cat_name_en AS 'Cat Name',
ctm.md_name AS 'MD In Charge',
ctm.md_email AS 'MD Email',
re.region_name AS 'Seller City',
v.`telephone` AS 'Seller Phone',
  v.`street` AS 'Seller Address',
  v.`contract_type` AS 'Contract Type',
  v.`contract_number` AS 'Contract Seller',
v.`tax_code` AS 'Tax Code Seller',
 CAST(vpr.`registered_at`AS DATE) AS 'Seller Registered Date',
 v.`reject_reason` AS 'Reject Reason',
 v.`udmember_membership_title` AS 'Seller Membership',
 v.`seller_type` AS 'Seller Type',
v.`shipping_service` AS 'Shipping Service',
CASE WHEN v.`start_date` IS NULL THEN NULL ELSE CAST(v.`start_date`AS DATE)END AS 'Start Date',
CASE WHEN v.`end_date` IS NULL THEN NULL ELSE CAST(v.`end_date`AS DATE)END AS 'End Date',
v.`pickup_enable`,
v.`apply_ship_sixty`,
v.`pickup_leadtime_afternoon`,
v.`pickup_leadtime_morning`,
v.`pickup_location`,
v.`pickup_location_map`
-- SDD location
-- r.region_name AS 'SDD Province',
-- GROUP_CONCAT(DISTINCT r.district_name ORDER BY r.district_name ASC) AS 'SDD Distirct'
FROM 
mainbo.`udropship_vendor` v
LEFT JOIN mainbo.`udropship_vendor_registration` vpr
 ON vpr.`vendor_name` = v.`vendor_name`
LEFT JOIN aggregate.`region` re
ON re.ward_id = v.ward_id
LEFT JOIN mainbo.`sdd_vendor_info` i
ON v.vendor_id = i.vendor_id
LEFT JOIN aggregate.`seller_cat` sc
ON v.vendor_id = sc.seller_id
LEFT JOIN `category_tree_manual` ctm
ON sc.category_id = ctm.category_id
LEFT JOIN mainbo.`sdd_vendor_shiparea` s
ON i.vendor_id = s.vendor_id
LEFT JOIN aggregate.`region`  r
ON s.ward= r.ward_id

WHERE v.`STATUS` LIKE '%A%'
AND v.`carrier_code` LIKE '%sdd%'
AND ctm.category_id IS NOT NULL

ORDER BY 1
LIMIT 1000000