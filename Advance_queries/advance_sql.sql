SELECT
    job_title as title,
    job_location As location,
    job_posted_date at time zone 'UTC' at time zone 'EST' as date,
    EXTRACT (MONTH FROM job_posted_date) as months,
    EXTRACT (YEAR from job_posted_date) as years
FROM 
    job_postings_fact
LIMIT 10;

SELECT
    count(job_id) as Number_of_jobs,
    EXTRACT (MONTH from job_posted_date) as months
from 
    job_postings_fact
WHERE
    job_title_short='Data Analyst'
GROUP BY
    months
order by 
    months;

select * 
from 
    job_postings_fact
limit 10;

select 
    job_schedule_type,
    avg(salary_year_avg),
    avg(salary_hour_avg)
FROM
    job_postings_fact
WHERE
    job_posted_date :: DATE > '2023-06-01'
GROUP BY
    job_schedule_type;

create table january_jobs as
select * 
from job_postings_fact
where
    EXTRACT(months from job_posted_date)= 1;

CREATE TABLE february_jobs AS
SELECT * FROM job_postings_fact WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
SELECT * FROM job_postings_fact WHERE EXTRACT(MONTH FROM job_posted_date) = 3;


select 
    count(job_id) as number_of_jobs,
    case
        when job_location = 'Anywhere' then 'Remote'
        when job_location = 'New York, NY' then 'Local'
        else 'Onsite'
    end as Location_category
from 
    job_postings_fact
where
    job_title_short='Data Analyst'
GROUP BY   
    Location_category;
--- case Example--
select 
    job_title_short,
    salary_year_avg,
    case
        when salary_year_avg >= 100000 then 'High'
        when salary_year_avg <100000 and salary_year_avg >= 55000 then 'standard'
        when salary_year_avg <55000 then 'low'
        else 'invalid salary'
    end as Salary_desired
from
    job_postings_fact
where 
    job_title_short = 'Data Analyst'
ORDER BY
    Salary_desired;
------------finish----------

-- subqueries example
select *
from(
    select *
    from job_postings_fact
    where EXTRACT (month from job_posted_date) = 1
) as january_jobs;
--finish--

--CET example
/* insted of creating permenent table we can just create temp table 
to display jan month data in seprate table */

with january_jobs as (
    select *
    from job_postings_fact
    where EXTRACT (month from job_posted_date) = 1
)
select * from january_jobs;

----finish---

-- subquerie example 
/* list of company that have any jobs that dont required degree
note : in this case job posting table have company_id and job degree required 
or not , we have to get name from company table  */
select
    name as compnay_name
from
    company_dim
where
    company_id IN(
        select 
            company_id
        from job_postings_fact
        where job_no_degree_mention = true
    );

/* 
CET example 
find companies that have the most job opening
-get the total num of job posting per comp_id (jon_posting_fact)
-Return the total number of jobs with the company name ( company_dim)
*/
with company_job_count as(
    select
    company_id,
    count(*) as total_jobs
    from
        job_postings_fact
    GROUP BY 
        company_id
)
select company_dim.name  as compnay_name,
       company_job_count.total_jobs 
from company_dim
left join company_job_count on company_job_count.company_id= company_dim.company_id
order BY
    company_job_count.total_jobs desc ;


select
    company_table.name,
    count(job_id) as total_jobs
from    
    job_postings_fact as job_table
    left join company_dim as company_table on 
        job_table.company_id= company_table.company_id
GROUP BY
    job_table.company_id, company_table.name
order BY   
    total_jobs desc;


/* find the count of the number of remote job postings per skill
-  Display the top 5 skills by their demand in remote jobs
- Include skill ID, name, and count of postings requiring the skill
NOTE: ketli remote jobs che per skill

*/

select* from skills_dim limit 5;


with remote_job_skills as(
    select
        skill_id,
        count(*) as total_skills
    from 
        skills_job_dim as skill_dim_table
    inner join job_postings_fact as job_table on job_table.job_id= skill_dim_table.job_id
    where  
        job_table.job_work_from_home = true
    GROUP BY
        skill_id
)
select
    skills,
    total_skills
from 
    remote_job_skills 
    inner join skills_dim as get_skill_name on
        get_skill_name.skill_id = remote_job_skills.skill_id
    order BY   
        total_skills desc limit 5;



/* union 
    find job postings from the first quarter have a salary greater than 70k$
    - combine job posting tables from the first quater of 2023(jan - march)
    - gets job postings with as averages yearly salary > $70,000
*/

select 
    job_title_short,
    job_location,
    job_via,
    job_posted_date::Date,
    salary_year_avg
from(
    select *
    from january_jobs
    UNION All
    select *
    from february_jobs
    UNION All
    select *
    from march_jobs
) as quarter_job_posting
where salary_year_avg > 70000
ORDER BY
    salary_year_avg desc;





