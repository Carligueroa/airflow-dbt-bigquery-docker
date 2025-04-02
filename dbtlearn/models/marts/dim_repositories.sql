with raw_data as (

    select * from {{ ref('stg_repositories') }}

),

renamed as (

    select
        repository_id,
        repository_full_name
    from raw_data

)
select * from renamed