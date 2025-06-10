// models/AnggotaKeluarga.js
const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const AnggotaKeluarga = sequelize.define(
  "AnggotaKeluarga",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    kk_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    nama: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    nik: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    tanggal_lahir: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    jenis_kelamin: {
      type: DataTypes.ENUM("L", "P"),
      allowNull: false,
    },
    status_dalam_keluarga: {
      type: DataTypes.ENUM(
        "Kepala Keluarga",
        "Istri",
        "Anak",
        "Cucu",
        "Orang Tua",
        "Menantu",
        "Orang Lain"
      ),
      allowNull: false,
    },
    kategori: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    hamil: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    hpht: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    usia_kandungan: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
  },
  {
    tableName: "anggota_keluarga",
    timestamps: true,
  }
);

module.exports = AnggotaKeluarga;
