select * from employee;

-- 1. Write a SQL query to remove the details of an employee whose first name ends in ‘even’
delete from employees where lower(first_name) like '%even';
select * from employees where lower(first_name) like '%even';


-- 2. Write a query in SQL to show the three minimum values of the salary from the table.
select distinct salary from employees order by salary limit 3;


-- 3. Write a SQL query to remove the employees table from the database
drop table employees;


-- 4. Write a SQL query to copy the details of this table into a new table with table name as Employee table and to delete the records in employees table
create table employee as (select * from employees);
select * from employee;
truncate table employees;
select * from employees;
--deep - schema, data -- like + insert
--shallow -schema - like
--simple - schema, data -as


-- 5. Write a SQL query to remove the column Age from the table
alter table employee add column age int;
describe table employee;
alter table employee drop column age;
describe table employee;


-- 6. Obtain the list of employees (their full name, email, hire_year) where they have joined the firm before 2000
select concat(first_name,' ',last_name) as full_name, email, year(hire_date) as hire_year from employee where hire_year<2000;


-- 7. Fetch the employee_id and job_id of those employees whose start year lies in the range of 1990 and 1999
select employee_id, job_id, year(hire_date) from employee where year(hire_date) between 1990 and 1999;//last job history


-- 8. Find the first occurrence of the letter 'A' in each employees Email ID Return the employee_id, email id and the letter position
select employee_id, email, position('A',email) as letter_position from employee where letter_position > 0;


-- 9. Fetch the list of employees(Employee_id, full name, email) whose full name holds characters less than 12
select employee_id, concat(first_name,' ',last_name) as full_name, email from employee where (len(full_name))< 12;


-- 10. Create a unique string by hyphenating the first name, last name , and email of the employees to obtain a new field named UNQ_ID Return the employee_id, and their corresponding UNQ_ID;
alter table employee add UNQ_ID varchar;
update employee set UNQ_ID = CONCAT(first_name, '-', last_name, '-', email);
select employee_id, UNQ_ID from employee;


-- 11. Write a SQL query to update the size of email column to 30
alter table employee modify column email varchar(30);
describe table employee;


-- 12. Fetch all employees with their first name , email , phone (without extension part) and extension (just the extension) Info : this mean you need to separate phone into 2 parts eg: 123.123.1234.12345 => 123.123.1234 and 12345 . first half in phone column and second half in extension column   
select first_name, email, phone_number,
case
    when array_size(split(phone_number, '.')) = 4 then concat(split_part(phone_number,'.', 1),'.',split_part(phone_number,'.', 2),'.', split_part(phone_number,'.', 3))
    when array_size(split(phone_number, '.')) = 3 then concat(split_part(phone_number,'.', 1),'.',split_part(phone_number,'.', 2) )
end as phone,
split_part(phone_number,'.', -1) as extension from employee;


-- 13. Write a SQL query to find the employee with second and third maximum salary.
select * from employee where salary in (select distinct salary from employee order by salary DESC limit 2 offset 1 );


-- 14. Fetch all details of top 3 highly paid employees who are in department Shipping and IT
select * from employee where department_id in (select department_id from departments where department_name in ('Shipping' ,'IT')) order by salary desc limit 3;


-- 15. Display employee id and the positions(jobs) held by that employee (including the current position)
--current job
select employee.employee_id, jobs.job_title from employee,jobs where employee.job_id=jobs.job_id 
union 
--history of jobs
select job_history.employee_id, jobs.job_title from job_history, jobs where job_history.job_id = jobs.job_id order by employee_id;


-- 16. Display Employee first name and date joined as WeekDay, Month Day, Year Eg : ID Date Joined 1 Monday, June 21st, 1999
select first_name, hire_date, concat (dayname(hire_date),', ', monthname(hire_date),' ', dayofmonth(hire_date),', ',year(hire_date)) as date from employee;


-- 17. The company holds a new job opening for Data Engineer (DT_ENGG) with a minimum salary of 12,000 and maximum salary of 30,000 . The job position might be removed based on market trends (so, save the changes) . - Later, update the maximum salary to 40,000 . - Save the entries as well.
alter session set autocommit=false;
select * from jobs;
insert into jobs values( 'DT_ENGG', 'Data Engineer', 12000, 30000 );
commit;
--delete from jobs where job_id='DT_ENGG';
update jobs set max_salary=40000 where job_id='DT_ENGG';
select * from jobs;
-- Now, revert back the changes to the initial state, where the salary was 30,000
rollback;
select * from jobs;
alter session set autocommit=true; --unset auto commit


-- 18. Find the average salary of all the employees who got hired after 8th January 1996 but before 1st January 2000 and round the result to 3 decimals
 select round(avg(salary),3) from employee where hire_date between '1996-01-09' and '1999-12-31';
 

-- 19. Display Australia, Asia, Antarctica, Europe along with the regions in the region table (Note: Do not insert data into the table)
--A. Display all the regions
select * from regions;
select region_name from regions 
union all 
select 'Australia' union all select 'Asia' union all select 'Antarctica' union all select 'Europe';

--B. Display all the unique regions
select region_name from regions union select 'Australia' union select 'Asia' union select 'Antarctica' union select 'Europe';