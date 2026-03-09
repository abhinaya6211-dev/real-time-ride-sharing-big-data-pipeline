-- Create database and schema
-- Setup
CREATE DATABASE nyc_taxi_db;
USE DATABASE nyc_taxi_db;
CREATE SCHEMA taxi_analytics;
USE SCHEMA taxi_analytics;

-- Hourly KPIs table
CREATE TABLE hourly_kpis (
    pickup_hour INT,
    trip_count INT,
    avg_fare FLOAT,
    total_revenue FLOAT,
    avg_distance FLOAT,
    avg_speed_mph FLOAT,
    is_peak_hour STRING
);

-- Zone KPIs table
CREATE TABLE zone_kpis (
    pulocationid INT,
    trip_count INT,
    total_revenue FLOAT,
    avg_fare_per_mile FLOAT,
    avg_distance FLOAT
);

-- Peak vs Off-Peak table
CREATE TABLE peak_analysis (
    is_peak_hour STRING,
    is_weekend STRING,
    trip_count INT,
    avg_fare FLOAT,
    total_revenue FLOAT,
    avg_duration_min FLOAT
);

-- Payment Analysis table
CREATE TABLE payment_analysis (
    payment_type INT,
    trip_count INT,
    avg_fare_per_mile FLOAT,
    avg_tip FLOAT,
    total_revenue FLOAT
);


USE DATABASE nyc_taxi_db;
USE SCHEMA taxi_analytics;

-- ======================================
-- Query 1: Peak Hour Revenue Ranking
-- Identify which hours generate the highest revenue
-- ======================================

SELECT 
    pickup_hour,
    is_peak_hour,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM hourly_kpis
ORDER BY revenue_rank;


-- ======================================
-- Query 2: Peak vs Off-Peak Performance
-- Compare trip volume and revenue
-- ======================================

SELECT 
    is_peak_hour,
    SUM(trip_count) AS total_trips,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(avg_fare), 2) AS avg_fare
FROM peak_analysis
GROUP BY is_peak_hour
ORDER BY total_revenue DESC;


-- ======================================
-- Query 3: Top 10 Revenue Generating Zones
-- Identify high-performing taxi zones
-- ======================================

SELECT
    pulocationid,
    trip_count AS total_trips,
    total_revenue,
    avg_fare_per_mile
FROM zone_kpis
ORDER BY total_revenue DESC
LIMIT 10;


-- ======================================
-- Query 4: Identify Peak Demand Hours
-- Find hours with highest trip volume
-- ======================================

SELECT
    pickup_hour,
    SUM(trip_count) AS total_trips,
    ROUND(SUM(total_revenue),2) AS total_revenue,
    ROUND(AVG(avg_fare),2) AS avg_fare
FROM hourly_kpis
GROUP BY pickup_hour
ORDER BY total_trips DESC
LIMIT 5;


-- ======================================
-- Query 5: Payment Type Performance
-- Compare revenue and tipping behavior
-- ======================================

SELECT
    payment_type,
    SUM(trip_count) AS total_trips,
    ROUND(AVG(avg_tip),2) AS avg_tip,
    ROUND(SUM(total_revenue),2) AS total_revenue
FROM payment_analysis
GROUP BY payment_type
ORDER BY total_revenue DESC;


-- ======================================
-- Query 6: Rank Zones by Revenue
-- ======================================

SELECT
    pulocationid,
    total_revenue AS revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM zone_kpis
ORDER BY revenue_rank
LIMIT 10;


-- ======================================
-- Query 7: Revenue Contribution by Zone
-- Advanced window analytics
-- ======================================

SELECT
    pulocationid,
    total_revenue,
    ROUND(
        total_revenue / SUM(total_revenue) OVER () * 100,
        2
    ) AS revenue_share_pct
FROM zone_kpis
ORDER BY revenue_share_pct DESC
LIMIT 10;
