const { AnggotaKeluarga } = require("../models");

//mencari umur
function getAgeInYears(tanggal_lahir) {
  const today = new Date();
  const birth = new Date(tanggal_lahir);
  let umur = today.getFullYear() - birth.getFullYear();
  const m = today.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) {
    umur--;
  }
  return umur;
}

//mencari umur kehamilan dengan hpht
function hitungUsiaKandungan(hpht) {
  const mulaiHaid = new Date(hpht);
  if (isNaN(mulaiHaid)) return 0;

  const today = new Date();
  const selisihHari = (today - mulaiHaid) / (1000 * 60 * 60 * 24); // hari
  return Math.floor(selisihHari / 7);
}

//mencari istri suami dalam satu kk, dan pengecekan apakah dia dalam usia subur
async function updateKategoriPasanganUsiaSubur(kk_id) {
  const kepala = await AnggotaKeluarga.findOne({
    where: { kk_id, status_dalam_keluarga: "Kepala Keluarga" },
  });

  const istri = await AnggotaKeluarga.findOne({
    where: { kk_id, status_dalam_keluarga: "Istri" },
  });

  if (!kepala || !istri) return;

  const today = new Date();
  const umurKepala = kepala.tanggal_lahir
    ? getAgeInYears(kepala.tanggal_lahir)
    : null;
  const umurIstri = istri.tanggal_lahir
    ? getAgeInYears(istri.tanggal_lahir)
    : null;

  if (
    umurKepala !== null &&
    umurIstri !== null &&
    umurKepala >= 15 &&
    umurKepala <= 49 &&
    umurIstri >= 15 &&
    umurIstri <= 49
  ) {
    await kepala.update({ kategori: "Pasangan Usia Subur" });
    await istri.update({ kategori: "Pasangan Usia Subur" });
  }
}

//mencari kategori otomatis dengan umur
async function getKategoriOtomatis(anggota) {
  try {
    if (!anggota.tanggal_lahir) return "";

    const today = new Date();
    const lahir = new Date(anggota.tanggal_lahir);
    if (isNaN(lahir)) return "";

    let umurTahun = today.getFullYear() - lahir.getFullYear();
    let umurBulan = today.getMonth() - lahir.getMonth();

    if (umurBulan < 0) {
      umurTahun--;
      umurBulan += 12;
    }

    const totalUmurBulan = umurTahun * 12 + umurBulan;
    let usiaKandungan = anggota.usia_kandungan || 0;

    if (anggota.hpht) {
      usiaKandungan = hitungUsiaKandungan(anggota.hpht);
    }

    const status = anggota.status_dalam_keluarga
      ? anggota.status_dalam_keluarga.toLowerCase()
      : "";

    if (anggota.hamil && usiaKandungan > 0) return "Ibu Hamil";
    if (totalUmurBulan <= 60) return "Balita";
    if (umurTahun >= 50 && umurTahun <= 59) return "Pra Lansia";
    if (umurTahun >= 60) return "Lansia";
    if (
      umurTahun >= 15 &&
      umurTahun <= 49 &&
      ["istri", "kepala keluarga"].includes(status)
    )
      return "Pasangan Usia Subur";

    return "";
  } catch (error) {
    console.log("Error get category!", error);
    return "";
  }
}

exports.createAnggota = async (req, res) => {
  try {
    const usiaKandungan = req.body.hpht
      ? hitungUsiaKandungan(req.body.hpht)
      : req.body.usia_kandungan || 0;
    const anggotaWithUsia = { ...req.body, usia_kandungan: usiaKandungan };

    const kategori = await getKategoriOtomatis(anggotaWithUsia);
    const data = await AnggotaKeluarga.create({ ...anggotaWithUsia, kategori });

    if (kategori === "Pasangan Usia Subur") {
      await updateKategoriPasanganUsiaSubur(data.kk_id);
    }

    const updatedData = await AnggotaKeluarga.findByPk(data.id);
    res.status(201).json(updatedData);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getAllAnggota = async (req, res) => {
  try {
    const data = await AnggotaKeluarga.findAll();
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getAnggotaById = async (req, res) => {
  try {
    const data = await AnggotaKeluarga.findByPk(req.params.id);
    if (!data) return res.status(404).json({ message: "Data tidak ditemukan" });
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateAnggota = async (req, res) => {
  try {
    const data = await AnggotaKeluarga.findByPk(req.params.id);
    if (!data) return res.status(404).json({ message: "Data tidak ditemukan" });

    const updatedData = { ...data.toJSON(), ...req.body };
    const usiaKandungan = updatedData.hpht
      ? hitungUsiaKandungan(updatedData.hpht)
      : updatedData.usia_kandungan || 0;

    const kategori = await getKategoriOtomatis({
      ...updatedData,
      usia_kandungan: usiaKandungan,
    });

    await data.update({
      ...req.body,
      kategori,
      usia_kandungan: usiaKandungan,
    });

    await updateKategoriPasanganUsiaSubur(data.kk_id);

    const refreshedData = await AnggotaKeluarga.findByPk(data.id);

    res.json(refreshedData);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.deleteAnggota = async (req, res) => {
  try {
    const data = await AnggotaKeluarga.findByPk(req.params.id);
    if (!data) return res.status(404).json({ message: "Data tidak ditemukan" });

    await data.destroy();
    res.status(200).json({ message: 'Data berhasil dihapus' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
