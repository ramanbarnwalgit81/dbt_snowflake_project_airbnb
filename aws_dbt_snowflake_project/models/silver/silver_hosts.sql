{{config(materialized='incremental', unique_key='host_id')}}

SELECT 
    host_id,
    REPLACE(host_name, ' ', '_') as host_name,
    host_since,
    is_superhost,
    CASE 
        WHEN response_rate > 95 THEN 'VERY_GOOD'
        WHEN response_rate > 80 THEN 'GOOD'
        WHEN response_rate > 60 THEN 'FAIR'
        ELSE 'POOR'
    END as response_rate_quality,
    created_at
    FROM {{ ref('bronze_hosts') }}
    