# Central Distribution Centre (CDC) — Inventory & Physical Audit Database

A relational database designed to tackle **Stock Drift** and operational discrepancies in high-volume distribution hubs. This project models the lifecycle of inventory pallet units (ILPNs), bridges virtual warehouse management records with physical Perpetual Inventory (PI) audits, and automates discrepancy exception reporting.

---

## 📌 Project Overview & Problem Statement

In large-scale chilled and ambient distribution centres, inventory recorded in Warehouse Management Systems (WMS) often diverges from physical floor stock due to transit damages, picking shortages, leakage, or misplacement a phenomenon known as **stock drift**.

This project provides a robust relational data model and analytical suite to:
- Enforce data integrity across colleagues, roles, products, and pallet-level inventory units.
- Track audit discrepancies between expected system stock and actual physical counts.
- Automate exception handling to flag unverified pallets and damaged inventory for immediate triage.

---

## 🛠️ Tech Stack & Concepts

- **Database Engine:** MySQL 
- **Data Modeling:** 3NF Normalization, Primary & Foreign Keys, Multi-to-Many Relationships (Junction Tables)
- **Data Integrity & Constraints:** `CHECK` constraints, `UNIQUE` identifiers, `CASCADE/RESTRICT` foreign key integrity, `TIMESTAMP` triggers
- **SQL Capabilities:** Multi-table `JOIN`s (Inner, Left), Conditional Logic (`CASE`, `IF`), Aggregate Functions, Subqueries, Virtual Tables (`VIEW`s), and Stored Procedures (`DELIMITER`)

---

## 🗄️ Database Architecture & Entity Relationships

The schema consists of 6 interconnected tables designed to ensure separation of concerns and eliminate redundancy:

[roles] <--- (M:N via colleague_roles) ---> [colleagues]
│
▼ (1:N)
[products] <─────── (1:N) ───────────> [inventory_units] (WMS System Stock)
│
▼ (1:N)
[physical_audit] (PI Floor Checks)

### Table Breakdown
1. **`roles`**: Standardized operational titles (`Picker`, `Loader`, `Stock_auditor`, `Admin`, etc.).
2. **`colleagues`**: Master record for warehouse staff, tracking unique logins, contact info, and start dates.
3. **`colleague_roles`**: Bridge table supporting multi-skilled workers across multiple job functions.
4. **`products`**: Master product catalogue with pricing, weight flags for Health & Safety / pick prioritization, and price validation constraints.
5. **`inventory_units`**: Pallet-level tracking (ILPNs) linking items, recorded system quantities, condition statuses (`Available`, `On Hold`, `Damaged`), and modification history.
6. **`physical_audit`**: Perpetual inventory physical audit logs capturing actual floor quantities, auditor ID, audit timestamps, and qualitative location notes.

---

## 🔍 Key Features & Analytical Queries

### 1. Discrepancy & Anomaly Detection
Identifies audits where physical quantities differ from system records, tracing back to the last colleague who updated the system unit:
```sql
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
WHERE i.initial_quantity <> a.actual_quantity
ORDER BY colleague_id;
```
### 2. Operational Exception View (Pending_Audits)
Acts as an operational exception report for the PI Office, dynamically filtering for pallet units that have not yet undergone a physical audit:

```SQL
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
```
### 3. Stored Procedure for Price Governance
Simulates a transactional price adjustment routine:
```sql
DELIMITER //
CREATE PROCEDURE UpdateStorePrice(IN target_item_no INT, IN new_price DECIMAL(10,2))
BEGIN
    UPDATE products 
    SET unit_price = new_price 
    WHERE item_no = target_item_no;
    
    SELECT CONCAT('Price successfully updated for Item: ', target_item_no) AS confirmation;
END //
DELIMITER ;
```
---
## 🚀 How to Run Locally
### 1. Clone the repository:

```Bash
git clone https://github.com/magda-uk/CFG-Assignments/tree/main/assignment-3-sql
cd <your-repo-name>
```
Execute the SQL script in MySQL Workbench, DBeaver, or via CLI:

Bash
mysql -u <username> -p < inventory_and_audit.sql
Verify installation:

SQL
USE inventory_and_audit;
SHOW TABLES;
SELECT * FROM Pending_Audits;
👤 Author
Developed by Magdalena Domínguez

Bridging warehouse operational logistics, Perpetual Inventory data integrity, and relational database systems.


---
de negocio.

<FollowUp label="Want to draft the bullet points for your CV to showcase this SQL project?" query="How should I describe this SQL inventory and audit project on my CV in English?"/
