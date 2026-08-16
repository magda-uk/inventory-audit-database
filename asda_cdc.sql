-- ==========================================
-- 1. DATABASE & TABLES CREATION 
-- ==========================================

CREATE DATABASE IF NOT EXISTS inventory_and_audit;
USE inventory_and_audit;
-- 1. Table roles
-- Standardizes job titles to avoid data redundancy
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE -- Ensures no duplicate roles
);

-- 2. Table colleagues
-- Master data for CDC colleagues including contact details and seniority
CREATE TABLE colleagues (
    user_id VARCHAR(12) PRIMARY KEY,        -- Unique Asda login
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL, -- Constraint: Emails must be unique
    started_at DATE NOT NULL -- The date the colleague joined Asda
);
-- 3. Table colleague_roles
-- Bridge table to allow many-to-many relationship between colleagues and roles
-- Allows record multi-skilled workers
CREATE TABLE colleague_roles (
    user_id VARCHAR(12),
    role_id INT,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES colleagues(user_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- 4. Table products
-- Master Data table for all items in the CDC.
CREATE TABLE products (
    item_no INT(20) PRIMARY KEY,        -- Asda Item Number (Unique identifier)
    product_name VARCHAR(100) NOT NULL,     -- Description of the item
    unit_price DECIMAL(10, 2) NOT NULL,     -- Price per unit for valuation
    is_heavy_item BOOLEAN DEFAULT FALSE,    -- Flag for health and safety (lifting)
    CONSTRAINT chk_unit_price CHECK (unit_price > 0) -- Constraint: Price cannot be zero or negative
);

-- 5. Table inventory_units
-- This table tracks system (Manhattan WMS) recordings.
-- Links ILPNs with received items.
-- Records which colleague last worked with item.
CREATE TABLE inventory_units (
    ilpn_id INT PRIMARY KEY,            -- License Plate Number (Pallet ID)
    item_no INT(20) NOT NULL,           -- Foreign Key to products table
    initial_quantity INT NOT NULL,      -- Quantity received and recorded on the ILPN
    system_status VARCHAR(20) DEFAULT 'Available', -- Constraint: Default. 
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Automatic clock-Function(Current_Timestamp)
    updated_by_user VARCHAR(12),            -- Foreign Key to colleagues table
    FOREIGN KEY (item_no) REFERENCES products(item_no),
    FOREIGN KEY (updated_by_user) REFERENCES colleagues(user_id),
    CONSTRAINT chk_qty CHECK (initial_quantity >= 0) -- Constraint:Check- Stock cannot be negative
);
-- 6. Table physical_audit
-- Stores the results of physical inventory checks.
-- This is where we identify discrepancies (PI - Perpetual Inventory).
CREATE TABLE physical_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each audit
    ilpn_id INT NOT NULL,                    -- The pallet being checked
    actual_quantity INT NOT NULL,            -- What the manager physically counted
    manager_user_id VARCHAR(12) NOT NULL,    -- The colleague performing the audit
    location_notes TEXT,                     -- Details like 'Aisle 4, Level 2' or 'Damaged packaging'
    sighting_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- When the audit happened-In-Built Function(Current_Timestamp)
    FOREIGN KEY (ilpn_id) REFERENCES inventory_units(ilpn_id),
    FOREIGN KEY (manager_user_id) REFERENCES colleagues(user_id)
);

-- ==========================================
-- 2. DATA POPULATION (MOCK DATA)
-- ==========================================

INSERT INTO roles (role_name) VALUES 
('Picker'),
('Reciever'),
('Loader'),
('Hybrid Role'),
('Goods in Clerk'),
('Manager'),
('Admin'),
('Stock_auditor'),
('Tipper');

INSERT INTO colleagues (user_id, first_name, last_name, email, started_at) VALUES 
('js00sw', 'John', 'Smith', 'john.smith@asda.com', '2018-05-12'),
('tw14cs', 'Tracy', 'Warrens', 'tracy.warrens@asda.com', '2020-02-20'),
('sb07wj', 'Sarah', 'Belcher', 'sarah.belcher@asda.com', '2015-11-01'),
('dg22mk', 'David', 'Gill', 'david.gill@asda.com', '2022-06-15'),
('rj09pl', 'Robert', 'Jones', 'robert.jones@asda.com', '2021-03-10'),
('em11qw', 'Emma', 'Miller', 'emma.miller@asda.com', '2019-09-30'),
('th05ty', 'Thomas', 'Hardy', 'thomas.hardy@asda.com', '2017-08-22'),
('bc03er', 'Benjamin', 'Cook', 'benjamin.cook@asda.com', '2023-01-05'),
('sw10er', 'Sophie', 'West', 'sophie.west@asda.com', '2024-02-14'),
('lh11mk', 'Liam', 'Hill', 'liam.hill@asda.com', '2024-05-20');
INSERT INTO colleagues (user_id, first_name, last_name, email, started_at) VALUES 
('al26br', 'Alex', 'Brown', 'alex.brown@asda.com', '2026-01-10'),
('mj26st', 'Maria', 'Jimenez', 'maria.jimenez@asda.com', '2026-03-22');

INSERT INTO colleague_roles (user_id, role_id) VALUES 
('sb07wj', 6), 
('tw14cs', 6), 
('em11qw', 1), 
('bc03er', 1), 
('bc03er', 3), 
('th05ty', 9), 
('th05ty', 2), 
('js00sw', 4), 
('dg22mk', 5), 
('rj09pl', 7), 
('sw10er', 1), 
('lh11mk', 8);
INSERT INTO colleague_roles (user_id, role_id) VALUES 
('mj26st', 1),
('al26br', 8),
('al26br', 4);

INSERT INTO products (item_no, product_name, unit_price, is_heavy_item) VALUES 
(1002022, 'Asda Whole Milk 2L', 1.65, FALSE),
(2509981, 'British Beef Mince 500g', 3.50, FALSE),
(4001122, 'Jacket Potatoes 2.5kg', 2.20, TRUE),
(5550012, 'Coca Cola Zero 24pk', 10.00, TRUE),
(8889123, 'Asda Toilet Tissue 9pk', 4.50, FALSE),
(3337766, 'Gala Apples 6pk', 1.80, FALSE),
(9994433, 'Cadbury Dairy Milk 110g', 1.20, FALSE),
(7772211, 'Asda Frozen Peas 1kg', 1.45, FALSE),
(1112233, 'Basmati Rice 5kg', 7.50, TRUE),
(4445566, 'Hovis Wholemeal Bread', 1.10, FALSE),
(8880099, 'Nescafé Gold 200g', 6.00, FALSE),
(2223344, 'Walkers Variety 20pk', 4.80, FALSE),
(6667788, 'Comfort Fabric Softener', 3.50, FALSE),
(5554433, 'Heineken Lager 12pk', 12.00, TRUE),
(1234567, 'Asda Free Range Eggs x12', 2.50, FALSE);

INSERT INTO inventory_units (ilpn_id, item_no, initial_quantity, system_status, updated_by_user) VALUES 
(888001, 1002022, 48, 'Available', 'js00sw'),
(888002, 2509981, 24, 'Available', 'em11qw'),
(888003, 4001122, 100, 'On Hold', 'dg22mk'),
(888004, 5550012, 15, 'Available', 'bc03er'),
(888005, 8889123, 60, 'Available', 'js00sw'),
(888006, 3337766, 30, 'Damaged', 'th05ty'),
(888007, 1112233, 40, 'Available', 'rj09pl'),
(888008, 5554433, 20, 'Available', 'bc03er'),
(888009, 1234567, 144, 'Available', 'sw10er'),
(888010, 4445566, 80, 'Available', 'lh11mk'),
(888011, 8880099, 36, 'Available', 'em11qw'),
(888012, 2223344, 120, 'Available', 'js00sw');
INSERT INTO inventory_units (ilpn_id, item_no, initial_quantity, system_status, updated_by_user) VALUES 
(888013, 1112233, 20, 'Damaged', 'rj09pl'),   
(888014, 1112233, 50, 'Available', 'rj09pl'), 
(888015, 2223344, 100, 'On Hold', 'js00sw'),  
(888016, 1234567, 24, 'Available', 'dg22mk'), 
(888017, 5554433, 48, 'Available', 'em11qw'); 

INSERT INTO physical_audit (ilpn_id, actual_quantity, manager_user_id, location_notes) VALUES 
(888001, 45, 'sb07wj', 'Found 3 leaking bottles - removed from stock'),
(888002, 24, 'tw14cs', 'Count matches system - Aisle 1'),
(888003, 100, 'tw14cs', 'Status check: Still on hold for quality control'),
(888004, 12, 'sb07wj', 'Shortage: 3 units damaged by forklift in transit'),
(888005, 60, 'tw14cs', 'Location check: Aisle 4, Level 1 - OK'),
(888006, 30, 'tw14cs', 'Confirmed damaged status - Waiting for disposal'),
(888007, 38, 'sb07wj', 'Discrepancy: 2 units missing from bottom layer'),
(888008, 20, 'tw14cs', 'Heavy item area - safe to pick'),
(888009, 144, 'sb07wj', 'Bulk stock check - All eggs accounted for'),
(888010, 75, 'sb07wj', 'Shortage: 5 units missing compared to system'),
(888011, 36, 'tw14cs', 'Coffee stock check - OK'),
(888012, 120, 'sb07wj', 'Full pallet check - Matches system');

-- ==========================================
-- 3. QUERIES (ANALYSIS)
-- ==========================================

-- Shows products ordered by price on descending order, limited to 3. (Three more expensive)
SELECT 
	product_name AS item, 
	unit_price AS price
FROM products
ORDER BY unit_price DESC
LIMIT 3;

-- Identifies all audit records where the notes explicitly mention a "discrepancy" ordered by month.
SELECT 
	audit_id AS audit_no,
	location_notes AS details,
	MONTH(sighting_timestamp) AS month
FROM physical_audit 
WHERE location_notes LIKE '%discrepancy%'
ORDER BY month;

-- Shows audits where the notes state missing or damaged
SELECT 
	audit_id AS audit_no,
	location_notes AS details,
	DAY(sighting_timestamp) AS day
FROM physical_audit 
WHERE location_notes LIKE '%missing%'
	OR location_notes LIKE '%damaged%'
ORDER BY details;

-- Shows the audits with damaged notes FIRST, then the rest in ASC order
SELECT 
	audit_id AS audit_no,
	location_notes AS audit_details
FROM physical_audit 
ORDER BY audit_details LIKE '%damaged%'DESC, audit_details ASC;

-- Finds if specific users have interacted with "Damaged" inventory.
SELECT 
	updated_by_user AS last_user,
	ilpn_id AS ilpn
FROM inventory_units
WHERE system_status= "Damaged"
	AND (updated_by_user LIKE '%js%' OR updated_by_user LIKE '%rj%')
GROUP BY last_user, ilpn
ORDER BY last_user;

-- Filters items (qty between 100 and 150) that are not'Available'and the user.
SELECT 
	item_no AS item,
	initial_quantity AS quantity,
	system_status AS condition_code,
	updated_by_user AS last_user
FROM inventory_units
WHERE initial_quantity BETWEEN 100 AND 150
AND NOT system_status= "Available"
ORDER BY quantity DESC;

-- =============================================
-- 4. AGGREGATE FUNCTIONS 
-- =============================================
-- Calculates the total amount of items on hold
SELECT 
	COUNT(item_no) AS no_items,
	SUM(initial_quantity) AS total_units_not_allocated
FROM inventory_units
WHERE system_status = "On hold";

-- Calculates the total inventory volume for a specific product ID
SELECT 
	item_no AS item,
	SUM(initial_quantity) AS total_amount
FROM inventory_units 
WHERE item_no = 1112233
GROUP BY item_no;


-- =============================================
-- 5. IN-BUILT FUNCTIONS
-- =============================================
-- 
-- Numeric Function ROUND(..., 2) 
-- The result is formatted as a currency value
SELECT 
	ROUND(AVG(unit_price), 2) AS average_price
FROM products;

-- Round the item price to the nearest whole integer, because didn't specify a number of decimal places
SELECT 
	product_name AS item,
	ROUND(unit_price) AS round_price
FROM products
ORDER BY round_price;

-- Date Function YEAR (extracts the year part from a given date.)
-- Assigns a dynamic 'seniority' label based on specific date ranges 
-- and inclusion lists (IN/BETWEEN) to identify employee milestones.
         
SELECT first_name,
	CASE 
		WHEN YEAR (started_at) >= 2025 THEN "newbie"
		WHEN YEAR (started_at) BETWEEN 2015 AND 2019 THEN "senior"
		WHEN YEAR (started_at) IN (2016, 2021) THEN "aniversary_soon"
		ELSE "standard"
	END AS seniority
FROM colleagues
ORDER BY seniority;

-- Flow Control Function  IF()
-- Heavy items are flagged for 'priority pick' to ensure they are at 
-- the bottom of a pallet for stability, while others are 'normal_pick'.
SELECT 	
	product_name AS item,
	IF (is_heavy_item= TRUE, 'priority: pick it first', 'normal_pick')AS pick_type
FROM products
ORDER BY pick_type DESC;


-- ==========================================
-- 6.  JOINS
-- ==========================================
-- Shows colleague user_id and their roles
SELECT 
	cr.user_id, r.role_name
FROM colleague_roles AS cr
LEFT JOIN roles AS r
	ON cr.role_id = r.role_id
ORDER BY r.role_name;

-- Counts how many colleagues are trained in a role
SELECT 
	r.role_name AS job,
	COUNT(cr.user_id) AS total_trained
FROM colleague_roles AS cr
LEFT JOIN roles AS r
	ON cr.role_id = r.role_id
GROUP BY r.role_name
ORDER BY r.role_name;

-- Show which colleague last updated an item that later had an audit discrepancy.
SELECT 
    c.user_id AS colleague_id,
    p.item_no AS item,
    i.initial_quantity AS virtual_qty,
    a.actual_quantity AS physical_qty,
    a.location_notes AS details,
    a.manager_user_id AS auditor
FROM physical_audit a
JOIN inventory_units i ON a.ilpn_id = i.ilpn_id
JOIN products p ON i.item_no = p.item_no
JOIN colleagues c ON i.updated_by_user = c.user_id
WHERE initial_quantity <> actual_quantity
ORDER BY colleague_id;

-- ==========================================
-- 7. DELETE DATA
-- ==========================================
-- We insert a dummy product first so the delete doesn't affect existing queries results.

INSERT INTO products (item_no, product_name, unit_price, is_heavy_item) 
VALUES (1999900, 'Test Item for Deletion', 9.99, FALSE);

-- Now we perform the required DELETE operation
DELETE FROM products 
WHERE item_no = 1999900;


-- ==========================================
-- 8. VIRTUAL TABLE (VIEWS)
-- ==========================================
-- This view acts as an Exception Report. 
-- In a PI Office, this allows the team to focus only on 'unverified' 
-- stock, increasing warehouse efficiency.

-- We drop the view if it already exists to ensure the script runs smoothly every time.
DROP VIEW IF EXISTS Pending_Audits;

CREATE VIEW Pending_Audits AS
SELECT 
    i.system_status AS condition_code,
	i.ilpn_id AS ILPN_not_checked, 
    i.item_no AS item,
    p.product_name AS item_description
FROM inventory_units i
LEFT JOIN physical_audit a ON i.ilpn_id = a.ilpn_id
JOIN products p ON i.item_no = p.item_no
WHERE a.audit_id IS NULL 
ORDER BY system_status DESC;

SELECT * FROM Pending_Audits;

-- ==========================================
-- 9. STORED PROCEDURE
-- ==========================================

DELIMITER //

/* Purpose: This procedure simulates an Asda store price update. 
   Staff can change the price of an item using item_no(eg.Yellow Sticker Items)  */

CREATE PROCEDURE UpdateStorePrice(IN target_item_no INT, IN new_price DECIMAL(10,2))
BEGIN
   -- Updates the specific product matching the input parameter
    UPDATE products 
    SET unit_price = new_price 
    WHERE item_no = target_item_no;
    
    SELECT CONCAT('Price successfully updated for Item: ', target_item_no) AS confirmation;
END //

DELIMITER ;

-- PROCEDURE DEMONSTRATION
-- 1. View current price for 'Asda Whole Milk 2L'
SELECT item_no, product_name, unit_price FROM products WHERE item_no = 1002022;

-- 2. Call the procedure to update the price to 1.85
CALL UpdateStorePrice(1002022, 1.85);

-- 3. Verify the update worked as expected
SELECT item_no, product_name, unit_price FROM products WHERE item_no = 1002022;
