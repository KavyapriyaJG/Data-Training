--1.	 Write a SQL query to find the total salary of employees who is in Tokyo excluding whose first name is Nancy
select sum(salary) as total_salary from employee 
join departments on employee.department_id = departments.department_id 
join locations on departments.location_id = locations.location_id 
where locations.city = 'Seattle' and employee.first_name != 'Nancy';


--2.	 Fetch all details of employees who has salary more than the avg salary by each department.
select employee.employee_id, employee.salary, employee.department_id, average_salaries.average_salary as avg_salary_of_dept from employee 
join ( select department_id, avg(salary) as average_salary from employee  
             group by department_id ) as average_salaries on employee.department_id = average_salaries.department_id
where employee.salary > average_salaries.average_salary;


--3.	Write a SQL query to find the number of employees and its location whose salary is greater than or equal to 7000 and less than 10000
select count(*) as total_employees, departments.location_id from employee
join departments on employee.department_id = departments.department_id
where employee.salary between 7000 and 9999
group by departments.location_id;


--4.	Fetch max salary, min salary and avg salary by job and department. 
-- Info:  grouped by department id and job id ordered by department id and max salary
select max(salary) as max_salary, min(salary) as min_salary, round(avg(salary),2) as average_salary, job_id, department_id from employee
group by department_id, job_id
order by department_id, max_salary;
 
--5.	Write a SQL query to find the total salary of employees whose country_id is ‘US’ excluding whose first name is Nancy  
select sum(employee.salary) as sum_of_salaries from employee 
join departments on employee.department_id = departments.department_id 
join locations on departments.location_id = locations.location_id
where employee.first_name != 'Nancy' and locations.country_id = 'US';


--6.	Fetch max salary, min salary and avg salary by job id and department id but only for folks who worked in more than one role(job) in a department.

-- all jobs that have atleast one employee worked in more than 1 role
SELECT job_id, department_id, employee_id  FROM employee repeated_emp WHERE employee_id IN (
    select data.employee_id from
    (SELECT jh.employee_id, jh.department_id, jh.job_id 
    FROM job_history jh 
    UNION ALL
    SELECT e.employee_id, e.department_id, e.job_id
    FROM employee e
    INNER JOIN jobs j ON e.job_id = j.job_id
    ) AS data
group by data.employee_id
HAVING count(data.employee_id) > 1
ORDER by data.employee_id )
ORDER BY employee_id;

--distinct jobs that have atleast one employee worked in more than 1 role
SELECT j.job_id, e.department_id, 
       MAX(j.max_salary) AS max_salary, 
       MIN(j.min_salary) AS min_salary,
       AVG(e.salary) AS avg_salary
FROM jobs j
JOIN employee e ON j.job_id = e.job_id
WHERE e.employee_id IN (
  SELECT employee_id
  FROM (
    SELECT jh.employee_id
    FROM job_history jh 
    UNION ALL
    SELECT e.employee_id
    FROM employee e
    INNER JOIN jobs j ON e.job_id = j.job_id
  ) AS data
  GROUP BY employee_id
  HAVING COUNT(employee_id) > 1
)
GROUP BY j.job_id, e.department_id;


--7.	Display the employee count in each department and also in the same result.  
-- Info: * the total employee count categorized as "Total"
-- •	the null department count categorized as "-" *
select coalesce(department_id::varchar, '-') as department_id, count(employee_id) as employee_count
from employee group by department_id
union select 'Total_employee_count',count(employee_id) from employee
order by department_id;


--8.	Display the jobs held and the employee count. 
-- Hint: every employee is part of at least 1 job 
-- Hint: use the previous questions answer
-- Sample
-- JobsHeld EmpCount
-- 1	100
-- 2	4
select jobs_held, count(jobs_held) as emp_count from ( select count(employee_id) as jobs_held from 
                                                        (select employee_id from employee
                                                           union all
                                                            select employee_id from job_history ) 
                                                      group by employee_id )
group by jobs_held
order by jobs_held;


--9.	 Display average salary by department and country.
select avg(salary) as average_salary, departments.department_name, countries.country_name from employee
inner join departments on employee.department_id = departments.department_id
inner join locations on departments.location_id = locations.location_id
inner join countries on locations.country_id = countries.country_id
group by departments.department_name, countries.country_name
order by countries.country_name, departments.department_name;


--10.	Display manager names and the number of employees reporting to them by countries (each employee works for only one department, and each department belongs to a country)
select concat(manager.first_name,' ',manager.last_name) as manager_name , count(employee.manager_id) as employees_reporting, countries.country_name
from employee
join departments on employee.department_id = departments.department_id
join locations on departments.location_id = locations.location_id
join countries on countries.country_id = locations.country_id
join employee manager on manager.employee_id = employee.manager_id
group by employee.manager_id, countries.country_id, manager.first_name, manager.last_name, countries.country_name 
order by manager_name;


--11. Group salaries of employees in 4 buckets eg: 0-10000, 10000-20000,.. (Like the previous question) but now group by department and categorize it like below. Eg : 
-- DEPT ID    0-10000      10000-20000
-- 50          2               10
-- 60          6                5
select department_id,
    count(case when salary >= 0 and salary < 10000 then 1 end)as "0-10000",
    count(case when salary >= 10000 and salary < 20000 then 1 end)as "10000-20000",
    count(case when salary >= 20000 and salary < 30000 then 1 end)as "20000-30000",
    count(case when salary >= 30000 then 1 end)as ">30000"
