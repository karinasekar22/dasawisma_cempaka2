const { KartuKeluarga, AnggotaKeluarga } = require('../models');


exports.createKartuKeluarga = async (req, res) => {
  try {
    const data = await KartuKeluarga.create(req.body);
    res.status(201).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.getAllKartuKeluarga = async (req, res) => {
  try {
    const data = await KartuKeluarga.findAll({
      include: [{ model: AnggotaKeluarga, as: 'anggota' }]
    });
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.getKartuKeluargaById = async (req, res) => {
  try {
    const data = await KartuKeluarga.findByPk(req.params.id, {
      include: [{ model: AnggotaKeluarga, as: 'anggota' }]
    });

    if (!data) return res.status(404).json({ message: 'Data tidak ditemukan' });
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateKartuKeluarga = async (req, res) => {
  try {
    const data = await KartuKeluarga.findByPk(req.params.id);
    if (!data) return res.status(404).json({ message: 'Data tidak ditemukan' });

    await data.update(req.body);
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.deleteKartuKeluarga = async (req, res) => {
  try {
    const data = await KartuKeluarga.findByPk(req.params.id);
    if (!data) return res.status(404).json({ message: 'Data tidak ditemukan' });

    await data.destroy();
    res.status(200);
    res.json({ message: 'Data berhasil dihapus' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
