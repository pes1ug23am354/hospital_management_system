// backend/server.js
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// routers
const authRouter = require('./routes/auth');
const patientsRouter = require('./routes/patients');
const doctorsRouter = require('./routes/doctors');
const deptsRouter = require('./routes/departments');
const pharmacyRouter = require('./routes/pharmacy');
const treatmentsRouter = require('./routes/treatments');
const paymentsRouter = require('./routes/payments');
const billsRouter = require('./routes/bills'); // optional if you have it
const purchasesRouter = require('./routes/purchases');

app.use('/api/auth', authRouter);
app.use('/api/patients', patientsRouter);
app.use('/api/doctors', doctorsRouter);
app.use('/api/departments', deptsRouter);
app.use('/api/pharmacy', pharmacyRouter);
app.use('/api/treatments', treatmentsRouter);
app.use('/api/payments', paymentsRouter);
app.use('/api/bills', billsRouter);
app.use('/api/purchases', purchasesRouter);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log('✅ Backend running on port', PORT));
