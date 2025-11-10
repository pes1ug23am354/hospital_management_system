#!/bin/bash
# ========================================
# DATABASE VIEW COMMANDS
# ========================================
# Run this script to view all database tables and their contents
# Usage: bash view_database.sh

echo "========================================="
echo "PHARMACY DATABASE - ALL TABLES"
echo "========================================="

# Show all tables
echo -e "\n📋 ALL TABLES IN DATABASE:"
mysql -u root -p pharmacy_new -e "SHOW TABLES;"

# Departments
echo -e "\n========== DEPARTMENTS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM departments;"

# Patients
echo -e "\n========== PATIENTS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM patients;"

# Doctors
echo -e "\n========== DOCTORS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM doctors;"

# Pharmacies
echo -e "\n========== PHARMACIES =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM pharmacies;"

# Items
echo -e "\n========== ITEMS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM items;"

# Products
echo -e "\n========== PRODUCTS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM products;"

# Categories
echo -e "\n========== CATEGORIES =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM categories;"

# Inventory
echo -e "\n========== INVENTORY =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM inventory;"

# Treatment Records
echo -e "\n========== TREATMENT RECORDS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM treatment_records;"

# Purchases
echo -e "\n========== PURCHASES =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM purchases;"

# Purchase Items
echo -e "\n========== PURCHASE ITEMS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM purchase_items;"

# Sales
echo -e "\n========== SALES =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM sales;"

# Sale Items
echo -e "\n========== SALE ITEMS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM sale_items;"

# Bills
echo -e "\n========== BILLS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM bills;"

# Payments
echo -e "\n========== PAYMENTS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM payments;"

# Users
echo -e "\n========== USERS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM users;"

# Inventory Movements
echo -e "\n========== INVENTORY MOVEMENTS =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM inventory_movements;"

# Patient Audit
echo -e "\n========== PATIENT AUDIT =========="
mysql -u root -p pharmacy_new -e "SELECT * FROM patient_audit;"

# Table counts
echo -e "\n========== TABLE ROW COUNTS =========="
mysql -u root -p pharmacy_new -e "
SELECT table_name AS 'Table', table_rows AS 'Rows' 
FROM information_schema.tables 
WHERE table_schema = 'pharmacy_new' 
ORDER BY table_name;"

echo -e "\n========================================="
echo "✅ DATABASE VIEW COMPLETE"
echo "========================================="
