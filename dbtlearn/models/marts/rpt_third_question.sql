-- What is the percentage of increase in the number of commits between last year and this year across all repositories?
with raw_data as (

    select 
        created_at
    from {{ ref('fct_commits') }}

),
yearly_commit_counts as (

    select
        extract(year from created_at) as commit_year,
        count(*) as commit_count
    from raw_data
    group by commit_year

),
comparison as (

    select
        current_year.commit_count as this_year_commits,
        previous_year.commit_count as last_year_commits,
        ((current_year.commit_count - previous_year.commit_count) / previous_year.commit_count) * 100 as percentage_increase
    from yearly_commit_counts current_year
    join yearly_commit_counts previous_year
        on current_year.commit_year = previous_year.commit_year + 1
    where current_year.commit_year = extract(year from current_date())
      and previous_year.commit_year = extract(year from current_date()) - 1

)

select * from comparison
