const express = require('express');
const cors = require('cors');
require('dotenv').config();
const sequelize = require('./config/database');
const path = require('path');
require('./models/index');

const anggotaKeluargaRoutes = require('./routes/anggotaKeluargaRoutes');
const kartuKeluargaRoutes = require('./routes/kartuKeluargaRoutes');

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());

sequelize.sync({ alter: true }) 
  .then(() => {
    console.log('Connected to database PostgreSQL!');
  })
  .catch((err) => {
    console.error('DB Error:', err);
  });

app.use('/api/anggota-keluarga', anggotaKeluargaRoutes);
app.use('/api/kartu-keluarga', kartuKeluargaRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server nyala di http://localhost:${PORT}`);
});
