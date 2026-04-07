{{config(materialized='incremental', unique_key='listing_id')}}

SELECT 
    listing_id,
    host_id,
    property_type,
    room_type,
    city,
    country,
    Accommodates,
    bedrooms,
    bathrooms,
    price_per_night,
    created_at,
    {{ tag('CAST(price_per_night as int)') }} as price_per_night_tag
FROM {{ ref('bronze_listings') }}