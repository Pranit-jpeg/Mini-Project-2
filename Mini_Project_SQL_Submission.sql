
-- Mini Project Part 2: Data Cleaning and SQL Practice

-- =====================================================
-- TASK 1: Create Table
-- =====================================================
DROP TABLE IF EXISTS organizations;
CREATE TABLE IF NOT EXISTS organizations (
  Index SERIAL PRIMARY KEY,
  Organization_Id VARCHAR(255),
  Name VARCHAR(255),
  Website VARCHAR(255),
  Country VARCHAR(255),
  Description TEXT,
  Founded VARCHAR(5),
  Industry VARCHAR(255),
  Number_of_Employees INT
);

-- =====================================================
-- TASK 2: Import CSV File
-- (⚠️ Adjust path to your local machine)
-- =====================================================
-- COPY public.organizations (Index,Organization_Id,Name,Website,Country,Description,Founded,Industry,Number_of_Employees)
-- FROM 'G:/organizations-10000.csv' DELIMITER ',' CSV HEADER;

-- =====================================================
-- TASK 3: Basic SELECT and INSERT
-- =====================================================
SELECT Name, Country FROM organizations LIMIT 20;

INSERT INTO organizations (
  Index, Organization_Id, Name, Website, Country, Description, Founded, Industry, Number_of_Employees
) VALUES (
  100001, 'bC0CEd48A8000E0', 'Velazquez-Odom', 'https://stokes.com/', 'Djibouti',
  'Streamlined 6th generation function', '2002', 'Alternative Dispute Resolution', 4044
);
SELECT * FROM organizations WHERE Index = '100001';

-- =====================================================
-- TASK 4: Aggregation, NULL Check, and Update
-- =====================================================
SELECT MIN(Number_of_Employees) AS min_employees, MAX(Number_of_Employees) AS max_employees FROM organizations;
SELECT * FROM organizations WHERE Number_of_Employees IS NULL;
UPDATE organizations SET Number_of_Employees = 3135 WHERE Organization_Id = '6CDCcdE3D0b7b44';
SELECT * FROM organizations WHERE Organization_Id = '6CDCcdE3D0b7b44';

-- More tasks to be appended in the next cell due to size

-- =====================================================
-- TASK 5: Distinct Values and GROUP BY
-- =====================================================
SELECT DISTINCT Industry FROM organizations;
SELECT Industry, COUNT(*) AS count_by_industry
FROM organizations
GROUP BY Industry
ORDER BY count_by_industry DESC;

SELECT Industry, COUNT(DISTINCT Country) AS Number_of_Countries
FROM organizations
GROUP BY Industry
ORDER BY Number_of_Countries DESC;

-- =====================================================
-- TASK 6: LENGTH, FILTER, UPDATE, and ALTER
-- =====================================================
SELECT LENGTH(Founded) AS years_founded FROM organizations;
SELECT Organization_Id, Country, Founded FROM organizations WHERE LENGTH(Founded) > 4;

UPDATE organizations SET Founded = '1980' WHERE Organization_Id = '74FAA2BF6f0E0ed';

ALTER TABLE public.organizations
ALTER COLUMN Founded TYPE VARCHAR(4)
USING SUBSTRING(Founded FROM 1 FOR 4);

-- =====================================================
-- TASK 7: Find and Remove Duplicates
-- =====================================================
SELECT Organization_Id, COUNT(*) AS Occurrences
FROM organizations
GROUP BY Organization_Id
HAVING COUNT(*) > 1;

CREATE TABLE organizations_clean AS
SELECT DISTINCT ON (Organization_Id) *
FROM organizations
ORDER BY Organization_Id, Index;

DROP TABLE organizations;
ALTER TABLE organizations_clean RENAME TO organizations;

-- =====================================================
-- TASK 8: ORDER BY Number_of_Employees
-- =====================================================
SELECT Country, Number_of_Employees
FROM organizations
ORDER BY Number_of_Employees DESC;

-- =====================================================
-- TASK 9: CAST Founded to DATE and Filter
-- =====================================================
SELECT Name, Country, to_date(Founded, 'YYYY') AS Founded_Date
FROM organizations
WHERE CAST(Founded AS INTEGER) BETWEEN 1990 AND 2000;

