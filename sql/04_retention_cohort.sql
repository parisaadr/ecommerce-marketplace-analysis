-- =====================================================
-- RETENTION & COHORT ANALYSIS
-- =====================================================


-- ==========================================
-- CUSTOMER COHORT CREATION
-- ==========================================

WITH first_purchase AS (

    SELECT

        c.customer_unique_id,

        MIN(
            o.order_purchase_timestamp
        ) AS first_purchase_date

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    GROUP BY c.customer_unique_id
),

cohorts AS (

    SELECT

        customer_unique_id,

        DATE_FORMAT(
            first_purchase_date,
            '%Y-%m'
        ) AS cohort_month

    FROM first_purchase
),

customer_orders AS (

    SELECT

        c.customer_unique_id,

        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id
),

cohort_data AS (

    SELECT

        co.customer_unique_id,

        co.cohort_month,

        ord.order_month,

        TIMESTAMPDIFF(
            MONTH,

            STR_TO_DATE(
                co.cohort_month,
                '%Y-%m'
            ),

            STR_TO_DATE(
                ord.order_month,
                '%Y-%m'
            )
        ) AS month_index

    FROM cohorts co

    JOIN customer_orders ord
        ON co.customer_unique_id =
           ord.customer_unique_id
)

SELECT

    cohort_month,

    month_index,

    COUNT(
        DISTINCT customer_unique_id
    ) AS active_customers

FROM cohort_data

GROUP BY
    cohort_month,
    month_index

ORDER BY
    cohort_month,
    month_index;


-- ==========================================
-- RETENTION RATE (%)
-- ==========================================

WITH first_purchase AS (

    SELECT

        c.customer_unique_id,

        MIN(
            o.order_purchase_timestamp
        ) AS first_purchase_date

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    GROUP BY c.customer_unique_id
),

cohorts AS (

    SELECT

        customer_unique_id,

        DATE_FORMAT(
            first_purchase_date,
            '%Y-%m'
        ) AS cohort_month

    FROM first_purchase
),

customer_orders AS (

    SELECT

        c.customer_unique_id,

        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id
),

cohort_data AS (

    SELECT

        co.customer_unique_id,

        co.cohort_month,

        ord.order_month,

        TIMESTAMPDIFF(
            MONTH,

            STR_TO_DATE(
                co.cohort_month,
                '%Y-%m'
            ),

            STR_TO_DATE(
                ord.order_month,
                '%Y-%m'
            )
        ) AS month_index

    FROM cohorts co

    JOIN customer_orders ord
        ON co.customer_unique_id =
           ord.customer_unique_id
),

cohort_size AS (

    SELECT

        cohort_month,

        COUNT(
            DISTINCT customer_unique_id
        ) AS cohort_customers

    FROM cohort_data

    WHERE month_index = 0

    GROUP BY cohort_month
)

SELECT

    cd.cohort_month,

    cd.month_index,

    COUNT(
        DISTINCT cd.customer_unique_id
    ) AS active_customers,

    cs.cohort_customers,

    ROUND(
        COUNT(
            DISTINCT cd.customer_unique_id
        ) * 100.0
        / cs.cohort_customers,
        2
    ) AS retention_rate

FROM cohort_data cd

JOIN cohort_size cs
    ON cd.cohort_month =
       cs.cohort_month

GROUP BY

    cd.cohort_month,

    cd.month_index,

    cs.cohort_customers

ORDER BY

    cd.cohort_month,

    cd.month_index;


-- ==========================================
-- MONTH 1 RETENTION
-- ==========================================

WITH first_purchase AS (

    SELECT

        c.customer_unique_id,

        MIN(
            o.order_purchase_timestamp
        ) AS first_purchase_date

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    GROUP BY c.customer_unique_id
),

cohorts AS (

    SELECT

        customer_unique_id,

        DATE_FORMAT(
            first_purchase_date,
            '%Y-%m'
        ) AS cohort_month

    FROM first_purchase
),

customer_orders AS (

    SELECT

        c.customer_unique_id,

        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id
),

cohort_data AS (

    SELECT

        co.customer_unique_id,

        co.cohort_month,

        TIMESTAMPDIFF(
            MONTH,

            STR_TO_DATE(
                co.cohort_month,
                '%Y-%m'
            ),

            STR_TO_DATE(
                ord.order_month,
                '%Y-%m'
            )
        ) AS month_index

    FROM cohorts co

    JOIN customer_orders ord
        ON co.customer_unique_id =
           ord.customer_unique_id
)

SELECT

    cohort_month,

    COUNT(
        DISTINCT CASE
            WHEN month_index = 1
            THEN customer_unique_id
        END
    ) AS month_1_returning_customers

FROM cohort_data

GROUP BY cohort_month

ORDER BY cohort_month;
