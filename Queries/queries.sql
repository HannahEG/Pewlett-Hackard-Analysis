--MODULE 7 LESSON & CHALLENGE CODE
--(challenge 7 code labeled below:)


--employees from 1952-1955
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

--employees from 1952
SELECT COUNT( * ) as "Number of Employees"
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

--employees from 1953
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31';

--employess from 1954
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31';

--employess from 1955
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31';

--retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

--count number of retiring employees
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31'); --41380 retiring

--create table for retirement eligible employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
--check table
SELECT * FROM retirement_info;

--DROP TABLE retirement_info;


-- Joining departments and dept_manager tables
SELECT d.dept_name,
	dm.emp_no,
	dm.from_date,
	dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no;

-- Joining tables and creating new table for retirement eligibility
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

SELECT * FROM current_emp;

-- Employee count by department number 
SELECT COUNT(ce.emp_no), de.dept_no
INTO dept_retire
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

SELECT * FROM dept_retire;

SELECT * FROM salaries
ORDER BY to_date DESC;

--create table for employees including gender and hire date
SELECT e.emp_no, 
	e.first_name, 
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

-- List of managers per department
SELECT 	dm.dept_no,
		d.dept_name,
		dm.emp_no,
		ce.last_name,
		ce.first_name,
		dm.from_date,
		dm.to_date
INTO manager_info
FROM dept_manager as dm
	INNER JOIN departments as d
		ON (dm.dept_no = d.dept_no)
	INNER JOIN current_emp as ce
		ON (dm.emp_no = ce.emp_no);
		
-- Retiring employees by department
SELECT	ce.emp_no,
		ce.first_name,
		ce.last_name,
		d.dept_name
INTO dept_info
FROM current_emp as ce
	INNER JOIN dept_emp as de
		ON (ce.emp_no = de.emp_no)
	INNER JOIN departments as d
		ON (de.dept_no = d.dept_no);

SELECT * FROM dept_INFO;
select * from emp_info;-- row count 33118
select * from retirement_info;
select * from manager_info;
select * from titles;

-- List query for sale department info
SELECT * FROM dept_info
WHERE dept_name IN('Sales', 'Development');





--CHALLENGE 7 CODE
-- Retiring employees count/grouped by title (BEFORE DUPLICATES)
SELECT COUNT(ce.emp_no), ts.title
--INTO title_retire
FROM current_emp as ce
LEFT JOIN titles as ts
ON ce.emp_no = ts.emp_no
GROUP BY ts.title
ORDER BY ts.title;

SELECT * FROM title_retire; --total count 54722

--retiring titles query for AFTER DUPLICATES removed
SELECT COUNT (emp_no), title
FROM titles_deliverable_refined
GROUP BY title
ORDER BY title; -- total count 33118


-- Retiring employees table with no, names, titles, from dates, salaries: Deliverable 1
SELECT	ei.emp_no,
		ei.first_name,
		ei.last_name,
		ts.title,
		ts.from_date,
		ei.salary
INTO titles_deliverable_1
FROM emp_info as ei
	INNER JOIN titles as ts
		ON (ei.emp_no = ts.emp_no); --54722 count rows

-- Remove duplicate title entries/keep most recent from_dates
SELECT 	emp_no, 
		first_name, 
		last_name, 
		title, 
		from_date,
		salary
INTO titles_deliverable_refined
FROM 
	(SELECT emp_no, first_name, last_name, title, from_date, salary,
	 ROW_NUMBER() OVER
	 (PARTITION BY (emp_no) 
	  ORDER BY from_date DESC) rn
	 FROM titles_deliverable_1)
	 tmp WHERE rn = 1
 ORDER BY emp_no;
	 
SELECT * FROM titles_deliverable_refined
ORDER BY emp_no; --row count 33118

-- Mentorship eligibility table
SELECT 	e.emp_no,
		e.first_name,
		e.last_name,
		ts.title,
		ts.from_date,
		ts.to_date
INTO mentorship_eligibility
FROM employees as e
	INNER JOIN titles as ts
ON e.emp_no = ts.emp_no
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31');

select * from mentorship_eligibility; --2846 row count

--Remove duplicates from mentorship eligibility
SELECT 	emp_no, 
		first_name, 
		last_name, 
		title, 
		from_date,
		to_date
INTO mentorship_eligibility_refined
FROM 
	(SELECT emp_no, first_name, last_name, title, from_date, to_date,
	 ROW_NUMBER() OVER
	 (PARTITION BY (emp_no) 
	  ORDER BY from_date DESC) rn
	 FROM mentorship_eligibility)
	 tmp WHERE rn = 1
 ORDER BY emp_no;
 
 select * from mentorship_eligibility_refined; --1940 row count
 
 
--COUNTS:
--number of mentorship eligible employees	 --1940 eligible
SELECT COUNT (emp_no)
FROM mentorship_eligibility_refined;

--number of retiring employees --41380 retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31'); 