SELECT Name, Country, to_date(Founded, 'YYYY') AS Founded_Date, Number_of_Employees
FROM organizations
WHERE CAST(Founded AS INTEGER) BETWEEN 1990 AND 2000 AND Number_of_Employees BETWEEN 2000 AND 3000;

SELECT
    CASE
        WHEN Number_of_Employees BETWEEN 0 AND 1000 THEN '0-1000'
        WHEN Number_of_Employees BETWEEN 1001 AND 2000 THEN '1001-2000'
        WHEN Number_of_Employees BETWEEN 2001 AND 3000 THEN '2001-3000'
        ELSE '3001+'
    END AS Employee_Range,
    COUNT(*) AS Count_of_Organizations
FROM organizations
WHERE CAST(Founded AS INTEGER) BETWEEN 1990 AND 2000
GROUP BY Employee_Range
ORDER BY Employee_Range;

ALTER TABLE organizations ADD COLUMN firm_size VARCHAR(10);
UPDATE organizations
SET firm_size = CASE
    WHEN Number_of_Employees BETWEEN 0 AND 1000 THEN 'Small'
    WHEN Number_of_Employees BETWEEN 1001 AND 2000 THEN 'Medium'
    WHEN Number_of_Employees BETWEEN 2001 AND 3000 THEN 'Large'
    ELSE 'Very Large'
END;

SELECT Name, Number_of_Employees, firm_size FROM organizations LIMIT 20;

-- More tasks continued...

-- =====================================================
-- TASK 10: Firms Older than 20 Years and Huge
-- =====================================================
SELECT
    CONCAT(Name, ' - ', Country) AS Firm_Details,
    Founded,
    Number_of_Employees
FROM organizations
WHERE
    CAST(Founded AS INTEGER) <= EXTRACT(YEAR FROM CURRENT_DATE) - 20
    AND Number_of_Employees > 6000;

-- =====================================================
-- TASK 11: Repeat of Task 10 (Confirmed by prompt)
-- =====================================================
SELECT
    CONCAT(Name, ' - ', Country) AS Firm_Details,
    Founded,
    Number_of_Employees
FROM organizations
WHERE
    CAST(Founded AS INTEGER) <= EXTRACT(YEAR FROM CURRENT_DATE) - 20
    AND Number_of_Employees > 6000;

-- =====================================================
-- TASK 12: TRIM and SUBSTRING
-- =====================================================
SELECT
    TRIM(SUBSTRING(Description FROM '^[A-Za-z]+')) AS First_Word,
    COUNT(*) AS Frequency
FROM organizations
GROUP BY First_Word
ORDER BY Frequency DESC
LIMIT 20;

-- =====================================================
-- TASK 13: LOOP for Incrementing Employees
-- =====================================================
DO $$
DECLARE
    org_id VARCHAR;
BEGIN
    FOR org_id IN SELECT Organization_Id FROM organizations
    LOOP
        UPDATE organizations
        SET Number_of_Employees = COALESCE(Number_of_Employees, 0) + 100
        WHERE Organization_Id = org_id;
    END LOOP;
END $$;

-- =====================================================
-- TASK 14: INNER JOIN (Employees + Departments)
-- =====================================================
CREATE TABLE IF NOT EXISTS Departments (
    Department_ID INT PRIMARY KEY,
    Department_Name VARCHAR(50)
);

INSERT INTO Departments VALUES
(1, 'HR'), (2, 'Finance'), (3, 'Engineering'), (4, 'Sales'), (5, 'Service');

CREATE TABLE IF NOT EXISTS Employees (
    Employee_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Department_ID INT
);

INSERT INTO Employees VALUES
(101, 'Alice', 1), (102, 'Bob', 2), (103, 'Charlie', 3), (104, 'Diana', NULL), (105, 'Eve', 4);

SELECT
    Employees.Employee_ID,
    Employees.Employee_Name,
    Departments.Department_Name
FROM Employees
INNER JOIN Departments ON Employees.Department_ID = Departments.Department_ID;

