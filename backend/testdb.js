const db = require('./db');

(async ()=> {
  try {
    const [rows] = await db.query('SELECT 1+1 AS result');
    console.log('DB OK', rows);
    process.exit(0);
  } catch (e) {
    console.error('DB test failed', e);
    process.exit(1);
  }
})();
