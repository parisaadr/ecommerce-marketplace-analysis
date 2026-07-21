-- =====================================================
-- PRODUCT ANALYSIS
-- =====================================================


-- ==========================================
-- PRODUCT REVENUE
-- ==========================================

SELECT

    i.product_id,

    ROUND(
        SUM(i.price),
        2
    ) AS total_revenue,

    COUNT(
        DISTINCT i.order_id
    ) AS total_orders

FROM items i

GROUP BY i.product_id

ORDER BY total_revenue DESC;


-- ==========================================
-- TOP PRODUCTS BY ORDER VOLUME
-- ==========================================

SELECT

    product_id,

    COUNT(
        DISTINCT order_id
    ) AS total_orders

FROM items

GROUP BY product_id

ORDER BY total_orders DESC;


-- ==========================================
-- PRODUCT REVIEW PERFORMANCE
-- ==========================================

CREATE OR REPLACE VIEW product_rating_view AS

SELECT

    i.product_id,

    COUNT(
        DISTINCT i.order_id
    ) AS reviewed_orders,

    ROUND(
        AVG(r.review_score),
        2
    ) AS avg_rating

FROM items i

JOIN reviews r
    ON i.order_id = r.order_id

GROUP BY i.product_id;


SELECT *

FROM product_rating_view

ORDER BY avg_rating DESC;


-- ==========================================
-- PRODUCT COMPLAINT RATE
-- ==========================================

WITH product_scores AS (

    SELECT

        i.product_id,

        i.order_id,

        r.review_score

    FROM items i

    JOIN reviews r
        ON i.order_id = r.order_id
)

SELECT

    product_id,

    COUNT(
        DISTINCT CASE
            WHEN review_score <= 2
            THEN order_id
        END
    ) AS complaint_count,

    COUNT(
        DISTINCT order_id
    ) AS total_reviews,

    ROUND(

        COUNT(
            DISTINCT CASE
                WHEN review_score <= 2
                THEN order_id
            END
        ) * 100.0

        /

        COUNT(
            DISTINCT order_id
        ),

        2

    ) AS complaint_rate

FROM product_scores

GROUP BY product_id

HAVING total_reviews >= 5

ORDER BY complaint_rate DESC;


-- ==========================================
-- PRODUCT QUALITY SEGMENTATION
-- ==========================================

WITH product_quality AS (

    SELECT

        product_id,

        reviewed_orders,

        avg_rating,

        NTILE(4)
            OVER (
                ORDER BY reviewed_orders
            ) AS volume_quartile

    FROM product_rating_view
)

SELECT

    product_id,

    reviewed_orders,

    avg_rating,

    CASE

        WHEN volume_quartile >= 3
             AND avg_rating >= 4
        THEN 'HIGH DEMAND HIGH QUALITY'

        WHEN volume_quartile >= 3
             AND avg_rating < 3
        THEN 'HIGH DEMAND LOW QUALITY'

        WHEN volume_quartile <= 2
             AND avg_rating >= 4
        THEN 'NICHE HIGH QUALITY'

        ELSE 'LOW PERFORMANCE'

    END AS product_segment

FROM product_quality;


-- ==========================================
-- CATEGORY PERFORMANCE
-- ==========================================

SELECT

    COALESCE(
        c.product_category_name_english,
        p.product_category_name
    ) AS category_name,

    COUNT(
        DISTINCT i.order_id
    ) AS total_orders,

    ROUND(
        SUM(i.price),
        2
    ) AS total_revenue

FROM items i

JOIN products p
    ON i.product_id = p.product_id

LEFT JOIN category c
    ON p.product_category_name =
       c.product_category_name

GROUP BY category_name

ORDER BY total_revenue DESC;


-- ==========================================
-- CATEGORY REVIEW PERFORMANCE
-- ==========================================

