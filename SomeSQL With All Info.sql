SELECT *
  /*c.`Created Date`,
  c.`Order Number`,
  c.`Product ID`,
  c.`Revenue` AS 'NMV (USD)',
  c.`Quantity Ordered` AS 'ValidItem'*/
FROM
  (SELECT DISTINCT
    b.*,
    CASE
      -- order, po, shipment completed
       WHEN b.`Order Status` LIKE '%Completed%'
      THEN 'Valid'
      WHEN b.`PO Status` LIKE '%Completed%'
      THEN 'Valid'
      WHEN b.`Shipment Status` LIKE '%Delivered%'
      THEN 'Valid' -- shipment: cancel end status
       WHEN (
        b.`Shipment Status` LIKE '%Cancelled%'
        OR -- customer cancel trước 3PL pick hàng
         b.`Shipment Status` LIKE 'Pick Failed'
        OR b.`Shipment Status` LIKE 'Cancelled - OOS'
        OR b.`Shipment Status` LIKE 'Lost Package'
        OR b.`Shipment Status` LIKE '%Ship Failed%'
      )
      THEN 'Invalid' -- po : cancel end status
       WHEN (
        b.`PO Status` LIKE '%Partial Completed%'
        AND b.`Shipment Created` LIKE '%No%'
      )
      THEN 'Invalid'
      WHEN (b.`PO Status` LIKE '%Cancel%')
      THEN 'Invalid'
      WHEN (
        b.`PO Status` LIKE '%Delivery Failed%'
      )
      THEN 'Invalid'
      WHEN (
        b.`PO Status` LIKE '%Ship Failed%'
      )
      THEN 'Invalid' -- order: cancel end status
       WHEN (
        b.`Order Status` LIKE '%Order Failed%'
        OR b.`Order Status` LIKE '%Payment Failed%'
        OR b.`Order Status` LIKE '%SM Canceled%'
        OR b.`Order Status` LIKE '%Cancelled%'
      )
      THEN 'Invalid' -- order test
       WHEN b.`Test` NOT LIKE 'Nontest'
      THEN 'Invalid'
      ELSE 'Valid'
    END AS 'Actual Status'
  FROM
    (SELECT DISTINCT
      a.*,
      CASE
        WHEN LOWER(a.`Customer Email`) LIKE '%test%'
        THEN 'Test'
        WHEN LOWER(a.`Customer Name`) LIKE '%test%'
        THEN 'Test'
        WHEN LOWER(a.`Shipping Name`) LIKE '%test%'
        THEN 'Test'
        WHEN LOWER(a.`Billing Address`) LIKE '%test%'
        THEN 'Test'
        WHEN LOWER(a.`Shipping Address`) LIKE '%test%'
        THEN 'Test'
        WHEN LOWER(a.`Cancel Reason Comment`) LIKE '%test%'
        THEN 'Test' -- cancel cs note
         ELSE 'Nontest'
      END AS 'Test',
      ROUND(
        a.`Product Price` * a.`Quantity Ordered` / 23000,
        2
      ) AS 'Revenue'
    FROM
      (SELECT DISTINCT
        i.`item_id` AS 'Order Item ID',
        i.`order_id` AS 'Order ID',
        o.`increment_id` AS 'Order Number',
        ROUND(o.`subtotal`, 0) AS 'Order Total',
        CAST(o.`created_at` AS DATE) AS 'Created Date',
        MAX(o.`completed_at`) AS 'SO Completed Time',
        o.`state` AS 'Order State',
        st.`label` AS 'Order Status',
        o.`sm_order_cancellation_note` AS 'Cancel Reason Comment',
        CASE
          WHEN COUNT(ssi.`entity_id`) > 0
          THEN 'Yes'
          ELSE 'No'
        END AS 'Shipment Created',
        o.`customer_email` AS 'Customer Email',
        CONCAT(
          UPPER(o.`customer_firstname`),
          ' ',
          UPPER(o.`customer_lastname`)
        ) AS 'Customer Name',
        gr.`entity_id` AS 'PO ID',
        gr.`increment_id` AS 'PO Number',
        gr.`created_at` AS 'PO Created Time',
        pos.`po_status` AS 'PO Status',
        ss.increment_id AS 'Shipment Number',
        sst.`shipment_status` AS 'Shipment Status',
        i.`product_id` AS 'Product ID',
        -- add cat id
--  pcf.category_id AS 'Category ID',
         ROUND(TRIM(vp.`stock_qty`), 0) AS 'Stock',
        i.`sku` AS 'Product SKU',
        i.`name` AS 'Product Name',
        br.`name` AS 'Brand Name',
        ROUND(IFNULL(i.`qty_ordered`, 0), 0) AS 'Quantity Ordered',
        ROUND(
          IFNULL(poi.`sm_qty_available`, 0),
          0
        ) AS 'Quantity Available',
        ROUND(IFNULL(i.`qty_shipped`, 0), 0) AS 'Quantity Shipped',
        ROUND(IFNULL(poi.`qty_delivered`, 0), 0) AS 'Quantity Delivered',
        ROUND(
          IFNULL(poi.`qty_ship_failed`, 0),
          0
        ) AS 'Quantity Failed Delivery',
        ROUND(IFNULL(poi.`qty_canceled`, 0), 0) AS 'Quantity Canceled',
        ROUND(IFNULL(i.`qty_refunded`, 0), 0) AS 'Quantity Refunded',
        ROUND(
          IFNULL(
            CASE
              WHEN i.`qty_urma` IS NULL
              OR i.`qty_urma` = 0
              THEN i.`qty_returned`
              ELSE i.`qty_urma`
            END,
            0
          ),
          0
        ) AS 'Quantity Return',
        ROUND(i.`price`, 0) AS 'Product Price',
        ROUND(i.`discount_amount`, 0) AS 'Discount Amount',
        CONCAT(
          UPPER(s.`firstname`),
          ' ',
          UPPER(s.`lastname`)
        ) AS 'Shipping Name',
        s.`street` AS 'Shipping Address',
        CONCAT(
          UPPER(b.`firstname`),
          ' ',
          UPPER(b.`lastname`)
        ) AS 'Billing Name',
        b.`street` AS 'Billing Address',
        ctm.cat_group_md AS 'Cat Group Final',
        v.vendor_id AS 'Seller ID',
        v.vendor_name AS 'Seller Name',
        ctm.category_id AS 'Cat ID'
      FROM
        mainbo.sales_order_item i
        LEFT JOIN mainbo.sales_order o
          ON i.`order_id` = o.`entity_id`
        LEFT JOIN mainbo.sales_order_payment p
          ON o.`entity_id` = p.`parent_id`
        LEFT JOIN mainbo.sales_order_address s
          ON o.`entity_id` = s.`parent_id`
          AND s.`address_type` = 'shipping'
        LEFT JOIN mainbo.sales_order_address b
          ON o.`entity_id` = b.`parent_id`
          AND b.`address_type` = 'billing'
        LEFT JOIN mainbo.sales_order_status st
          ON o.`status` = st.`status`
        LEFT JOIN mainbo.udropship_po_item poi -- USE INDEX (PrIndex4)
           ON poi.`order_item_id` = i.`item_id`
        LEFT JOIN mainbo.udropship_po gr
          ON gr.`entity_id` = poi.`parent_id`
        LEFT JOIN `aggregate`.`po_status` pos
          ON pos.po_status_code = gr.udropship_status
        LEFT JOIN mainbo.udropship_po_comment upc
          ON upc.`parent_id` = gr.`entity_id`
          AND upc.`udropship_status` IN ('Đang xử lý', 'Processing')
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
        LEFT JOIN mainbo.catalog_product_entity_varchar vc -- USE INDEX (ProIndex)
           ON vc.`entity_id` = i.`product_id`
          AND vc.`attribute_id` = 557
          AND vc.store_id = 0
        LEFT JOIN mainbo.customer_entity_varchar cv
          ON o.`customer_id` = cv.`entity_id`
          AND cv.`attribute_id` = 545
        LEFT JOIN mainbo.customer_entity ce
          ON ce.`entity_id` = o.`customer_id`
        LEFT JOIN mainbo.sales_shipment_item ssi
          ON ssi.`order_item_id` = i.`item_id`
        LEFT JOIN mainbo.sales_shipment ss
          ON ss.`entity_id` = ssi.`parent_id`
        LEFT JOIN `aggregate`.`shipment_status` sst
          ON sst.shipment_status_code = ss.udropship_status -- add new
         LEFT JOIN `aggregate`.`product_cat_final` pcf
          ON pcf.product_id = i.`product_id`
        LEFT JOIN aggregate.`category_tree_manual` ctm
          ON ctm.category_id = pcf.category_id
      WHERE i.`price` > 0
        AND o.`created_at` >= '2019-01-01 00:00:00' -- AND (ctm.cat_group_md  LIKE '%Apparels%' OR ctm.cat_group_md  LIKE '%Sport%')
       GROUP BY i.`item_id`
      ORDER BY i.`item_id` ASC
      LIMIT 100000000) AS a) AS b
  GROUP BY 1
  ORDER BY 1) AS c
WHERE c.`Actual Status` LIKE 'Valid'
GROUP BY 1
LIMIT 10000000000