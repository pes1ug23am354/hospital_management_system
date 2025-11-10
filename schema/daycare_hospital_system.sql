-- ============================================
-- COMPLETE DATABASE SETUP
-- Creates schema and inserts fresh data
-- Database: pharmacy_new
-- ============================================

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS pharmacy_new;
USE pharmacy_new;

-- Drop existing tables if they exist
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS bills;
DROP TABLE IF EXISTS purchase_items;
DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS treatment_records;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS pharmacies;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS patient_audit;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- CREATE TABLES
-- ============================================

-- DEPARTMENTS
CREATE TABLE departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_name VARCHAR(100) NOT NULL,
  floor_no VARCHAR(20),
  dept_code VARCHAR(20) UNIQUE
);

-- PATIENTS
CREATE TABLE patients (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  gender ENUM('Male','Female','Other') DEFAULT 'Male',
  phone VARCHAR(20) UNIQUE,
  dob DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- DOCTORS
CREATE TABLE doctors (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  specialization VARCHAR(120),
  phone VARCHAR(20),
  visiting_hours VARCHAR(100),
  department_id INT,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

-- PHARMACIES
CREATE TABLE pharmacies (
  pharmacy_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  location VARCHAR(120),
  operational_hours VARCHAR(100)
);

-- PHARMACY ITEMS
CREATE TABLE items (
  item_id INT AUTO_INCREMENT PRIMARY KEY,
  item_name VARCHAR(150) NOT NULL,
  brand VARCHAR(100),
  dosage VARCHAR(50),
  stock_qty INT DEFAULT 0,
  price DECIMAL(10,2) DEFAULT 0.00,
  expiry_date DATE DEFAULT NULL,
  pharmacy_id INT,
  FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(pharmacy_id) ON DELETE SET NULL
);

-- TREATMENT RECORDS
CREATE TABLE treatment_records (
  record_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  doctor_id INT,
  date_of_treatment DATE DEFAULT (CURRENT_DATE),
  diagnosis TEXT,
  fees DECIMAL(10,2) DEFAULT 0.00,
  amount_paid DECIMAL(10,2) DEFAULT 0.00,
  is_billed TINYINT(1) DEFAULT 0,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL
);

-- PURCHASES
CREATE TABLE purchases (
  purchase_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  pharmacy_id INT,
  purchase_date DATE DEFAULT (CURRENT_DATE),
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE SET NULL,
  FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(pharmacy_id) ON DELETE SET NULL
);

-- PURCHASE ITEMS
CREATE TABLE purchase_items (
  purchase_item_id INT AUTO_INCREMENT PRIMARY KEY,
  purchase_id INT,
  item_id INT,
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE RESTRICT
);

-- PAYMENTS
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  bill_id VARCHAR(50) UNIQUE,
  patient_id INT,
  payment_date DATE DEFAULT (CURRENT_DATE),
  amount DECIMAL(10,2) NOT NULL,
  mode ENUM('Cash','Card','UPI') DEFAULT 'Cash',
  treatment_id INT,
  purchase_id INT,
  bill_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  balance_due DECIMAL(10,2) DEFAULT 0.00,
  remarks VARCHAR(255),
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE SET NULL,
  FOREIGN KEY (treatment_id) REFERENCES treatment_records(record_id) ON DELETE SET NULL,
  FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id) ON DELETE SET NULL
);

-- BILLS TABLE
CREATE TABLE bills (
  bill_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  treatment_id INT,
  purchase_id INT,
  total_amount DECIMAL(10,2) DEFAULT 0.00,
  mode ENUM('Cash','Card','UPI','Insurance') DEFAULT 'Cash',
  bill_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  remarks VARCHAR(255),
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
  FOREIGN KEY (treatment_id) REFERENCES treatment_records(record_id) ON DELETE SET NULL,
  FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id) ON DELETE SET NULL
);

