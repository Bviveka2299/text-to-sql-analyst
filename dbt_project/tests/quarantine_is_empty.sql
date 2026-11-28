{{ config(severity='warn') }}

select 'orders'   as source, failed_checks from {{ ref('quarantine_orders') }}
union all
select 'reviews'  as source, failed_checks from {{ ref('quarantine_order_reviews') }}
union all
select 'payments' as source, failed_checks from {{ ref('quarantine_order_payments') }}
