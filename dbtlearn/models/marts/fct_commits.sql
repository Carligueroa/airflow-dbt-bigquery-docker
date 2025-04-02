with raw_data as (

    select * from {{ ref('stg_commits') }}

),

renamed as (

    select
        commit_id,
        author_name,
        author_email,
        created_at,
        repository_id,
        repository_full_name
    from raw_data

)
select * from renamed