SELECT

    COALESCE(
        c.product_category_name_english,
        p.product_category_name
    ) AS category_name,

    COUNT(
        DISTINCT i.order_id
    ) AS reviewed_orders,

    ROUND(
        AVG(r.review_score),
        2
    ) AS avg_rating

FROM items i

JOIN products p
    ON i.product_id = p.product_id

LEFT JOIN category c
    ON p.product_category_name =
       c.product_category_name

JOIN reviews r
    ON i.order_id = r.order_id

GROUP BY category_name

ORDER BY avg_rating DESC;


-- ==========================================
-- CATEGORY COMPLAINT RATE
-- ==========================================

SELECT

    COALESCE(
        c.product_category_name_english,
        p.product_category_name
    ) AS category_name,

    COUNT(
        DISTINCT CASE
            WHEN r.review_score <= 2
            THEN i.order_id
        END
    ) AS complaints,

    COUNT(
        DISTINCT i.order_id
    ) AS total_reviews,

    ROUND(

        COUNT(
            DISTINCT CASE
                WHEN r.review_score <= 2
                THEN i.order_id
            END
        ) * 100.0

        /

        COUNT(
            DISTINCT i.order_id
        ),

        2

    ) AS complaint_rate

FROM items i

JOIN products p
    ON i.product_id = p.product_id

LEFT JOIN category c
    ON p.product_category_name =
       c.product_category_name

JOIN reviews r
    ON i.order_id = r.order_id

GROUP BY category_name

HAVING total_reviews >= 20

ORDER BY complaint_rate DESC;


-- ==========================================
-- DELIVERY DELAY IMPACT ON REVIEWS
-- ==========================================

SELECT

    CASE

        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late Delivery'

        ELSE 'On-Time Delivery'

    END AS delivery_status,

    ROUND(
        AVG(r.review_score),
        2
    ) AS avg_review_score,

    COUNT(*) AS review_count

FROM orders o

JOIN reviews r
    ON o.order_id = r.order_id

GROUP BY delivery_status;


-- ==========================================
-- LOW REVIEW PRODUCTS
-- ==========================================

SELECT

    i.product_id,

    ROUND(
        AVG(r.review_score),
        2
    ) AS avg_rating,

    COUNT(
        DISTINCT i.order_id
    ) AS reviewed_orders

FROM items i

JOIN reviews r
    ON i.order_id = r.order_id

GROUP BY i.product_id

HAVING reviewed_orders >= 10

ORDER BY avg_rating ASC;


-- ==========================================
-- PRODUCT HEALTH SCORECARD
-- ==========================================

WITH revenue_rank AS (

    SELECT

        product_id,

        NTILE(4)
            OVER (
                ORDER BY SUM(price)
            ) AS revenue_score

    FROM items

    GROUP BY product_id
),

rating_rank AS (

    SELECT

        product_id,

        NTILE(4)
            OVER (
                ORDER BY avg_rating
            ) AS rating_score

    FROM product_rating_view
),

complaint_rank AS (

    SELECT

        product_id,

        NTILE(4)
            OVER (
                ORDER BY complaint_rate DESC
            ) AS complaint_risk

    FROM (

        SELECT

            i.product_id,

            ROUND(

                COUNT(
                    DISTINCT CASE
                        WHEN r.review_score <= 2
                        THEN i.order_id
                    END
                ) * 100.0

                /

                COUNT(
                    DISTINCT i.order_id
                ),

                2

            ) AS complaint_rate

        FROM items i

        JOIN reviews r
            ON i.order_id = r.order_id

        GROUP BY i.product_id

    ) complaints
)

SELECT

    r.product_id,

    revenue_score,

    rating_score,

    complaint_risk,

    revenue_score +
    rating_score -
    complaint_risk AS product_health_score

FROM revenue_rank r

JOIN rating_rank rt
    ON r.product_id = rt.product_id

JOIN complaint_rank cr
    ON r.product_id = cr.product_id

ORDER BY product_health_score DESC;
