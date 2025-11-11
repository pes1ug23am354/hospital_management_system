# Daycare Hospital Management System

A full-stack hospital daycare management system designed to manage patients, doctors, treatments, pharmacy inventory, purchases, billing, and payments. The project uses a MySQL-backed REST API (Node.js + Express) with a React-based frontend UI.

---

## 🔥 Key Features

### 🏥 Hospital Data Management
- Manage **Departments** (name, floor, code)
- Manage **Doctors** (specialization, visiting hours, department mapped)
- Manage **Patients** with unique phone numbers and automatic audit tracking

### 👩‍⚕️ Treatment Records
- Record diagnosis, doctor, fees, and date of treatment
- Tracks **amount paid** and **remaining balance** automatically
- Supports patient-wise financial summaries

### 💊 Pharmacy Inventory & Billing
- Manage **medicine stock** (price, expiry, brand, quantity)
- Create **pharmacy purchases** with **multiple item entries**
- Stock quantity adjusts **automatically** on purchase creation/deletion

### 💰 Payments & Invoices
- Payments can be made **per treatment** or **per pharmacy purchase**
- Balances automatically update via **database triggers**
- View all payments and outstanding balances per patient

### 📊 Dashboards
- Summary cards for revenue earned and pending
- Doctor-wise, patient-wise and item-wise lookup and filtering

---

## 🏗️ System Architecture

| Component | Technology |
|----------|------------|
| Frontend | React, Axios, Material UI, Recharts |
| Backend  | Node.js, Express, MySQL2, CORS, Dotenv |
| Database | MySQL 8.x |
| Tools    | npm, VS Code, MySQL Workbench |

The backend exposes structured REST APIs that the frontend consumes using Axios.

---

## 🗄️ Database Design

### ✔ Schema Includes
- departments
- patients
- doctors
- pharmacies
- items (pharmacy inventory)
- treatment_records
- purchases + purchase_items
- bills
- payments
- patient_audit (trigger-based logging)

### 🔥 Triggers Used
| Trigger Name | Purpose |
|-------------|---------|
| `after_patient_insert` | Logs patient creation into audit table |
| `after_payment_insert` | Updates treatment amount_paid automatically |
| `before_payment_delete` | Rolls back fees if a payment is removed |
| `after_purchase_item_insert` | Reduces item stock automatically |
| `after_purchase_item_delete` | Restores stock when removed |

### 🧠 Stored Procedure + Function
- `add_treatment_with_payment(...)`
- `get_patient_balance(patient_id)`

---

