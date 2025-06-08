import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posyandu_cempaka2/models/kartu_keluarga.dart';
import 'package:posyandu_cempaka2/services/anggota_keluarga_service.dart';
import 'package:posyandu_cempaka2/services/kartu_keluarga_service.dart';

class AddAnggotaForm extends StatefulWidget {
  final String kkId;
  final int jumlah;

  const AddAnggotaForm({required this.kkId, required this.jumlah, Key? key}) : super(key: key);

  @override
  _AddAnggotaFormState createState() => _AddAnggotaFormState();
}

class _AddAnggotaFormState extends State<AddAnggotaForm> {
  final _formKey = GlobalKey<FormState>();
  int currentIndex = 0;
  bool showReview = false;

  late List<Map<String, dynamic>> anggotaControllers;

  @override
  void initState() {
    super.initState();
    anggotaControllers = List.generate(widget.jumlah, (index) {
      return {
        'nama': TextEditingController(),
        'nik': TextEditingController(),
        'tanggal_lahir': TextEditingController(),
        'jenis_kelamin': null,
        'status_dalam_keluarga': null,
      };
    });
  }

  @override
  void dispose() {
    for (var ctrl in anggotaControllers) {
      ctrl['nama']?.dispose();
      ctrl['nik']?.dispose();
      ctrl['tanggal_lahir']?.dispose();
    }
    super.dispose();
  }

  Future<void> _selectTanggal(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      anggotaControllers[index]['tanggal_lahir']!.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _nextOrSubmit() {
    if (_formKey.currentState!.validate()) {
      if (currentIndex < widget.jumlah - 1) {
        setState(() {
          currentIndex++;
        });
      } else {
        setState(() {
          showReview = true;
        });
      }
    }
  }

  Future<void> _submitAllData() async {
    final data = anggotaControllers.map((ctrl) {
      return {
        'kk_id': widget.kkId,
        'nama': ctrl['nama']!.text,
        'nik': ctrl['nik']!.text,
        'tanggal_lahir': ctrl['tanggal_lahir']!.text,
        'jenis_kelamin': ctrl['jenis_kelamin'],
        'status_dalam_keluarga': ctrl['status_dalam_keluarga'],
      };
    }).toList();

    try {
      for (var anggota in data) {
        var anggotaObj = AnggotaKeluarga(
          kk_id: widget.kkId, 
          nama: anggota['nama'],
          nik: anggota['nik'],
          tanggal_lahir: DateTime.parse(anggota['tanggal_lahir']),
          jenis_kelamin: anggota['jenis_kelamin'],
          statusDalamKeluarga: anggota['status_dalam_keluarga'],
        );
        await AnggotaKeluargaService.addAnggotaKeluarga(anggotaObj);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data berhasil disimpan')),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  Future<bool> _handleBackPressed() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah kamu yakin ingin keluar? Data yang belum disimpan akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      try {
        await KartuKeluargaService.deleteKK(widget.kkId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data KK dibatalkan')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus KK: $e')),
        );
      }
      return true;
    }
    return false;
  }

  Widget _buildReviewScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Data Anggota')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: anggotaControllers.length,
        itemBuilder: (context, index) {
          final ctrl = anggotaControllers[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anggota ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Nama: ${ctrl['nama']!.text}'),
                  Text('NIK: ${ctrl['nik']!.text}'),
                  Text('Tanggal Lahir: ${ctrl['tanggal_lahir']!.text}'),
                  Text(
                    'Jenis Kelamin: ${ctrl['jenis_kelamin'] == 'L' ? 'Laki-laki' : ctrl['jenis_kelamin'] == 'P' ? 'Perempuan' : '-'}',
                  ),
                  Text('Status: ${ctrl['status_dalam_keluarga'] ?? "-"}'),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitAllData,
          child: const Text('Kirim Semua'),
        ),
      ),
    );
  }

  Widget _buildFormScreen() {
    final ctrl = anggotaControllers[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Anggota ${currentIndex + 1} dari ${widget.jumlah}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () async {
              final shouldExit = await _handleBackPressed();
              if (shouldExit) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: ctrl['nama'],
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            TextFormField(
              controller: ctrl['nik'],
              decoration: const InputDecoration(labelText: 'NIK'),
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.length != 16 ? 'Harus 16 digit' : null,
            ),
            TextFormField(
              controller: ctrl['tanggal_lahir'],
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tanggal Lahir',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectTanggal(currentIndex),
              validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
              value: ctrl['jenis_kelamin'],
              items: ['L', 'P'].map((jk) {
                return DropdownMenuItem(
                  value: jk,
                  child: Text(jk == 'L' ? 'Laki-laki' : 'Perempuan'),
                );
              }).toList(),
              onChanged: (val) => setState(() => ctrl['jenis_kelamin'] = val),
              validator: (val) => val == null ? 'Pilih jenis kelamin' : null,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Status dalam Keluarga'),
              value: ctrl['status_dalam_keluarga'],
              items: ['Kepala Keluarga', 'Istri', 'Anak', 'Lainnya'].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (val) => setState(() => ctrl['status_dalam_keluarga'] = val),
              validator: (val) => val == null ? 'Pilih status' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextOrSubmit,
              child: Text(
                currentIndex < widget.jumlah - 1 ? 'Selanjutnya' : 'Review Data',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _handleBackPressed();
          if (shouldPop) Navigator.of(context).pop();
        }
      },
      child: showReview ? _buildReviewScreen() : _buildFormScreen(),
    );
  }
}
