--SQL PROJECT - Library Management System

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM members;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
*/

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


/*
Task 14: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

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

SELECT * FROM branch_reports;

/*
Task 15: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
*/

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

/*
Task 16: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
*/

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

/*
Task 17: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.
*/

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

/*
Task 18: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
*/

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
