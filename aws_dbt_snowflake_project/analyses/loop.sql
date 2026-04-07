{% set cols = ['NIGHTS_BOOKED', 'BOOKING_ID', 'TOTAL_AMOUNT'] %}

SELECT 
{% for col in cols %}
{{col}}
{% if not loop.last %},
{% endif %}
{% endfor %}
FROM {{ref('bronze_bookings')}}