-- PATIENT AUDIT TABLE
CREATE TABLE patient_audit (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  action VARCHAR(20),
  action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CREATE TRIGGERS
-- ============================================

DELIMITER $$

-- Trigger: After patient insert
CREATE TRIGGER after_patient_insert
AFTER INSERT ON patients
FOR EACH ROW
BEGIN
  INSERT INTO patient_audit (patient_id, action) VALUES (NEW.patient_id, 'INSERT');
END$$

-- Trigger: After payment insert (update treatment amount_paid)
CREATE TRIGGER after_payment_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
  IF NEW.treatment_id IS NOT NULL THEN
    UPDATE treatment_records
    SET amount_paid = IFNULL(amount_paid,0) + NEW.amount
    WHERE record_id = NEW.treatment_id;
  END IF;
END$$

-- Trigger: Before payment delete
CREATE TRIGGER before_payment_delete
BEFORE DELETE ON payments
FOR EACH ROW
BEGIN
  IF OLD.treatment_id IS NOT NULL THEN
    UPDATE treatment_records
    SET amount_paid = GREATEST(IFNULL(amount_paid,0) - OLD.amount, 0)
    WHERE record_id = OLD.treatment_id;
  END IF;
END$$

-- Trigger: After purchase item insert (decrease stock)
CREATE TRIGGER after_purchase_item_insert
AFTER INSERT ON purchase_items
FOR EACH ROW
BEGIN
  UPDATE items SET stock_qty = GREATEST(stock_qty - NEW.quantity, 0) WHERE item_id = NEW.item_id;
END$$

-- Trigger: After purchase item delete (increase stock back)
CREATE TRIGGER after_purchase_item_delete
AFTER DELETE ON purchase_items
FOR EACH ROW
BEGIN
  UPDATE items SET stock_qty = stock_qty + OLD.quantity WHERE item_id = OLD.item_id;
END$$

-- Trigger: Before payment insert (validate amount)
CREATE TRIGGER before_payment_insert
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
  IF NEW.amount < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount cannot be negative';
  END IF;
END$$

DELIMITER ;



-- DEPARTMENTS (6 unique)
INSERT INTO departments (dept_name, floor_no, dept_code) VALUES
('General Medicine', '1', 'GM01'),
('Pediatrics', '2', 'PD02'),
('Cardiology', '3', 'CD03'),
('Orthopedics', '2', 'OR04'),
('Dermatology', '1', 'DR05'),
('Pharmacy Department', 'Ground', 'PH01');

-- PATIENTS (8 unique with unique phones)
INSERT INTO patients (name, gender, phone, dob) VALUES
('Vivan Naik', 'Male', '9876543210', '2000-06-15'),
('Priya Sharma', 'Female', '9876543211', '1995-03-22'),
('Rahul Mehta', 'Male', '9876543212', '1988-11-30'),
('Anita Desai', 'Female', '9876543213', '2002-07-18'),
('Karan Singh', 'Male', '9876543214', '1992-09-05'),
('Sneha Patel', 'Female', '9876543215', '1998-12-10'),
('Arjun Kumar', 'Male', '9876543216', '2001-04-25'),
('Meera Reddy', 'Female', '9876543217', '1990-08-14');

-- DOCTORS (5 unique)
INSERT INTO doctors (name, specialization, phone, visiting_hours, department_id) VALUES
('Dr. Amit Sharma', 'General Medicine', '9123456780', '09:00 AM - 01:00 PM', 1),
('Dr. Sneha Kumar', 'Pediatrics', '9123456781', '10:00 AM - 02:00 PM', 2),
('Dr. Rajesh Patel', 'Cardiology', '9123456782', '02:00 PM - 06:00 PM', 3),
('Dr. Kavita Singh', 'Orthopedics', '9123456783', '09:00 AM - 01:00 PM', 4),
('Dr. Vikram Rao', 'Dermatology', '9123456784', '03:00 PM - 07:00 PM', 5);

-- PHARMACIES (2)
INSERT INTO pharmacies (name, location, operational_hours) VALUES
('Central Pharmacy', 'Ground Floor - Main Building', '08:00 AM - 08:00 PM'),
('Emergency Pharmacy', 'Ground Floor - Emergency Wing', '24 Hours');

-- PHARMACY ITEMS (15 items with expiry dates)
INSERT INTO items (item_name, brand, dosage, stock_qty, price, expiry_date, pharmacy_id) VALUES
-- Pain Relief (1 year expiry)
('Paracetamol', 'Calpol', '500mg', 200, 2.50, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 1),
('Ibuprofen', 'Brufen', '400mg', 150, 5.00, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 1),
('Aspirin', 'Disprin', '75mg', 180, 3.00, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 1),
-- Antibiotics (1 year expiry)
('Amoxicillin', 'Amoxil', '250mg', 120, 8.50, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 1),
('Azithromycin', 'Azithral', '500mg', 100, 12.00, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 1),
-- Cold & Cough (6 months expiry)
('Cough Syrup', 'Benadryl', '100ml', 80, 6.50, DATE_ADD(CURDATE(), INTERVAL 6 MONTH), 1),
('Cetirizine', 'Zyrtec', '10mg', 150, 4.00, DATE_ADD(CURDATE(), INTERVAL 6 MONTH), 1),
-- Digestive (6 months expiry)
('Antacid', 'Gelusil', '200ml', 90, 7.00, DATE_ADD(CURDATE(), INTERVAL 6 MONTH), 1),
('Omeprazole', 'Omez', '20mg', 110, 9.50, DATE_ADD(CURDATE(), INTERVAL 6 MONTH), 1),
-- Vitamins (6 months expiry)
('Vitamin C', 'Celin', '500mg', 200, 3.50, DATE_ADD(CURDATE(), INTERVAL 6 MONTH), 1),
('Multivitamin', 'Revital', 'Daily', 130, 15.00, DATE_ADD(CURDATE(), INTERVAL 2 YEAR), 1),
('Vitamin D3', 'Calcirol', '60000 IU', 95, 25.00, DATE_ADD(CURDATE(), INTERVAL 2 YEAR), 1),
-- Emergency Stock (2 years expiry)
('Bandage', 'Johnson', 'Standard', 250, 2.00, DATE_ADD(CURDATE(), INTERVAL 2 YEAR), 2),
('Antiseptic', 'Dettol', '100ml', 180, 4.50, DATE_ADD(CURDATE(), INTERVAL 2 YEAR), 2),
('Glucose Powder', 'Glucon-D', '500g', 75, 12.50, DATE_ADD(CURDATE(), INTERVAL 2 YEAR), 2);

-- TREATMENT RECORDS (8 records)
INSERT INTO treatment_records (patient_id, doctor_id, date_of_treatment, diagnosis, fees, amount_paid) VALUES
(1, 1, '2025-01-10', 'Seasonal Flu and Fever', 500.00, 500.00),
(2, 2, '2025-01-12', 'Routine Pediatric Checkup', 300.00, 0.00),
(3, 3, '2025-01-15', 'Chest Pain - ECG Done', 1200.00, 600.00),
(4, 5, '2025-01-18', 'Skin Rash and Allergy', 400.00, 400.00),
(5, 4, '2025-01-20', 'Knee Pain - X-Ray Required', 800.00, 300.00),
(6, 1, '2025-01-22', 'Migraine and Headache', 350.00, 0.00),
(7, 2, '2025-01-25', 'Child Vaccination', 250.00, 250.00),
(8, 3, '2025-01-28', 'High Blood Pressure Checkup', 600.00, 200.00);

-- PHARMACY PURCHASES (6 purchases)
INSERT INTO purchases (patient_id, pharmacy_id, purchase_date) VALUES (1, 1, '2025-01-10');
SET @purchase1_id = LAST_INSERT_ID();
INSERT INTO purchase_items (purchase_id, item_id, quantity, price) VALUES
(@purchase1_id, 1, 2, 2.50),
(@purchase1_id, 6, 1, 6.50);

INSERT INTO purchases (patient_id, pharmacy_id, purchase_date) VALUES (3, 1, '2025-01-15');
SET @purchase2_id = LAST_INSERT_ID();
INSERT INTO purchase_items (purchase_id, item_id, quantity, price) VALUES
(@purchase2_id, 4, 1, 8.50),
(@purchase2_id, 8, 1, 7.00);

INSERT INTO purchases (patient_id, pharmacy_id, purchase_date) VALUES (4, 1, '2025-01-18');
SET @purchase3_id = LAST_INSERT_ID();
INSERT INTO purchase_items (purchase_id, item_id, quantity, price) VALUES
(@purchase3_id, 7, 2, 4.00),
(@purchase3_id, 14, 1, 4.50);

INSERT INTO purchases (patient_id, pharmacy_id, purchase_date) VALUES (5, 1, '2025-01-20');
SET @purchase4_id = LAST_INSERT_ID();
INSERT INTO purchase_items (purchase_id, item_id, quantity, price) VALUES
(@purchase4_id, 2, 2, 5.00),
(@purchase4_id, 13, 1, 2.00);

INSERT INTO purchases (patient_id, pharmacy_id, purchase_date) VALUES (6, 1, '2025-01-22');
SET @purchase5_id = LAST_INSERT_ID();
INSERT INTO purchase_items (purchase_id, item_id, quantity, price) VALUES
(@purchase5_id, 10, 1, 3.50),
(@purchase5_id, 11, 1, 15.00);

INSERT INTO purchases (patient_id, pharmacy_id, purchase_date) VALUES (8, 1, '2025-01-28');
SET @purchase6_id = LAST_INSERT_ID();
INSERT INTO purchase_items (purchase_id, item_id, quantity, price) VALUES
(@purchase6_id, 3, 1, 3.00),
(@purchase6_id, 9, 1, 9.50);

-- PAYMENTS (12 total: 6 treatment + 6 pharmacy)
-- Treatment Payments
INSERT INTO payments (patient_id, treatment_id, purchase_id, amount, mode, remarks, payment_date) VALUES
(1, 1, NULL, 500.00, 'UPI', 'Full payment for flu treatment', '2025-01-10'),
(3, 3, NULL, 600.00, 'Card', 'Partial payment for cardiology consultation', '2025-01-15'),
(4, 4, NULL, 400.00, 'Cash', 'Full payment for dermatology treatment', '2025-01-18'),
(5, 5, NULL, 300.00, 'UPI', 'Partial payment for orthopedic consultation', '2025-01-20'),
(7, 7, NULL, 250.00, 'Card', 'Vaccination payment', '2025-01-25'),
(8, 8, NULL, 200.00, 'Cash', 'Partial payment for BP checkup', '2025-01-28');

-- Pharmacy Purchase Payments
INSERT INTO payments (patient_id, treatment_id, purchase_id, amount, mode, remarks, payment_date) VALUES
(1, NULL, @purchase1_id, 11.50, 'UPI', 'Pharmacy purchase - Flu medicines', '2025-01-10'),
(3, NULL, @purchase2_id, 15.50, 'Card', 'Pharmacy purchase - Antibiotics', '2025-01-15'),
(4, NULL, @purchase3_id, 12.50, 'Cash', 'Pharmacy purchase - Skin care', '2025-01-18'),
(5, NULL, @purchase4_id, 12.00, 'UPI', 'Pharmacy purchase - Pain relief', '2025-01-20'),
(6, NULL, @purchase5_id, 18.50, 'Card', 'Pharmacy purchase - Vitamins', '2025-01-22'),
(8, NULL, @purchase6_id, 12.50, 'Cash', 'Pharmacy purchase - BP medication', '2025-01-28');

-- ============================================
-- VERIFICATION
-- ============================================

SELECT '========================================' AS '';
SELECT 'DATABASE SETUP COMPLETE!' AS '';
SELECT '========================================' AS '';

SELECT 'Departments' AS Table_Name, COUNT(*) AS Count FROM departments
UNION ALL SELECT 'Patients', COUNT(*) FROM patients
UNION ALL SELECT 'Doctors', COUNT(*) FROM doctors
UNION ALL SELECT 'Pharmacies', COUNT(*) FROM pharmacies
UNION ALL SELECT 'Items', COUNT(*) FROM items
UNION ALL SELECT 'Treatments', COUNT(*) FROM treatment_records
UNION ALL SELECT 'Purchases', COUNT(*) FROM purchases
UNION ALL SELECT 'Purchase Items', COUNT(*) FROM purchase_items
UNION ALL SELECT 'Payments', COUNT(*) FROM payments;

SELECT '========================================' AS '';
SELECT 'You can now start the backend and frontend!' AS '';
SELECT '========================================' AS '';
