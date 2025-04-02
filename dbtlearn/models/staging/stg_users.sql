with source as (

    select * from {{ source('data8', 'users') }}

),

renamed as (

    select
        id as user_id,
        url as api_endpoint_url,
        type,
        login,
        html_url as user_url
    from source

)

select * from renamed