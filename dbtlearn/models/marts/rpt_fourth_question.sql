-- What are the most common events across all the top 3 repositories by number of commits?
with events as (

    select 
        created_at,
        event_type,
        repository_id,
        repository_full_name
    from {{ ref('fct_events') }}

),

commits as (

    select 
        repository_id,
        repository_full_name
    from {{ ref('fct_commits') }}

),

top_3_repositories as (

    select
        repository_id,
        repository_full_name,
        count(*) as commit_count
    from commits
    group by repository_id, repository_full_name
    order by commit_count desc
    limit 3
),

filtered_events as (

    select
        events.event_type,
        top_3_repositories.repository_id,
        top_3_repositories.repository_full_name,
        count(*) as event_count
    from events
    right join top_3_repositories
    on (events.repository_id = top_3_repositories.repository_id)
    group by events.event_type, top_3_repositories.repository_id, top_3_repositories.repository_full_name

),

result as (

    select
        repository_full_name,
        event_type,
        event_count,
        rank() over (partition by repository_id order by event_count desc) as event_rank
    from filtered_events

)
select * from result