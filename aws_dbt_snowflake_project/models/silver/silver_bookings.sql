{{config(materialized='incremental', unique_key='booking_id')}}

SELECT 
    booking_id,
    booking_date,
    listing_id,
    {{ multiply('nights_booked', 'booking_amount', 2 ) }} as total_amount,
    cleaning_fee,
    service_fee,
    booking_status,
    created_at
    
FROM {{ ref('bronze_bookings') }}