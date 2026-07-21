# E-Commerce Marketplace Analysis

## Project Overview

This project analyzes a Brazilian e-commerce marketplace dataset to understand customer behavior, operational performance, seller quality, and product performance.

The goal was to move beyond descriptive reporting and answer business questions related to retention, fulfillment efficiency, marketplace reliability, and customer satisfaction.

The analysis was conducted using MySQL and focuses on four core areas:

* Order Funnel & Fulfillment Performance
* Customer Behavior & Retention
* Seller Performance & Reliability
* Product Quality & Customer Satisfaction

---

## Business Questions

### Order Operations

* What percentage of orders successfully move through the fulfillment funnel?
* Where do customers drop out of the order lifecycle?
* How often are orders delivered late?
* What is the overall cancellation rate?

### Customer Behavior

* How many customers become repeat buyers?
* How long does it take customers to make a second purchase?
* What is the average time between purchases?
* How well does the marketplace retain customers over time?

### Seller Performance

* Which sellers generate the most revenue?
* Which sellers have the highest operational risk?
* Which sellers provide the best customer experience?
* Can sellers be segmented based on performance?

### Product Performance

* Which products generate the most revenue?
* Which products receive the highest number of complaints?
* Which product categories perform best?
* How do delivery delays affect customer satisfaction?

---

## Dataset

Dataset: Brazilian E-Commerce Public Dataset by Olist

Source:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The dataset contains information on:

* Customers
* Orders
* Payments
* Reviews
* Sellers
* Products
* Product Categories

---

## Tools & Techniques

### SQL

* Common Table Expressions (CTEs)
* Window Functions
* Aggregations
* Views
* Ranking Functions

### Functions Used

* ROW_NUMBER()
* LAG()
* NTILE()
* DATEDIFF()
* TIMESTAMPDIFF()
* DATE_FORMAT()
* CASE WHEN

### Analytical Techniques

* Funnel Analysis
* Cohort Analysis
* Retention Analysis
* Customer Segmentation
* Seller Segmentation
* Product Quality Analysis

---

## Project Structure

```text
sql/

01_schema.sql
02_order_funnel.sql
03_customer_analysis.sql
04_retention_cohort.sql
05_seller_analysis.sql
06_product_analysis.sql
```

### 01_schema.sql

Creates all marketplace tables and relationships.

### 02_order_funnel.sql

Analyzes:

* Funnel conversion rates
* Funnel drop-offs
* Delivery speed
* Cancellation rate
* Monthly order trends
* Monthly revenue trends

### 03_customer_analysis.sql

Analyzes:

* Repeat purchase behavior
* Purchase frequency
* Customer lifetime value
* Average days between purchases
* Time to second purchase

### 04_retention_cohort.sql

Analyzes:

* Monthly customer cohorts
* Retention rates
* Customer return behavior over time

### 05_seller_analysis.sql

Analyzes:

* Seller revenue
* Seller order volume
* Seller ratings
* Seller reliability
* Seller segmentation
* Seller health score

### 06_product_analysis.sql

Analyzes:

* Product revenue
* Product ratings
* Complaint rates
* Category performance
* Product segmentation
* Product health score

---

## Key Findings

### Customer Retention

* Most customers purchase only once.
* Repeat purchase behavior represents a small portion of the customer base.
* Retention declines significantly after the first purchase period.

### Fulfillment Performance

* The majority of orders successfully move through the fulfillment funnel.
* Late deliveries represent a measurable operational risk.
* Delivery performance has a noticeable impact on customer satisfaction.

### Seller Performance

* Revenue distribution is highly concentrated among a subset of sellers.
* High-volume sellers are not always the highest-rated sellers.
* Reliability metrics reveal significant differences in operational performance across sellers.

### Product Quality

* Some products generate disproportionately high complaint rates.
* Product categories vary significantly in customer satisfaction levels.
* Delivery delays are associated with lower review scores.

---

## Business Recommendations

### Improve Customer Retention

* Launch targeted campaigns for first-time buyers.
* Incentivize second purchases through discounts or loyalty programs.
* Monitor retention rates by acquisition cohort.

### Improve Operational Performance

* Investigate root causes of delayed deliveries.
* Introduce seller-level delivery performance monitoring.
* Escalate high-risk fulfillment issues proactively.

### Seller Management

* Reward highly reliable sellers.
* Monitor high-volume sellers with poor ratings.
* Create operational improvement programs for high-risk sellers.

### Product Quality Management

* Review products with consistently high complaint rates.
* Investigate categories with low customer satisfaction.
* Use review data to identify recurring quality issues.

---

## Future Improvements

Potential extensions for this project include:

* Interactive Power BI dashboard
* Customer RFM segmentation
* Predictive churn modeling
* Seller performance forecasting
* Product recommendation analysis
* Geographic performance analysis

---

## Author

Business Operations / Business Analytics Portfolio Project

Focus Areas:

* SQL Analytics
* Customer Retention
* Marketplace Operations
* Seller Performance
* Product Quality Analysis
