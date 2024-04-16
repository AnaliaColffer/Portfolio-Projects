--Delete previous database

DROP DATABASE PETSTORE

--Create the database

IF NOT EXISTS(SELECT * FROM sys.databases
	WHERE NAME = N'PETSTORE') --do this to delete the previous database and create a new one!
	CREATE DATABASE PetStore

GO
USE PetStore

-- Dtop existing tables
IF EXISTS(
	SELECT *
	FROM sys.tables 
	WHERE NAME = N'OrderItem'
	)
	DROP TABLE OrderItem;

IF EXISTS(
	SELECT *
	FROM sys.tables WHERE NAME = N'Product'
	)
	DROP TABLE Product;

IF EXISTS(
	SELECT *
	FROM sys.tables WHERE NAME = N'Category'
	)
	DROP TABLE Category;

IF EXISTS(
	SELECT *
	FROM sys.tables WHERE NAME = N'Rating'
	)
	DROP TABLE Rating;

IF EXISTS(
	SELECT *
	FROM sys.tables WHERE NAME = N'Supplier'
	)
	DROP TABLE Supplier;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Order'
       )
	DROP TABLE [Order];

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Customer'
       )
	DROP TABLE Customer;

IF EXISTS(
	SELECT *
	FROM sys.tables WHERE NAME = N'Employee'
	)
	DROP TABLE Employee;

IF EXISTS(
	SELECT *
	FROM sys.tables WHERE NAME = N'Department'
	)
	DROP TABLE Department;

IF EXISTS(
	SELECT *
	FROM sys.tables WHERE NAME = N'JobPosition'
	)
	DROP TABLE JobPosition;

-- Create the tables

CREATE TABLE Department (
	DepartmentID INT IDENTITY CONSTRAINT pk_department_id PRIMARY KEY,
    DepartmentName VARCHAR(55) CONSTRAINT nn_department_name NOT NULL
	);

CREATE TABLE JobPosition (
    JobPositionID INT IDENTITY CONSTRAINT pk_identity_id PRIMARY KEY,
    PositionName VARCHAR(55)CONSTRAINT nn_position_name NOT NULL,
    Salary DECIMAL(10, 2)
);

CREATE TABLE Employee (
    EmployeeID INT IDENTITY CONSTRAINT pk_employee_id PRIMARY KEY,
    FirstName VARCHAR(55) CONSTRAINT nn_first_name NOT NULL,
    LastName VARCHAR(55) CONSTRAINT nn_last_name NOT NULL,
	DepartmentID INT CONSTRAINT fk_department_id FOREIGN KEY REFERENCES Department(DepartmentID),
    JobPositionID INT CONSTRAINT fk_jobposition_id FOREIGN KEY REFERENCES JobPosition(JobPositionID),
    HireDate DATE CONSTRAINT nn_hire_date NOT NULL,
);

CREATE TABLE Customer (
	CustomerID INT IDENTITY CONSTRAINT pk_customer_id PRIMARY KEY,
    FirstName VARCHAR(55) CONSTRAINT nn_customer_first_name NOT NULL,
    LastName VARCHAR(55) CONSTRAINT nn_customer_last_name NOT NULL,
	Gender VARCHAR(55) CONSTRAINT nn_customer_gender NOT NULL,
	Birthdate DATE CONSTRAINT nn_customer_birthdate NOT NULL,
    Email VARCHAR(55)CONSTRAINT nn_customer_email NOT NULL,
    Phone VARCHAR(12) CONSTRAINT nn_customer_telephone NOT NULL,
    Street VARCHAR(255) CONSTRAINT nn_customer_address NOT NULL,
    City VARCHAR(55) CONSTRAINT nn_customer_city NOT NULL,
	[State] VARCHAR (55) CONSTRAINT nn_customer_state NOT NULL,
    ZipCode VARCHAR(7) CONSTRAINT nn_customer_postal_code NOT NULL,
);

CREATE TABLE [Order] (
    OrderID INT IDENTITY CONSTRAINT pk_order_id PRIMARY KEY,
    CustomerID INT CONSTRAINT fk_customer_id FOREIGN KEY REFERENCES Customer(CustomerID),
    EmployeeID INT CONSTRAINT fk_employee_id FOREIGN KEY REFERENCES Employee(EmployeeID),
    OrderDate DATE CONSTRAINT nn_order_date NOT NULL,
);

CREATE TABLE Category (
    CategoryID INT IDENTITY CONSTRAINT pk_category_id PRIMARY KEY,
    CategoryName VARCHAR(55) CONSTRAINT nn_category_name NOT NULL
);

CREATE TABLE Rating (
    RatingID INT IDENTITY CONSTRAINT pk_rating_id PRIMARY KEY,
    RatingScore INT CONSTRAINT nn_rating_score CHECK (RatingScore >= 0 AND RatingScore <= 5) NOT NULL
);

