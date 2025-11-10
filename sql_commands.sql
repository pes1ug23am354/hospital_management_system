

-- Show all tables
SHOW TABLES;



SELECT '\n========== DEPARTMENTS TABLE ==========' AS '';
DESCRIBE departments;
SELECT * FROM departments;

SELECT '\n========== PATIENTS TABLE ==========' AS '';
DESCRIBE patients;
SELECT * FROM patients;

SELECT '\n========== DOCTORS TABLE ==========' AS '';
DESCRIBE doctors;
SELECT * FROM doctors;

SELECT '\n========== PHARMACIES TABLE ==========' AS '';
DESCRIBE pharmacies;
SELECT * FROM pharmacies;

SELECT '\n========== ITEMS TABLE ==========' AS '';
DESCRIBE items;
SELECT * FROM items;

SELECT '\n========== PRODUCTS TABLE ==========' AS '';
DESCRIBE products;
SELECT * FROM products;

SELECT '\n========== CATEGORIES TABLE ==========' AS '';
DESCRIBE categories;
SELECT * FROM categories;

SELECT '\n========== INVENTORY TABLE ==========' AS '';
DESCRIBE inventory;
SELECT * FROM inventory;

SELECT '\n========== TREATMENT_RECORDS TABLE ==========' AS '';
DESCRIBE treatment_records;
SELECT * FROM treatment_records;

SELECT '\n========== PURCHASES TABLE ==========' AS '';
DESCRIBE purchases;
SELECT * FROM purchases;

SELECT '\n========== PURCHASE_ITEMS TABLE ==========' AS '';
DESCRIBE purchase_items;
SELECT * FROM purchase_items;

SELECT '\n========== SALES TABLE ==========' AS '';
DESCRIBE sales;
SELECT * FROM sales;

SELECT '\n========== SALE_ITEMS TABLE ==========' AS '';
DESCRIBE sale_items;
SELECT * FROM sale_items;

SELECT '\n========== BILLS TABLE ==========' AS '';
DESCRIBE bills;
SELECT * FROM bills;

SELECT '\n========== PAYMENTS TABLE ==========' AS '';
DESCRIBE payments;
SELECT * FROM payments;

SELECT '\n========== USERS TABLE ==========' AS '';
DESCRIBE users;
SELECT * FROM users;

SELECT '\n========== INVENTORY_MOVEMENTS TABLE ==========' AS '';
DESCRIBE inventory_movements;
SELECT * FROM inventory_movements;

SELECT '\n========== PATIENT_AUDIT TABLE ==========' AS '';
DESCRIBE patient_audit;
SELECT * FROM patient_audit;

-- ========================================
-- TABLE ROW COUNTS
-- ========================================
SELECT '\n========== TABLE ROW COUNTS ==========' AS '';
SELECT 
    table_name AS 'Table Name',
    table_rows AS 'Row Count'
FROM information_schema.tables 
WHERE table_schema = 'pharmacy_new' 
ORDER BY table_name;
