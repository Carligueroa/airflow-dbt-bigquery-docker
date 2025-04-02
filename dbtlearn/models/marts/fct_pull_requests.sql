with raw_data as (

    select * from {{ ref('stg_pull_requests') }}

),

renamed as (

    select
        pull_request_id,
        user_id,
        repository_id,
        repository_full_name,
        created_at
    from raw_data

)
select * from renamed