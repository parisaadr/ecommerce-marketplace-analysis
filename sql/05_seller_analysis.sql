-- =====================================================
-- SELLER ANALYSIS
-- =====================================================


-- ==========================================
-- SELLER REVENUE
-- ==========================================

SELECT

    seller_id,

    ROUND(
        SUM(price),
        2
    ) AS total_revenue

FROM items

GROUP BY seller_id

ORDER BY total_revenue DESC;


-- ==========================================
-- REVENUE DISTRIBUTION
-- ==========================================

CREATE OR REPLACE VIEW seller_revenue_view AS

SELECT

    seller_id,

    SUM(price) AS total_revenue

FROM items

GROUP BY seller_id;


SELECT

    MIN(total_revenue) AS min_revenue,

    MAX(total_revenue) AS max_revenue,

    ROUND(
        AVG(total_revenue),
        2
    ) AS avg_revenue

FROM seller_revenue_view;


-- ==========================================
-- REVENUE SEGMENTATION
-- ==========================================

WITH revenue_segments AS (

    SELECT

        seller_id,

        total_revenue,

        NTILE(4)
            OVER (
                ORDER BY total_revenue
            ) AS revenue_quartile

    FROM seller_revenue_view
)

SELECT

    seller_id,

    total_revenue,

    CASE

        WHEN revenue_quartile = 4
            THEN 'Top Seller'

        WHEN revenue_quartile = 3
            THEN 'Mid-High Seller'

        WHEN revenue_quartile = 2
            THEN 'Mid-Low Seller'

        ELSE 'Low Seller'

    END AS revenue_segment

FROM revenue_segments;


-- ==========================================
-- ORDER VOLUME
-- ==========================================

CREATE OR REPLACE VIEW seller_volume_view AS

SELECT

    seller_id,

    COUNT(DISTINCT order_id) AS order_volume

FROM items

GROUP BY seller_id;


SELECT

    MIN(order_volume) AS min_volume,

    MAX(order_volume) AS max_volume,

    ROUND(
        AVG(order_volume),
        2
    ) AS avg_volume

FROM seller_volume_view;


-- ==========================================
-- VOLUME SEGMENTATION
-- ==========================================

WITH volume_segments AS (

    SELECT

        seller_id,

        order_volume,

        NTILE(4)
            OVER (
                ORDER BY order_volume
            ) AS volume_quartile

    FROM seller_volume_view
)

SELECT

    seller_id,

    order_volume,

    CASE

        WHEN volume_quartile = 4
            THEN 'Top Volume Seller'

        WHEN volume_quartile = 3
            THEN 'Mid-High Volume Seller'

        WHEN volume_quartile = 2
            THEN 'Mid-Low Volume Seller'

        ELSE 'Low Volume Seller'

    END AS volume_segment

FROM volume_segments;


-- ==========================================
-- SELLER REVIEW PERFORMANCE
-- ==========================================

CREATE OR REPLACE VIEW seller_rating_view AS

SELECT

    i.seller_id,

    COUNT(DISTINCT i.order_id) AS reviewed_orders,

    ROUND(
        AVG(r.review_score),
        2
    ) AS avg_rating

FROM items i

JOIN reviews r
    ON i.order_id = r.order_id

GROUP BY i.seller_id;


SELECT *

FROM seller_rating_view

ORDER BY avg_rating DESC;


-- ==========================================
-- SELLER CANCELLATION RATE
-- ==========================================

SELECT

    i.seller_id,

    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'canceled'
            THEN o.order_id
        END
    ) AS cancelled_orders,

    COUNT(
        DISTINCT o.order_id
    ) AS total_orders,

    ROUND(

        COUNT(
            DISTINCT CASE
                WHEN o.order_status = 'canceled'
                THEN o.order_id
            END
        ) * 100.0

        /

        COUNT(
            DISTINCT o.order_id
        ),

        2

    ) AS cancellation_rate

FROM orders o

JOIN items i
    ON o.order_id = i.order_id

GROUP BY i.seller_id

ORDER BY cancellation_rate DESC;


-- ==========================================
-- SELLER LATE DELIVERY RATE
-- ==========================================