CREATE TABLE Supplier (
    SupplierID INT IDENTITY CONSTRAINT pk_supplier_id PRIMARY KEY,
    CompanyName VARCHAR(55) CONSTRAINT nn_company_name NOT NULL,
    ContactFirstName VARCHAR(55) CONSTRAINT nn_supplier_first_name NOT NULL,
    ContactLastName VARCHAR(55) CONSTRAINT nn_supplier_last_name NOT NULL,
    Email VARCHAR(55) CONSTRAINT nn_supplier_email NOT NULL,
    Phone VARCHAR(12) CONSTRAINT nn_supplier_phone NOT NULL
);

CREATE TABLE Product (
    ProductID INT IDENTITY CONSTRAINT pk_product_id PRIMARY KEY,
    ProductName VARCHAR(55) CONSTRAINT nn_product_name NOT NULL,
    SupplierID INT CONSTRAINT fk_supplier_id FOREIGN KEY REFERENCES Supplier(SupplierID),
    CategoryID INT CONSTRAINT fk_category_id FOREIGN KEY REFERENCES Category(CategoryID),
    RatingID INT CONSTRAINT fk_rating_id FOREIGN KEY REFERENCES Rating(RatingID),
    UnitSalesPrice DECIMAL(10, 2) CONSTRAINT nn_unitsales_price NOT NULL,
    UnitCost DECIMAL(10, 2) CONSTRAINT nn_unit_cost NOT NULL, 
);

CREATE TABLE OrderItem (
    OrderItemID INT IDENTITY CONSTRAINT pk_order_item_id PRIMARY KEY,
    OrderID INT CONSTRAINT fk_order_id FOREIGN KEY REFERENCES [Order](OrderID),
    ProductID INT CONSTRAINT fk_product_id FOREIGN KEY REFERENCES Product(ProductID),
    Quantity INT CONSTRAINT nn_quantity NOT NULL
);


-- Insert values in Tables

--Load base data into Department Table

INSERT INTO DEPARTMENT VALUES ('Sales');
INSERT INTO DEPARTMENT VALUES ('Management');
INSERT INTO DEPARTMENT VALUES ('Marketing');
INSERT INTO DEPARTMENT VALUES ('Operations');
INSERT INTO DEPARTMENT VALUES ('Training');
INSERT INTO DEPARTMENT VALUES ('Inventory');
INSERT INTO DEPARTMENT VALUES ('Logistics');
INSERT INTO DEPARTMENT VALUES ('Customer Service');
INSERT INTO DEPARTMENT VALUES ('Grooming');

--Load external data into JobPosition Table

BULK INSERT dbo.JobPosition
FROM 'C:\Users\Graduate\Desktop\DU Winter Quarter\Data Warehousing\Group Project\Project Part 2\Job Positions Clean Data.csv'
WITH 
(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
);

--Load external data into Employee Table (30 employees)

BULK INSERT dbo.Employee
FROM 'C:\Users\Graduate\Desktop\DU Winter Quarter\Data Warehousing\Group Project\Project Part 2\Employee Raw Data.csv'
WITH 
(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
);

--Load external data into Customer Table (500 customers)

BULK INSERT dbo.Customer
FROM 'C:\Users\Graduate\Desktop\DU Winter Quarter\Data Warehousing\Group Project\Project Part 2\Customer Raw Data.csv'
WITH 
(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
);


--Load external data into Order Tabe
BULK INSERT dbo.[Order]
FROM 'C:\Users\Graduate\Desktop\DU Winter Quarter\Data Warehousing\Group Project\Project Part 2\Order Raw Data.csv'
WITH 
(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
);


--Load base data into Category Table
INSERT INTO CATEGORY VALUES ('Toys');
INSERT INTO CATEGORY VALUES ('Food');
INSERT INTO CATEGORY VALUES ('Accesories');


--Load base data into Rating Table

INSERT INTO RATING VALUES ('1');
INSERT INTO RATING VALUES ('2');
INSERT INTO RATING VALUES ('3');
INSERT INTO RATING VALUES ('4');
INSERT INTO RATING VALUES ('5');


--Load external data into Supplier Table (5 suppliers)
BULK INSERT dbo.Supplier
FROM 'C:\Users\Graduate\Desktop\DU Winter Quarter\Data Warehousing\Group Project\Project Part 2\Suppliers Raw Data.csv'
WITH 
(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
);

--Load external data into Products Table (30 products, 10 of each cartegory)

BULK INSERT dbo.Product
FROM 'C:\Users\Graduate\Desktop\DU Winter Quarter\Data Warehousing\Group Project\Project Part 2\Products Clean Data.csv'
WITH 
(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
);


-- Load external data into OrderItem Table

BULK INSERT dbo.OrderItem
FROM 'C:\Users\Graduate\Desktop\DU Winter Quarter\Data Warehousing\Group Project\Project Part 2\OrderItem Raw Data.csv'
WITH 
(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
);



