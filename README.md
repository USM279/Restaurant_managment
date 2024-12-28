# Restaurant Management System

## Overview
This is a Python-based GUI application for managing a restaurant's database. The system is built using `Tkinter` for the user interface and interacts with a PostgreSQL database. It provides functionality for managing customers, staff, menu items, orders, payments, inventory, and more.

## Features
- **Dynamic Table Management:** Select and manage data from multiple tables in the database.
- **CRUD Operations:** Easily perform Create, Read, Update, and Delete operations.
- **Search Functionality:** Search for records in tables using specific criteria like IDs.
- **Auto-Increment IDs:** Automatically handles ID generation for new records in supported tables.
- **Trigger Support:** Includes database triggers to automate processes like order status updates.
- **Stored Procedures:** Implements stored procedures for operations like adding new orders, processing payments, etc.
- **Error Handling:** Displays real-time feedback for successful and failed operations.

## Requirements
- Python 3.12+
- PostgreSQL database
- Required Python libraries:
  - `psycopg2`
  - `tkinter`

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/USM279/Restaurant_managment.git
   cd Restaurant_managment
2. Set up a virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
3. Install dependencies:
   ```bash
   pip install psycopg2
4. Set up the PostgreSQL database;
   ```bash
   psql -U postgres -d your_database_name -f schema.sql


5. Configure database connection:
   Update the database_connection.py file with your PostgreSQL credentials:
   ```python
   def connect():
    return psycopg2.connect(
        dbname="your_database_name",
        user="your_username",
        password="your_password",
        host="your_host",
        port="your_port"
    )
6. Run the application:
   ```bash
   python main_app.py


**Database Tables
**
- The application works with the following tables:
- Customer: Manages customer details.
- Staff: Tracks restaurant staff details.
- Role: Defines roles assigned to staff.
- MenuItem: Contains menu item information.
- CustomerOrder: Tracks customer orders.
- OrderItem: Links items to customer orders.
- Payment: Logs payment transactions.
- DiningTable: Tracks dining table information.
- OrderTable: Manages table orders.
- Stock: Tracks inventory.
- OrderDiscount: Manages discounts for orders.
- StaffActionLog: Logs staff activities.
- StaffRole: Links staff members to their roles.

**Usage
**
1. Select a Table: Use the dropdown menu to select a table.
2. List Records: Click on the "List" button to view all records in the selected table.
3. Add New Records:
   Fill in the form fields and click "Insert."
   Leave the ID field blank (auto-generated).
4. Update Records:
   Select a record from the table.
   Edit the form fields and click "Update."
5. Delete Records:
   Select a record from the table.
   Click "Delete."
6. Search by ID:
   Enter an ID in the search bar and click "Search."

**Screenshots 
**
<img width="998" alt="Screenshot 2024-12-28 at 6 26 49 pm" src="https://github.com/user-attachments/assets/4ab226d6-a6e1-437d-a749-15c7e9ddcd17" />

<img width="998" alt="Screenshot 2024-12-28 at 6 27 50 pm" src="https://github.com/user-attachments/assets/e078bc7e-8f34-47fa-86b9-80c7e7ca01e5" />

**Future Improvements
**
- Add user authentication for enhanced security.
- Implement analytics and reporting features.
- Enhance UI design for a better user experience.

**Contributing
**
Contributions are welcome! Please fork the repository and create a pull request for any new features or bug fixes.

