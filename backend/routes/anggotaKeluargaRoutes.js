const express = require('express');
const router = express.Router();
const anggotaKeluargaController = require('../controllers/anggotaKeluargaController');

router.post('/', anggotaKeluargaController.createAnggota);

router.get('/', anggotaKeluargaController.getAllAnggota);

router.get('/:id', anggotaKeluargaController.getAnggotaById);

router.put('/:id', anggotaKeluargaController.updateAnggota);

router.delete('/:id', anggotaKeluargaController.deleteAnggota);

module.exports = router;
