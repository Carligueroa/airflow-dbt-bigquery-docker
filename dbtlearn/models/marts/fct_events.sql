with raw_data as (

    select * from {{ ref('stg_events') }}

),

renamed as (

    select
        repository_id,
        repository_full_name,
        event_type,
        created_at
    from raw_data

)
select * from raw_data