-- Create Customer Table
CREATE TABLE Customer (
    CustomerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Address TEXT NOT NULL
);

-- Create Staff Table
CREATE TABLE Staff (
    StaffID SERIAL PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(100) NOT NULL
);

-- Create Role Table
CREATE TABLE Role (
    RoleID SERIAL PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL
);

-- Create MenuItem Table
CREATE TABLE MenuItem (
    ItemID SERIAL PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Availability BOOLEAN DEFAULT TRUE NOT NULL
);

-- Create CustomerOrder Table
CREATE TABLE CustomerOrder (
    OrderID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL REFERENCES Customer(CustomerID) ON DELETE CASCADE,
    StaffID INT REFERENCES Staff(StaffID) ON DELETE SET NULL,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    OrderStatus VARCHAR(50) NOT NULL
);

-- Create OrderItem Table
CREATE TABLE OrderItem (
    OrderItemID SERIAL PRIMARY KEY,
    OrderID INT NOT NULL REFERENCES CustomerOrder(OrderID) ON DELETE CASCADE,
    ItemID INT NOT NULL REFERENCES MenuItem(ItemID) ON DELETE CASCADE,
    Quantity INT NOT NULL
);

-- Create Payment Table
CREATE TABLE Payment (
    PaymentID SERIAL PRIMARY KEY,
    OrderID INT NOT NULL REFERENCES CustomerOrder(OrderID) ON DELETE CASCADE,
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL
);

-- Create DiningTable Table
CREATE TABLE DiningTable (
    TableID SERIAL PRIMARY KEY,
    TableNumber INT NOT NULL,
    SeatingCapacity INT NOT NULL
);

-- Create OrderTable Table (many-to-many relationship)
CREATE TABLE OrderTable (
    OrderID INT NOT NULL REFERENCES CustomerOrder(OrderID) ON DELETE CASCADE,
    TableID INT NOT NULL REFERENCES DiningTable(TableID) ON DELETE CASCADE,
    PRIMARY KEY (OrderID, TableID)
);

-- Create Stock Table
CREATE TABLE Stock (
    StockID SERIAL PRIMARY KEY,
    ItemID INT NOT NULL REFERENCES MenuItem(ItemID) ON DELETE CASCADE,
    QuantityInStock INT NOT NULL
);

-- Create OrderDiscount Table
CREATE TABLE OrderDiscount (
    OrderID INT NOT NULL PRIMARY KEY REFERENCES CustomerOrder(OrderID) ON DELETE CASCADE,
    DiscountAmount DECIMAL(10, 2) NOT NULL,
    DiscountCode VARCHAR(50) NOT NULL
);

-- Create StaffActionLog Table
CREATE TABLE StaffActionLog (
    LogID SERIAL PRIMARY KEY,
    StaffID INT NOT NULL REFERENCES Staff(StaffID) ON DELETE CASCADE,
    ActionType VARCHAR(100) NOT NULL,
    ActionDetails TEXT NOT NULL,
    ActionTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Create StaffRole Table (many-to-many relationship between Staff and Role)
CREATE TABLE StaffRole (
    StaffID INT NOT NULL REFERENCES Staff(StaffID) ON DELETE CASCADE,
    RoleID INT NOT NULL REFERENCES Role(RoleID) ON DELETE CASCADE,
    PRIMARY KEY (StaffID, RoleID)
);

-- Add New Order Function
CREATE FUNCTION add_new_order(customer_id INT, staff_id INT, order_status VARCHAR) RETURNS VOID AS $$
BEGIN
    INSERT INTO CustomerOrder (CustomerID, StaffID, OrderStatus)
    VALUES (customer_id, staff_id, order_status);
END;
$$ LANGUAGE plpgsql;

-- Update Order Status Function
CREATE FUNCTION update_order_status(order_id INT, new_status VARCHAR) RETURNS VOID AS $$
BEGIN
    UPDATE CustomerOrder
    SET OrderStatus = new_status
    WHERE OrderID = order_id;
END;
$$ LANGUAGE plpgsql;

-- Process Payment Function
CREATE FUNCTION process_payment(order_id INT, total_amount DECIMAL, payment_method VARCHAR) RETURNS VOID AS $$
BEGIN
    INSERT INTO Payment (OrderID, TotalAmount, PaymentMethod)
    VALUES (order_id, total_amount, payment_method);
    UPDATE CustomerOrder
    SET OrderStatus = 'Completed'
    WHERE OrderID = order_id;
END;
$$ LANGUAGE plpgsql;

-- Add Menu Item Function
CREATE FUNCTION add_menu_item(item_name VARCHAR, description TEXT, price DECIMAL, category VARCHAR, availability BOOLEAN) RETURNS VOID AS $$
BEGIN
    INSERT INTO MenuItem (ItemName, Description, Price, Category, Availability)
    VALUES (item_name, description, price, category, availability);
END;
$$ LANGUAGE plpgsql;

-- Trigger for Order Status Update
CREATE FUNCTION trigger_update_order_status() RETURNS TRIGGER AS $$
BEGIN
    UPDATE CustomerOrder
    SET OrderStatus = 'In Progress'
    WHERE OrderID = NEW.OrderID;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_in_progress_status
AFTER INSERT ON OrderItem
FOR EACH ROW
EXECUTE FUNCTION trigger_update_order_status();

-- Trigger to Log Menu Item Changes
CREATE FUNCTION log_menu_item_changes() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO StaffActionLog (StaffID, ActionType, ActionDetails)
    VALUES (NULL, 'Menu Item Updated', CONCAT('ItemID: ', NEW.ItemID, ', Changes: ', ROW_TO_JSON(NEW)));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_menu_item_changes
AFTER UPDATE ON MenuItem
FOR EACH ROW
EXECUTE FUNCTION log_menu_item_changes();

-- Trigger to Ensure Item Availability before Ordering
CREATE FUNCTION check_item_availability() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT Availability FROM MenuItem WHERE ItemID = NEW.ItemID) = FALSE THEN
        RAISE EXCEPTION 'Item is not available.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_item_availability
BEFORE INSERT ON OrderItem
FOR EACH ROW
EXECUTE FUNCTION check_item_availability();

-- Trigger to Update Order Status to Completed
CREATE FUNCTION trigger_update_order_status_after_payment() RETURNS TRIGGER AS $$
BEGIN
    UPDATE CustomerOrder
    SET OrderStatus = 'Completed'
    WHERE OrderID = NEW.OrderID;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_order_status_after_payment
AFTER INSERT ON Payment
FOR EACH ROW
EXECUTE FUNCTION trigger_update_order_status_after_payment();
