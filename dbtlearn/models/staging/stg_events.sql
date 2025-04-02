with source as (

    select * from {{ source('data8', 'events') }}

),

renamed as (

    select
        id as event_id,
        repo,
        type as event_type,
        actor,
        created_at,
        {{ dbt_utils.generate_surrogate_key(['repository'])}} as repository_id,
        repository as repository_full_name

    from source

)

select * from renamed