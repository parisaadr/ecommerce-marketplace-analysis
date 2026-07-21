-- =====================================================
-- CUSTOMER ANALYSIS
-- =====================================================
-- NOTE:
-- customer_id is not the true customer identifier.
-- customer_unique_id represents the actual customer.
-- =====================================================


-- ==========================================
-- TOTAL ORDERS VS UNIQUE CUSTOMERS
-- ==========================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id;


-- ==========================================
-- ONE-TIME VS REPEAT CUSTOMERS
-- ==========================================

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders

    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id

    GROUP BY c.customer_unique_id
)

SELECT

    COUNT(
        CASE
            WHEN total_orders = 1
            THEN 1
        END
    ) AS one_time_buyers,

    COUNT(
        CASE
            WHEN total_orders > 1
            THEN 1
        END
    ) AS repeat_buyers,

    ROUND(
        COUNT(
            CASE
                WHEN total_orders = 1
                THEN 1
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS one_time_buyer_rate,

    ROUND(
        COUNT(
            CASE
                WHEN total_orders > 1
                THEN 1
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS repeat_buyer_rate

FROM customer_orders;


-- ==========================================
-- PURCHASE FREQUENCY DISTRIBUTION
-- ==========================================

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders

    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id

    GROUP BY c.customer_unique_id
)

SELECT
    total_orders,
    COUNT(*) AS customer_count

FROM customer_orders

GROUP BY total_orders

ORDER BY total_orders;


-- ==========================================
-- AVERAGE DAYS BETWEEN PURCHASES
-- ==========================================

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,

        o.order_purchase_timestamp,

        LAG(o.order_purchase_timestamp)
            OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY o.order_purchase_timestamp
            ) AS previous_order_date

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id
)

SELECT

    ROUND(
        AVG(
            DATEDIFF(
                order_purchase_timestamp,
                previous_order_date
            )
        ),
        2
    ) AS avg_days_between_orders

FROM customer_orders

WHERE previous_order_date IS NOT NULL;


-- ==========================================
-- DAYS TO SECOND PURCHASE
-- ==========================================

WITH ranked_orders AS (

    SELECT

        c.customer_unique_id,

        o.order_purchase_timestamp,

        ROW_NUMBER()
            OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY o.order_purchase_timestamp
            ) AS purchase_number

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id
),

first_second_purchase AS (

    SELECT

        customer_unique_id,

        MAX(
            CASE
                WHEN purchase_number = 1
                THEN order_purchase_timestamp
            END
        ) AS first_purchase,

        MAX(
            CASE
                WHEN purchase_number = 2
                THEN order_purchase_timestamp
            END
        ) AS second_purchase

    FROM ranked_orders

    GROUP BY customer_unique_id
)

SELECT

    ROUND(
        AVG(
            DATEDIFF(
                second_purchase,
                first_purchase
            )
        ),
        2
    ) AS avg_days_to_second_purchase

FROM first_second_purchase

WHERE second_purchase IS NOT NULL;


-- ==========================================
-- CUSTOMER LIFETIME VALUE (REVENUE)
-- ==========================================

WITH customer_revenue AS (

    SELECT

        c.customer_unique_id,

        ROUND(
            SUM(p.payment_value),
            2
        ) AS total_customer_revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN payments p
        ON o.order_id = p.order_id

    GROUP BY c.customer_unique_id
)

SELECT

    ROUND(
        AVG(total_customer_revenue),
        2
    ) AS avg_customer_lifetime_value,

    MIN(total_customer_revenue) AS min_customer_value,

    MAX(total_customer_revenue) AS max_customer_value

FROM customer_revenue;


-- ==========================================
-- TOP CUSTOMERS BY REVENUE
-- ==========================================

SELECT

    c.customer_unique_id,

    ROUND(
        SUM(p.payment_value),
        2
    ) AS customer_revenue

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN payments p
    ON o.order_id = p.order_id

GROUP BY c.customer_unique_id

ORDER BY customer_revenue DESC

LIMIT 20;