SELECT

    i.seller_id,

    COUNT(
        DISTINCT CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN o.order_id
        END
    ) AS late_orders,

    COUNT(
        DISTINCT o.order_id
    ) AS total_orders,

    ROUND(

        COUNT(
            DISTINCT CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN o.order_id
            END
        ) * 100.0

        /

        COUNT(
            DISTINCT o.order_id
        ),

        2

    ) AS late_delivery_rate

FROM orders o

JOIN items i
    ON o.order_id = i.order_id

GROUP BY i.seller_id

ORDER BY late_delivery_rate DESC;


-- ==========================================
-- SELLER RELIABILITY VIEW
-- ==========================================

CREATE OR REPLACE VIEW seller_reliability_view AS

SELECT

    i.seller_id,

    ROUND(

        COUNT(
            DISTINCT CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN o.order_id
            END
        ) * 100.0

        /

        COUNT(
            DISTINCT o.order_id
        ),

        2

    ) AS late_delivery_rate,

    ROUND(

        COUNT(
            DISTINCT CASE
                WHEN o.order_status = 'canceled'
                THEN o.order_id
            END
        ) * 100.0

        /

        COUNT(
            DISTINCT o.order_id
        ),

        2

    ) AS cancellation_rate

FROM orders o

JOIN items i
    ON o.order_id = i.order_id

GROUP BY i.seller_id;


-- ==========================================
-- RELIABILITY SEGMENTATION
-- ==========================================

WITH reliability_segments AS (

    SELECT

        seller_id,

        late_delivery_rate,

        cancellation_rate,

        NTILE(4)
            OVER (
                ORDER BY late_delivery_rate
            ) AS late_quartile,

        NTILE(4)
            OVER (
                ORDER BY cancellation_rate
            ) AS cancellation_quartile

    FROM seller_reliability_view
)

SELECT

    seller_id,

    late_delivery_rate,

    cancellation_rate,

    CASE

        WHEN late_quartile = 1
             AND cancellation_quartile = 1
        THEN 'Highly Reliable'

        WHEN late_quartile <= 2
             AND cancellation_quartile <= 2
        THEN 'Moderately Reliable'

        ELSE 'High Risk Seller'

    END AS reliability_segment

FROM reliability_segments;


-- ==========================================
-- SELLER QUALITY SEGMENTATION
-- ==========================================

WITH seller_quality AS (

    SELECT

        seller_id,

        reviewed_orders,

        avg_rating,

        NTILE(5)
            OVER (
                ORDER BY reviewed_orders
            ) AS order_frequency

    FROM seller_rating_view
)

SELECT

    seller_id,

    reviewed_orders,

    avg_rating,

    CASE

        WHEN order_frequency >= 4
             AND avg_rating >= 4
        THEN 'GOLD'

        WHEN order_frequency >= 3
             AND avg_rating >= 3
        THEN 'SILVER'

        WHEN order_frequency >= 2
             AND avg_rating >= 3
        THEN 'STABLE LOW VOLUME'

        WHEN order_frequency >= 4
             AND avg_rating <= 2
        THEN 'HIGH VOLUME LOW QUALITY'

        WHEN order_frequency <= 2
             AND avg_rating >= 4
        THEN 'LOW VOLUME HIGH QUALITY'

        ELSE 'LOW PERFORMANCE'

    END AS seller_segment

FROM seller_quality;


-- ==========================================
-- COMBINED SELLER SCORECARD
-- ==========================================

WITH revenue_rank AS (

    SELECT

        seller_id,

        NTILE(4)
            OVER (
                ORDER BY total_revenue
            ) AS revenue_score

    FROM seller_revenue_view
),

rating_rank AS (

    SELECT

        seller_id,

        NTILE(4)
            OVER (
                ORDER BY avg_rating
            ) AS rating_score

    FROM seller_rating_view
),

reliability_rank AS (

    SELECT

        seller_id,

        NTILE(4)
            OVER (
                ORDER BY (
                    late_delivery_rate +
                    cancellation_rate
                ) DESC
            ) AS risk_score

    FROM seller_reliability_view
)

SELECT

    r.seller_id,

    revenue_score,

    rating_score,

    risk_score,

    revenue_score +
    rating_score -
    risk_score AS seller_health_score

FROM revenue_rank r

JOIN rating_rank rt
    ON r.seller_id = rt.seller_id

JOIN reliability_rank rr
    ON r.seller_id = rr.seller_id

ORDER BY seller_health_score DESC;
