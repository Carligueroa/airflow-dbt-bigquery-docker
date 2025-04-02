with raw_data as (

    select * from {{ ref('stg_users') }}

),

renamed as (

    select
        user_id,
        login,
        user_url
    from raw_data

)
select * from renamed