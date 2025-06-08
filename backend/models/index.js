const sequelize = require('../config/database');
const KartuKeluarga = require('./kartukeluarga');
const AnggotaKeluarga = require('./anggotakeluarga');

KartuKeluarga.hasMany(AnggotaKeluarga, {
  foreignKey: 'kk_id',
  as: 'anggota',
  onDelete: 'CASCADE',
});

AnggotaKeluarga.belongsTo(KartuKeluarga, {
  foreignKey: 'kk_id',
  as: 'kartu_keluarga',
});

const db = {
  sequelize,
  KartuKeluarga,
  AnggotaKeluarga,
};

module.exports = db;
