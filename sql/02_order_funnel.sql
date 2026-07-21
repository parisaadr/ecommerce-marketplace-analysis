-- ====================================
-- ORDER FUNNEL
-- ====================================

SELECT
    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN order_approved_at IS NOT NULL
            THEN order_id END
        ) * 100.0
        / COUNT(DISTINCT order_id),
        2
    ) AS approval_rate,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN order_delivered_carrier_date IS NOT NULL
            THEN order_id END
        ) * 100.0
        / COUNT(DISTINCT order_id),
        2
    ) AS shipped_rate,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN order_delivered_customer_date IS NOT NULL
            THEN order_id END
        ) * 100.0
        / COUNT(DISTINCT order_id),
        2
    ) AS delivered_rate

FROM orders;


-- ====================================
-- FUNNEL DROPOFFS
-- ====================================

WITH funnel AS (

    SELECT
        COUNT(DISTINCT order_id) AS purchased,

        COUNT(DISTINCT CASE
            WHEN order_approved_at IS NOT NULL
            THEN order_id END
        ) AS approved,

        COUNT(DISTINCT CASE
            WHEN order_delivered_carrier_date IS NOT NULL
            THEN order_id END
        ) AS shipped,

        COUNT(DISTINCT CASE
            WHEN order_delivered_customer_date IS NOT NULL
            THEN order_id END
        ) AS delivered

    FROM orders
)

SELECT
    ROUND(
        (purchased - approved) * 100.0 / purchased,
        2
    ) AS purchase_to_approval_dropoff,

    ROUND(
        (approved - shipped) * 100.0 / approved,
        2
    ) AS approval_to_shipping_dropoff,

    ROUND(
        (shipped - delivered) * 100.0 / shipped,
        2
    ) AS shipping_to_delivery_dropoff

FROM funnel;


-- ====================================
-- DELIVERY SPEED
-- ====================================

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS avg_delivery_days

FROM orders

WHERE order_delivered_customer_date IS NOT NULL;


-- ====================================
-- APPROVAL / SHIPPING / DELIVERY TIMES
-- ====================================

SELECT

    ROUND(
        AVG(
            DATEDIFF(
                order_approved_at,
                order_purchase_timestamp
            )
        ),
        2
    ) AS avg_days_to_approve,

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_carrier_date,
                order_approved_at
            )
        ),
        2
    ) AS avg_days_to_ship,

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_delivered_carrier_date
            )
        ),
        2
    ) AS avg_days_to_deliver

FROM orders;


-- ====================================
-- LATE DELIVERY RATE
-- ====================================

SELECT

    COUNT(*) AS late_orders,

    ROUND(
        COUNT(*) * 100.0 /
        (
            SELECT COUNT(*)
            FROM orders
            WHERE order_delivered_customer_date IS NOT NULL
        ),
        2
    ) AS late_delivery_rate

FROM orders

WHERE order_delivered_customer_date >
      order_estimated_delivery_date;


-- ====================================
-- CANCELLATION RATE
-- ====================================

SELECT

    COUNT(*) AS cancelled_orders,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS cancellation_rate

FROM orders

WHERE order_status = 'canceled';


-- ====================================
-- MONTHLY ORDER TREND
-- ====================================

SELECT

    DATE_FORMAT(
        order_purchase_timestamp,
        '%Y-%m'
    ) AS order_month,

    COUNT(*) AS total_orders

FROM orders

GROUP BY order_month

ORDER BY order_month;


-- ====================================
-- MONTHLY REVENUE TREND
-- ====================================

SELECT

    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS order_month,

    ROUND(
        SUM(i.price),
        2
    ) AS revenue

FROM orders o

JOIN items i
    ON o.order_id = i.order_id

GROUP BY order_month

ORDER BY order_month;
