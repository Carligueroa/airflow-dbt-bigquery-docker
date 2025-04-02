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

commit_counts as (

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
        events.repository_id,
        events.repository_full_name,
        count(*) as event_count
    from events
    left join commit_counts
    on (events.repository_id = commit_counts.repository_id)
    group by events.event_type,events.repository_id, events.repository_full_name

),

ranked_events as (
    
    select
        repository_id,
        repository_full_name,
        event_type,
        event_count,
        rank() over (partition by repository_id order by event_count desc) as event_rank
  from filtered_events

),

result as (

    select
        repository_full_name,
        event_type,
        event_count,
        event_rank
    from ranked_events
    where event_rank <= 3
    order by repository_full_name, event_rank

)

select * from result
