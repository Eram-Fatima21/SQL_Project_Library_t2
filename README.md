# Library Management System using SQL Project 

## Project Overview

**Project Title**: Library Management System  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```

**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
     issued_member_id,
     count(issued_id) 
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id)>1;
```

### 3. CTAS (Create Table As Select)

**Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_cnts as
SELECT isbn,book_title,COUNT(issued_id) as book_issued_cnt
FROM books
JOIN issued_status
ON issued_status.issued_book_isbn = books.isbn
GROUP BY isbn,book_title;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

**Task 7.Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

**Task 8: Find Total Rental Income by Category**:

```sql
SELECT
     category,
     COUNT(category),
     SUM(rental_price) as total_rent
FROM Books
GROUP BY category;
```

**Task 9: List Members Who Registered in the Last 180 Days**:
    
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

**Task 10: List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
    e.emp_id,
    e.emp_name,
    e.position,
    e.salary,
	branch.*,
	m.emp_name as manager_name
FROM employees e
JOIN branch
ON e.branch_id = branch.branch_id 
JOIN employees m
ON m.emp_id = branch.manager_id; 
```

**Task 11: Create a Table of Books with Rental Price Above a Certain Threshold**:

```sql
CREATE TABLE expensive_books as
SELECT * FROM books
WHERE rental_price > 7.00;
```

**Task 12: Retrieve the List of Books Not Yet Returned**

```sql
SELECT DISTINCT(issued_book_name)
FROM issued_status
LEFT JOIN 
return_status
ON return_status.issued_id = issued_status.issued_id
WHERE return_status.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
    m.member_id, 
    m.member_name, 
    bk.book_title, 
    ist.issued_date,
    COALESCE(res.return_date, CURRENT_DATE) as check_date,
    (COALESCE(res.return_date, CURRENT_DATE) - ist.issued_date) - 30 as days_overdue
FROM members as m
JOIN issued_status as ist
    ON m.member_id = ist.issued_member_id
JOIN books as bk
    ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status as res
    ON res.issued_id = ist.issued_id
WHERE (COALESCE(res.return_date, CURRENT_DATE) - ist.issued_date) > 30;
```

**Task 14: Branch Performance Report**  
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
SELECT 
     br.branch_id,
     br.branch_address,
	 br.manager_id,
	 COUNT(ist.issued_id) as number_of_books_issued,
	 COUNT(res.return_id) as number_of_books_returned,
	 SUM(bk.rental_price) as total_revenue
FROM branch as br
JOIN
employees as emp
ON br.branch_id = emp.branch_id
JOIN
issued_status as ist
ON emp.emp_id = ist.issued_emp_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as res
ON ist.issued_id = res.issued_id
GROUP BY 1,2,3
ORDER BY 1;
```

**Task 15: CTAS: Create a Table of Active Members**  
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
CREATE TABLE active_members
AS
SELECT 
      DISTINCT ist.issued_member_id,
      mem.member_name,
	  mem.member_address
FROM issued_status as ist
JOIN 
members as mem
ON ist.issued_member_id = mem.member_id
WHERE (CURRENT_DATE - INTERVAL '2 months') <= issued_date ;

SELECT * FROM active_members;
```


**Task 16: Find Employees with the Most Book Issues Processed**  
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT 
     e.emp_name,
     br.*,
     COUNT(issued_id) as num_of_book_issued
FROM 
employees as e
JOIN 
issued_status as ist
ON e.emp_id = ist.issued_emp_id
JOIN 
branch as br
ON e.branch_id = br.branch_id
GROUP BY 1,2
ORDER BY  num_of_book_issued DESC LIMIT 3;
```

**Task 17: Identify Members Issuing High-Risk Books**  
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
```sql
SELECT 
     mem.member_name,
	 ist.issued_book_name,
	 COUNT(ist.issued_id) as issue_count
FROM issued_status as ist
LEFT JOIN 
return_status as res
ON ist.issued_id = res.issued_id
JOIN 
members as mem 
ON mem.member_id = ist.issued_member_id
WHERE res.book_quality = 'damaged' 
GROUP BY  mem.member_name,ist.issued_book_name
HAVING COUNT(ist.issued_id) > 2;
```

**Task 18: Create Table As Select (CTAS)**
-- Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

```sql
CREATE TABLE overdue_books_summary
AS
SELECT 
    m.member_id,
    m.member_name,
    COUNT(*) FILTER (WHERE (COALESCE(res.return_date, CURRENT_DATE) - ist.issued_date) > 30) as num_of_overdue_books,
    SUM(GREATEST((COALESCE(res.return_date, CURRENT_DATE) - ist.issued_date) - 30, 0) * 0.50) as total_fine,
    COUNT(ist.issued_id) as total_books_issued 
FROM members as m
JOIN issued_status as ist
    ON m.member_id = ist.issued_member_id
JOIN books as b
    ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status as res
    ON res.issued_id = ist.issued_id
GROUP BY 1,2
ORDER BY 1;

SELECT * FROM overdue_books_summary;
```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
2. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
3. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

