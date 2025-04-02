with source as (

    select * from {{ source('data8', 'repositories') }}

),

renamed as (

    select
        id as repository_original_id,
        url as api_endpoint_url,
        {{ dbt_utils.generate_surrogate_key(['full_name'])}} as repository_id,
        name as repository_name,
        owner,
        git_url,
        full_name as repository_full_name
    from source

)

select * from renamed