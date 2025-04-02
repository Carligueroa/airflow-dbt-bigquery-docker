with source as (

    select * from {{ source('data8', 'pull_requests') }}

),

renamed as (

    select
        id as pull_request_id,
        url as api_endpoint_url,
        user,
        JSON_EXTRACT_SCALAR(user, '$.id') as user_id,
        JSON_EXTRACT_SCALAR(user, '$.login') as user_name,
        title,
        created_at,
        {{ dbt_utils.generate_surrogate_key(['repository'])}} as repository_id,
        repository as repository_full_name,
        updated_at
    from source

)

select * from renamed