-- What is the average time between pull requests in the ‘datascience’ repo?
with raw_data as (

    select 
        created_at
    from {{ ref('fct_pull_requests') }}
    where 
        repository_full_name = 'data-8/datascience'


),
ordered_data as (

    select
        created_at,
        lag(created_at) over (order by created_at) as previous_created_at
    from raw_data

),
time_differences as (

    select
        TIMESTAMP_DIFF(created_at, previous_created_at, DAY) as time_difference_in_days
    from ordered_data
    where previous_created_at is not null

),
result as (

    select
        round(avg(time_difference_in_days)) as avg_time_between_pull_requests_in_days
    from time_differences

)

select * from result