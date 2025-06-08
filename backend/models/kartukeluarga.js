// models/KepalaKeluarga.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const KartuKeluarga = sequelize.define('KartuKeluarga', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  nomor_kk: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  alamat: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  rt: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  rw: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  telepon: {
    type: DataTypes.STRING,
    allowNull: true,
  },
}, {
  tableName: 'kartu_keluarga',
  timestamps: true,
});

module.exports = KartuKeluarga;
