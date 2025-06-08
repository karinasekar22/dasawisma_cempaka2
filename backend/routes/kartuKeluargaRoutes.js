const express = require('express');
const router = express.Router();
const kartuKeluargaController = require('../controllers/kartuKeluargaController');


router.post('/', kartuKeluargaController.createKartuKeluarga);

router.get('/', kartuKeluargaController.getAllKartuKeluarga);

router.get('/:id', kartuKeluargaController.getKartuKeluargaById);

router.put('/:id', kartuKeluargaController.updateKartuKeluarga);

router.delete('/:id', kartuKeluargaController.deleteKartuKeluarga);

module.exports = router;
