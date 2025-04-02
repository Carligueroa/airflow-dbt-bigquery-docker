-- Who is the user (author) with the most commits across all repositories in 2023?
with commits as (
    
    select * from {{ ref('fct_commits') }}
    where created_at >= '2023-01-01' and created_at < '2024-01-01'
),
grouped as (
    
    select
        author_name,
        author_email,
        count(*) as commit_count
    from commits
    group by
        author_name,
        author_email

),
result as (
    
    select
        author_name,
        author_email,
        commit_count
    from grouped
    order by
        commit_count desc

) 
    
select * from result