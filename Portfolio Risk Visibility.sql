USE ProjectinSQL
GO

/* Create constraints to auto detect relationship 
Not null*/ 
ALTER TABLE employees
ALTER COLUMN employeeNumber INT NOT NULL

ALTER TABLE customers
ALTER COLUMN customerNumber INT NOT NULL

ALTER TABLE orders
ALTER COLUMN orderNumber INT NOT NULL

ALTER TABLE order_details
ALTER COLUMN orderNumber INT NOT NULL

ALTER TABLE payments
ALTER COLUMN customerNumber INT NOT NULL

/*PK*/

ALTER TABLE employees
ADD CONSTRAINT PK_employees PRIMARY KEY (employeeNumber);

ALTER TABLE customers
ADD CONSTRAINT PK_customers PRIMARY KEY (customerNumber);

ALTER TABLE orders
ADD CONSTRAINT PK_orders PRIMARY KEY (orderNumber);

/*ALTER TABLE order_details
ADD CONSTRAINT PK_order_details PRIMARY KEY (orderNumber);

ALTER TABLE payments
ADD CONSTRAINT PK_payments PRIMARY KEY (customerNumber); */

/*FK*/

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE (TABLE_NAME = 'employees' AND COLUMN_NAME = 'employeeNumber')
   OR (TABLE_NAME = 'customers' AND COLUMN_NAME = 'salesRepEmployeeNumber');

   ALTER TABLE Customers
ALTER COLUMN salesRepEmployeeNumber INT NULL;

ALTER TABLE customers
ADD CONSTRAINT FK_customers_employees FOREIGN KEY (salesRepEmployeeNumber) 
        REFERENCES employees(employeeNumber);


ALTER TABLE payments
ADD CONSTRAINT FK_payments_customers FOREIGN KEY (customerNumber) 
        REFERENCES customers(customerNumber);
/* check */
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE (TABLE_NAME = 'orders' AND COLUMN_NAME = 'customerNumber')
   OR (TABLE_NAME = 'customers' AND COLUMN_NAME = 'customerNumber');

   ALTER TABLE orders
ALTER COLUMN customerNumber INT NULL;

ALTER TABLE orders 
ADD CONSTRAINT FK_orders_customers FOREIGN KEY (customerNumber) 
        REFERENCES customers(customerNumber);

ALTER TABLE order_details 
ADD CONSTRAINT FK_order_details_orders FOREIGN KEY (orderNumber) 
        REFERENCES orders(orderNumber);

   /* NOW TO THE TASK*/
/*Task 1: Retrieve order details with customer information
Write a query to list all orders along with the customer’s name, contact person’s full name, 
And phone number.
Key columns: order number, order date, customer name, contact first name, contact last name, phone */

SELECT o.orderNumber, o.orderDate,  c.customerName, 
    CONCAT(c.contactFirstName, ' ', c.contactLastName) AS contactFullName,  c.phone
FROM Orders o
INNER JOIN Customers c ON c.customerNumber = o.customerNumber;

/*Task 2: Find employee sales performance
Write a query to list all employees along with the number of customers they manage and the total credit limit of their customers, sorted by total number of customers in descending order.
Key columns: employee number, first name, last name, total customers, total credit limit. */

SELECT 
    e.employeeNumber,
    CONCAT (e.firstName,' ', e.lastName) AS FullName,
    COUNT(c.customerNumber) AS totalCustomers,
    SUM(c.creditLimit) AS totalCreditLimit
FROM Employees e
LEFT JOIN Customers c ON c.salesRepEmployeeNumber = e.employeeNumber
GROUP BY e.employeeNumber,CONCAT (e.firstName,' ', e.lastName)
ORDER BY totalCustomers DESC;

/*Task 3: Identify high-value customers
Write a query to find customers whose total payment amount is above the average total payment made by all customers, sorted in ascending order.
Key columns; customer name, total payment amount */

SELECT c.customerName, SUM(p.amount) AS totalPaymentAmount
FROM Customers c
INNER JOIN Payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
HAVING SUM(p.amount) > ( SELECT AVG(customerTotal)
    FROM ( SELECT SUM(amount) AS customerTotal
        FROM payments
        GROUP BY customerNumber) AS AvgPayments)
ORDER BY totalPaymentAmount ASC;

/*Task 4: Calculate customer lifetime value
Write a query to find the total amount spent by each customer, sorted in descending order.
Key columns: customer name, total amount spent */
SELECT c.customerName,
    SUM(p.amount) AS totalAmountSpent
FROM Customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY SUM(p.amount) DESC;

/*Task 5: average order value per customer
Find the average order value (AOV) per customer, (Hint: Order Value = total payments / total orders).
Key columns: customer name, total payments, total orders, AOV */

SELECT c.customerName, SUM(p.amount) AS Totalpayment,
       COUNT(o.orderNumber) AS Totalorders, 
       SUM(p.amount)/ NULLIF(COUNT (o.orderNumber), 0) AS AOV
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY AOV DESC;


/*Task 6: Number of orders per customer with order count categories
Retrieve the number of order placed by each customer and classify them as:
High frequency if greater than 10 orders
Regular if 5 - 10 orders
Occasional if less than 5 orders
Key columns: customer name, order count, customer category */

SELECT c.customerName,COUNT(o.orderNumber) AS TotalorderCount,
    CASE WHEN COUNT(o.orderNumber) > 10 THEN 'High Frequency'
        WHEN COUNT(o.orderNumber) BETWEEN 5 AND 10 THEN 'Regular'
        ELSE 'Occasional'
    END AS customerCategory
FROM Customers c
LEFT JOIN Orders o ON o.customerNumber = c.customerNumber
GROUP BY c.customerName
ORDER BY TotalorderCount DESC;



