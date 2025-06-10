class AnggotaKeluarga {
  final String? id;
  final String? kk_id;
  final String nama;
  final String nik;
  final DateTime tanggal_lahir;
  final String jenis_kelamin;
  final String? kategori;
  final bool? hamil;
  final DateTime? hpht;
  final int? usiaKandungan;
  final String statusDalamKeluarga;

  AnggotaKeluarga({
    this.id,
    this.kk_id,
    required this.nama,
    required this.nik,
    required this.tanggal_lahir,
    required this.jenis_kelamin,
    this.kategori,
    this.hamil,
    this.hpht,
    this.usiaKandungan,
    required this.statusDalamKeluarga,
  });

  factory AnggotaKeluarga.fromJson(Map<String, dynamic> json) {
    return AnggotaKeluarga(
      id: json['id'],
      kk_id: json['kk_id'],
      nama: json['nama'],
      nik: json['nik'],
      tanggal_lahir: DateTime.parse(json['tanggal_lahir'] as String),
      jenis_kelamin: json['jenis_kelamin'] == 'P' ? 'Perempuan' : 'Laki-laki',
      kategori: json['kategori'],
      hamil: json['hamil'],
      hpht: json['hpht'] != null ? DateTime.parse(json['hpht'] as String) : null,
      usiaKandungan:
          json['usia_kandungan'] != null
              ? int.tryParse(json['usia_kandungan'].toString())
              : null,
      statusDalamKeluarga: json['status_dalam_keluarga'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kk_id': kk_id,
      'nama': nama,
      'nik': nik,
      'tanggal_lahir': tanggal_lahir.toIso8601String(),
      'jenis_kelamin': jenis_kelamin,
      'kategori': kategori,
      'status_dalam_keluarga': statusDalamKeluarga,
      'hamil': hamil,
      'hpht': hamil == true && hpht != null ? hpht!.toIso8601String() : null,
    };
  }
}

class KartuKeluarga {
  final String? id;
  final String nomorKK;
  final String alamat;
  final String rt;
  final String rw;
  final String telepon;
  final List<AnggotaKeluarga> anggota;

  KartuKeluarga({
    this.id,
    required this.nomorKK,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.telepon,
    this.anggota = const [],
  });

  factory KartuKeluarga.fromJson(Map<String, dynamic> json) {
    var anggotaList =
        (json['anggota'] as List)
            .map((a) => AnggotaKeluarga.fromJson(a))
            .toList();

    return KartuKeluarga(
      id: json['id'],
      nomorKK: json['nomor_kk'],
      alamat: json['alamat'],
      rt: json['rt'],
      rw: json['rw'],
      telepon: json['telepon'],
      anggota: anggotaList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor_kk': nomorKK,
      'alamat': alamat,
      'rt': rt,
      'rw': rw,
      'telepon': telepon,
    };
  }

  AnggotaKeluarga? get kepalaKeluarga {
    try {
      return anggota.firstWhere(
        (a) => a.statusDalamKeluarga.toLowerCase() == "kepala keluarga",
      );
    } catch (e) {
      return null;
    }
  }
}
