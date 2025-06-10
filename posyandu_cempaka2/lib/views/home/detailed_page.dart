import 'package:flutter/material.dart';
import 'package:posyandu_cempaka2/models/kartu_keluarga.dart';
import 'package:intl/intl.dart';

int hitungUmur(DateTime tanggalLahir) {
  final today = DateTime.now();
  int umur = today.year - tanggalLahir.year;

  if (today.month < tanggalLahir.month ||
      (today.month == tanggalLahir.month && today.day < tanggalLahir.day)) {
    umur--;
  }

  return umur;
}

class DetailKKPage extends StatelessWidget {

  final KartuKeluarga kk;
  const DetailKKPage({super.key, required this.kk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail KK: ${kk.nomorKK}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nomor KK: ${kk.nomorKK}", style: TextStyle(fontSize: 18)),
            Text("Alamat: ${kk.alamat}, RT ${kk.rt}/RW ${kk.rw}"),
            Text("Telepon: ${kk.telepon}"),
            SizedBox(height: 16),
            Text(
              "Anggota Keluarga:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: kk.anggota.length,
                itemBuilder: (context, index) {
                  final anggota = kk.anggota[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: ListTile(
                      title: Text(
                        anggota.statusDalamKeluarga,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("NIK: ${anggota.nik}"),
                          Text("Nama Lengkap: ${anggota.nama}"),
                          Text(
                            "Tanggal Lahir: ${DateFormat('dd-MM-yyyy').format(anggota.tanggal_lahir)}",
                          ),
                          Text(
                            "Umur: ${hitungUmur(anggota.tanggal_lahir)} tahun",
                          ),
                    
                          Text("Jenis Kelamin: ${anggota.jenis_kelamin}"),
                          Text("Kategori: ${anggota.kategori}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
