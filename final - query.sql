#LINK TO DATABASED USED: https://www.dropbox.com/s/znmjrtlae6vt4zi/employees.sql?dl=0

USE employees;
#EXERCISE 1: 
#Find the average salary of the male and female employees in each department.

SELECT
	d.dept_name,
	AVG(s.salary) AS average_salary,
    e.gender
FROM
	employees e
		JOIN
	salaries s ON e.emp_no = s.emp_no
		JOIN
	dept_emp de ON s.emp_no = de.emp_no
		JOIN
	departments d ON de.dept_no = d.dept_no
GROUP BY e.gender, d.dept_name
ORDER BY d.dept_name;

#EXERCISE 2: 
#Find the lowest department number encountered in the 'dept_emp' table. Then, find the highest department number.
SELECT
	MIN(dept_no) AS lowest_dpt_number,
    MAX(dept_no) AS highest_dpt_number
FROM
	dept_emp;
    
#EXERCISE 3: 
#Obtain a table containing the following three fields for all individuals whose employee number is not greater than 10040:
	#- employee number
	#the lowest department number among the departments where the employee has worked in
	#assign '110022' as 'manager' to all individuals whose employee number is lower than or equal to 10020,
		#and '110039' to those whose number is between 10021 and 10040 inclusive. 

SELECT
	e.emp_no,
	(SELECT
		MIN(dept_no) 
	FROM
		dept_emp de
	WHERE
		e.emp_no = de.emp_no) AS dept_no,
	CASE
			WHEN e.emp_no <= 10020 THEN '110022'
			WHEN e.emp_no BETWEEN 10021 AND 10040 THEN '110039'
	END AS manager
FROM
	employees e
WHERE
	e.emp_no <= 10040;
    
#EXERCISE 4: 
#Retrieve a list of all employees that have been hired in 2000
SELECT
	*
FROM
	employees
WHERE
	YEAR(hire_date) = 2000;
    
#EXERCISE 5:
#Retrieve a list of all employees from the ‘titles’ table who are engineers
#Repeat the exercise, this time retrieving a list of all employees from the ‘titles’ table who are senior engineers.

SELECT
	*
FROM
	employees e
		JOIN
	titles t ON e.emp_no = t.emp_no
WHERE
	t.title LIKE ('%engineer%');

SELECT 
	*
FROM
	employees e
		JOIN
	titles t ON e.emp_no = t.emp_no
WHERE
	t.title LIKE ('%senior engineer%');

#EXERCISE 6:
#Create a procedure that asks you to insert an employee number and that will obtain an output containing
	#the same number, as well as the number and name of the last department the employee has worked in.
	#Finally, call the procedure for employee number 10010. 
    
DELIMITER $$
CREATE PROCEDURE emp_no_name(IN P_EMP_NO integer)
BEGIN
	SELECT
		e.emp_no,
        d.dept_no,
        d.dept_name
	FROM
		employees e
			JOIN
		dept_emp de ON e.emp_no = de.emp_no
			JOIN
		departments d ON de.dept_no = d.dept_no
	WHERE
		e.emp_no = p_emp_no
			AND de.from_date = (SELECT
				MAX(from_date)
			FROM
				dept_emp
			WHERE
				emp_no = p_emp_no);
END $$
DELIMITER ;

CALL emp_no_name(10010);


#EXERCISE 7
#How many contracts have been registered in the ‘salaries’ table with duration of more than one year and
	#of value higher than or equal to $100,000? 
    
SELECT
	COUNT(from_date) as contracts
FROM
	salaries
WHERE
	DATEDIFF(to_date, from_date) > 365
		AND
			salary >= 100000;
            
#EXERCISE 8:
#Create a trigger that checks if the hire date of an employee is higher than the current date. 
#If true, set the hire date to equal the current date. Format the output appropriately (YY-mm-dd). 

DELIMITER $$
CREATE TRIGGER before_hire_date_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
	IF new.hire_date > date_format(sysdate(),'%y-%m-%d') THEN SET new.hire_date = date_format(sysdate(), '%Y-%M-%D');
END IF;
END $$
DELIMITER ;

DELETE FROM employees
WHERE emp_no = 9999999;
INSERT INTO employees (emp_no, birth_date, first_name, last_name, hire_date)
VALUES(
9999999,
'0000-00-00',
'Kyle',
'King',
'2025-12-31');

#EXERCISE 9:
#Define a function that retrieves the largest contract salary value of an employee. Apply it to employee number 11356. 

DELIMITER $$
CREATE FUNCTION f_max_salary (p_emp_no INTEGER) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
DECLARE v_highest_salary DECIMAL(10,2);
SELECT
	MAX(s.salary)
INTO v_highest_salary FROM
	employees e
		JOIN
	salaries s ON e.emp_no = s.emp_no
WHERE
	e.emp_no = p_emp_no;
RETURN v_highest_salary;
END $$

DELIMITER ;

SELECT f_max_salary(11356);

DROP FUNCTION f_max_salary;

#EXERCISE 10:
#you can now try to create a third function that also accepts a second parameter. Let this parameter be a character sequence. 
	#Evaluate if its value is 'min' or 'max' and based on that retrieve either the lowest or the highest salary, respectively 
	#If the inserted value is any string value different from ‘min’ or ‘max’, let the function 
	#return the difference between the highest and the lowest salary of that employee.
    
DELIMITER $$
CREATE FUNCTION f_salary (p_emp_no INTEGER, p_min_max VARCHAR(10)) RETURNS DECIMAL(10,2)
deterministic
BEGIN
DECLARE v_salary_info DECIMAL(10,2);
SELECT
	CASE
		WHEN p_min_max = 'max' THEN max(s.salary)
		WHEN p_min_max = 'min' THEN min(s.salary)
		ELSE max(s.salary) - min(s.salary)
	END AS salary_info
INTO v_salary_info FROM
	employees e
		JOIN
	salaries s ON e.emp_no = s.emp_no
WHERE
	e.emp_no = p_emp_no;
RETURN v_salary_info;
END $$

DELIMITER ;

select employees.f_salary(11356, 'min');
select employees.f_salary(11356, 'max');
select employees.f_salary(11356, 'maxxx');

drop function f_salary;