-- =====================================================
-- TASK 15: LEFT JOIN
-- =====================================================
SELECT
    Employees.Employee_ID,
    Employees.Employee_Name,
    Departments.Department_Name
FROM Employees
LEFT JOIN Departments ON Employees.Department_ID = Departments.Department_ID;

-- =====================================================
-- TASK 16: RIGHT JOIN
-- =====================================================
SELECT
    Departments.Department_ID,
    Departments.Department_Name,
    Employees.Employee_Name
FROM Employees
RIGHT JOIN Departments ON Employees.Department_ID = Departments.Department_ID;

-- =====================================================
-- TASK 17: FULL OUTER JOIN
-- =====================================================
SELECT
    Employees.Employee_ID,
    Employees.Employee_Name,
    Departments.Department_Name
FROM Employees
FULL OUTER JOIN Departments ON Employees.Department_ID = Departments.Department_ID;

-- =====================================================
-- TASK 18: Subquery in SELECT
-- =====================================================
CREATE TABLE IF NOT EXISTS Warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(50),
    state VARCHAR(2)
);
INSERT INTO Warehouses VALUES
(1, 'Warehouse A', 'NY'), (2, 'Warehouse B', 'CA'),
(3, 'Warehouse C', 'TX'), (4, 'Warehouse D', 'FL');

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT PRIMARY KEY,
    warehouse_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2)
);
INSERT INTO Orders VALUES
(101, 1, 201, '2025-01-01', 500.00),
(102, 1, 202, '2025-01-02', 300.00),
(103, 2, 203, '2025-01-01', 700.00),
(104, 3, 204, '2025-01-03', 200.00),
(105, 4, 205, '2025-01-04', 100.00),
(106, 2, 206, '2025-01-04', 400.00),
(107, 3, 207, '2025-01-05', 250.00);

CREATE TABLE IF NOT EXISTS Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50)
);
INSERT INTO Customers VALUES
(201, 'Alice', 'New York'), (202, 'Bob', 'San Francisco'),
(203, 'Charlie', 'Los Angeles'), (204, 'Diana', 'Houston'),
(205, 'Eve', 'Miami'), (206, 'Frank', 'Sacramento'), (207, 'Grace', 'Dallas');

SELECT
    warehouse_id,
    warehouse_name,
    (SELECT SUM(amount) FROM Orders) AS total_order_amount
FROM Warehouses;

-- =====================================================
-- TASK 19: Subquery in FROM
-- =====================================================
SELECT
    W.warehouse_name,
    O.total_amount
FROM Warehouses AS W
INNER JOIN (
    SELECT warehouse_id, SUM(amount) AS total_amount
    FROM Orders
    GROUP BY warehouse_id
) AS O ON W.warehouse_id = O.warehouse_id;

-- =====================================================
-- TASK 20: Subquery in WHERE
-- =====================================================
SELECT warehouse_name
FROM Warehouses
WHERE warehouse_id IN (
    SELECT DISTINCT warehouse_id
    FROM Orders
    WHERE customer_id IN (
        SELECT customer_id
        FROM Customers
        WHERE city IN ('New York', 'Dallas')
    )
);

-- =====================================================
-- TASK 21: Subquery with Aggregate Functions
-- =====================================================
SELECT
    W.warehouse_name,
    COUNT(O.order_id) AS number_of_orders,
    CASE
        WHEN COUNT(O.order_id) * 1.0 / (SELECT COUNT(*) FROM Orders) <= 0.25 THEN '0-25% Orders'
        WHEN COUNT(O.order_id) * 1.0 / (SELECT COUNT(*) FROM Orders) <= 0.50 THEN '26-50% Orders'
        WHEN COUNT(O.order_id) * 1.0 / (SELECT COUNT(*) FROM Orders) <= 0.75 THEN '51-75% Orders'
        ELSE '76-100% Orders'
    END AS fulfillment_category
FROM Warehouses AS W
LEFT JOIN Orders AS O ON W.warehouse_id = O.warehouse_id
GROUP BY W.warehouse_id, W.warehouse_name;