from  employee
group by department_id;


-- 12.	 Display employee count by country and the avg salary -- Eg : 
-- Emp Count       Country        Avg Salary
-- 10                     Germany      34242.8
select count(*) as emp_count, countries.country_name as country, round(avg(salary), 1) as avg_salary from employee
inner join departments on employee.department_id = departments.department_id
inner join locations on departments.location_id = locations.location_id
inner join countries on locations.country_id = countries.country_id
group by countries.country_name;


-- 13.	 Display region and the number of employees by department -- (Please put "-" instead of leaving it NULL or Empty)
-- Dept ID   America   Europe  Asia
-- 10            22               -            -
-- 40             -                 34         -
select * from regions;
select emp.department_id,
coalesce(nullif(cast(count(case when region_name = 'Europe' then 1 end) as string),'0'),'-') as europe,
coalesce(nullif(cast(count(case when region_name = 'Americas' then 1 end) as string),'0'),'-') as america,
coalesce(nullif(cast(count(case when region_name = 'Asia' then 1 end) as string),'0'),'-') as asia,
coalesce(nullif(cast(count(case when region_name = 'Middle East and Africa' then 1 end ) as string),'0'),'-') AS "MIDDLE EAST AFRICA AND ASIA"
from employee emp
join departments d on emp.department_id=d.department_id
join locations l on d.location_id=l.location_id
join countries c on l.country_id=c.country_id
join regions r on c.region_id=r.region_id
group by emp.department_id order by emp.department_id ;


-- 14.	 Select the list of all employees who work either for one or more departments or have not yet joined / allocated to any department
select employee_id, first_name from employee
where employee_id in (
  select emp.employee_id from employee as emp
  group by emp.employee_id
  having count(emp.department_id)>=1 or count(emp.department_id)=0
  order by emp.employee_id
);


-- 15.	write a SQL query to find the employees and their respective managers. Return the first name, last name of the employees and their managers
select  e.first_name as emp_first_name,
        e.last_name as emp_last_name,
        coalesce(concat( manager.first_name ,' ', manager.last_name ), 'Not yet assigned') as manager_name from employee e
left join employee manager on e.manager_id = manager.employee_id
order by manager.first_name;


-- 16.	write a SQL query to display the department name, city, and state province for each department.
 select departments.department_name, locations.city, locations.state_province from departments 
 join locations on departments.location_id = locations.location_id;

 
-- 17.	write a SQL query to list the employees (first_name , last_name, department_name) who belong to a department or don't
select employee.employee_id, employee.first_name, iff(employee.department_id = departments.department_id,'Belongs to','Does not belong') as status, departments.department_name from employee 
inner join departments on employee.department_id = departments.department_id
--group by status, employee.employee_id, employee.first_name, employee.department_id, departments.department_id, departments.department_name
--having status = 'Belongs to';
order by status;


-- 18.	The HR decides to make an analysis of the employees working in every department. Help him to determine the salary given in average per department and the total number of employees working in a department.  List the above along with the department id, department name
select e1.department_id, dept.department_name, no_of_employees , e1.avg_sal from (select emp.department_id, round(avg(emp.salary),2) as avg_sal,count(employee_id) as no_of_employees from employee emp 
group by emp.department_id) e1
join departments dept on dept.department_id = e1.department_id;


-- 19.	Write a SQL query to combine each row of the employees with each row of the jobs to obtain a consolidated results. (i.e.) Obtain every possible combination of rows from the employees and the jobs relation.
select * from employee 
cross join jobs order by employee_id;


-- 20.	 Write a query to display first_name, last_name, and email of employees who are from Europe and Asia
select employee.first_name, employee.last_name, employee.email, countries.country_name from employee
join departments on employee.department_id = departments.department_id
join locations on locations.location_id = departments.location_id
join countries on countries.country_id = locations.country_id
join regions on regions.region_id = countries.region_id
where region_name in ('Europe','Asia');


-- 21.	 Write a query to display full name with alias as FULL_NAME (Eg: first_name = 'John' and last_name='Henry' - full_name = "John Henry") who are from oxford city and their second last character of their last name is 'e' and are not from finance and shipping department.
select concat(first_name,' ',last_name)as full_name, locations.city from employee
join departments on employee.department_id= departments.department_id
join locations on locations.location_id = departments.location_id
where locations.city ='Oxford' and  last_name like '%e_' and lower(departments.department_name) not in ('shipping','finance');


-- 22.	 Display the first name and phone number of employees who have less than 50 months of experience
select  employee.first_name, employee.phone_number,  employee.hire_date, months_between(current_date(), employee.hire_date) as experience from employee
where experience < 50;


-- 23.	 Display Employee id, first_name, last name, hire_date and salary for employees who has the highest salary for each hiring year. (For eg: John and Deepika joined on year 2023,  and john has a salary of 5000, and Deepika has a salary of 6500. Output should show Deepika’s details only).
select employee_id , first_name, last_name, hire_date, salary, rnk as rank
from (
  select employee_id, first_name, last_name, hire_date, salary,
         dense_rank() over (partition by year(hire_date) order by salary desc) as rnk
  from employee
) as emp_details
where rnk = 1 order by employee_id;