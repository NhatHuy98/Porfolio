SELECT 
v.`product_id`,
v.`vendor_price`,
v.`special_price`,
v.`special_from_date`,
v.`special_to_date`

FROM `udropship_vendor_product` v
WHERE v.`product_id` IN 
(
3923595,
3923597,
3923601,
3923603,
3923685,
4006945,
4006947,
4006949,
4006951,
4006953,
4006955,
4006957,
4006959,
4006961,
4006963,
4006965,
4006967
)