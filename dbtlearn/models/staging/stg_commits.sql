with source as (

    select * from {{ source('data8', 'commits') }}

),

renamed as (

    select
        sha as commit_id,
        JSON_EXTRACT_SCALAR(commit, '$.author.name') as author_name,
        JSON_EXTRACT_SCALAR(commit, '$.author.email') as author_email,
        url as api_endpoint_url,
        committer,
        created_at,
        {{ dbt_utils.generate_surrogate_key(['repository'])}} as repository_id,
        repository as repository_full_name

    from source

)

select * from renamed