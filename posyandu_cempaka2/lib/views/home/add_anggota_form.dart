import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posyandu_cempaka2/models/kartu_keluarga.dart';
import 'package:posyandu_cempaka2/services/anggota_keluarga_service.dart';
import 'package:posyandu_cempaka2/services/kartu_keluarga_service.dart';

class AddAnggotaForm extends StatefulWidget {
  final String kkId;
  final int jumlah;
  final List<AnggotaKeluarga>? existingAnggota;

  const AddAnggotaForm({
    Key? key,
    required this.kkId,
    required this.jumlah,
    this.existingAnggota,
  }) : super(key: key);

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
      if (index < (widget.existingAnggota?.length ?? 0)) {
        //Editing
        var existing = widget.existingAnggota![index];
        return {
          'id': existing.id,
          'nama': TextEditingController(text: existing.nama),
          'nik': TextEditingController(text: existing.nik),
          'tanggal_lahir': TextEditingController(
            text: DateFormat('yyyy-MM-dd').format(existing.tanggal_lahir),
          ),
          'jenis_kelamin': existing.jenis_kelamin == 'Perempuan' ? 'P' : 'L',
          'status_dalam_keluarga': existing.statusDalamKeluarga,
          'hamil': existing.hamil == true ? 'Ya' : 'Tidak',
          'hpht': TextEditingController(
            text:
                existing.hpht != null
                    ? DateFormat('yyyy-MM-dd').format(existing.hpht!)
                    : '',
          ),
          'isExisting': true,
        };
      } else {
        // Add data baru
        return {
          'nama': TextEditingController(),
          'nik': TextEditingController(),
          'tanggal_lahir': TextEditingController(),
          'jenis_kelamin': null,
          'status_dalam_keluarga': null,
          'hamil': null,
          'hpht': TextEditingController(),
          'isExisting': false,
        };
      }
    });
  }

  @override
  void dispose() {
    for (var ctrl in anggotaControllers) {
      ctrl['nama']?.dispose();
      ctrl['nik']?.dispose();
      ctrl['tanggal_lahir']?.dispose();
      ctrl['hpht']?.dispose();
    }
    super.dispose();
  }

  //Untuk Datepicker Tanggal Lahir
  Future<void> _selectTanggal(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2025),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      anggotaControllers[index]['tanggal_lahir']!.text = DateFormat(
        'yyyy-MM-dd',
      ).format(picked);
    }
  }

  //untuk Datepicker HPHT
  Future<void> _selectHPHT(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2025),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      anggotaControllers[index]['hpht']!.text = DateFormat(
        'yyyy-MM-dd',
      ).format(picked);
    }
  }

  void _nextOrSubmit() {
    print('Validasi form dijalankan. currentIndex: $currentIndex');
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
    final data =
        anggotaControllers.map((ctrl) {
          return {
            'id': ctrl['id'],
            'kk_id': widget.kkId,
            'nama': ctrl['nama']!.text,
            'nik': ctrl['nik']!.text,
            'tanggal_lahir': ctrl['tanggal_lahir']!.text,
            'jenis_kelamin': ctrl['jenis_kelamin'],
            'status_dalam_keluarga': ctrl['status_dalam_keluarga'],
            'hamil': ctrl['hamil'] == 'Ya' ? true : false,
            'hpht':
                ctrl['hpht'] != null && ctrl['hpht']!.text.isNotEmpty
                    ? DateTime.tryParse(ctrl['hpht']!.text)?.toIso8601String()
                    : null,
            'isExisting': ctrl['isExisting'],
          };
        }).toList();

    try {
      for (var anggotaData in data) {
        var anggota = AnggotaKeluarga(
          id: anggotaData['id'],
          kk_id: widget.kkId,
          nama: anggotaData['nama'],
          nik: anggotaData['nik'],
          tanggal_lahir: DateTime.parse(anggotaData['tanggal_lahir']),
          jenis_kelamin: anggotaData['jenis_kelamin'],
          statusDalamKeluarga: anggotaData['status_dalam_keluarga'],
          hamil: anggotaData['hamil'],
          hpht:
              anggotaData['hpht'] != null
                  ? DateTime.parse(anggotaData['hpht'])
                  : null,
        );
        if (anggotaData['isExisting'] == true) {
          await AnggotaKeluargaService.updateAnggotaKeluarga(anggota);
        } else {
          await AnggotaKeluargaService.addAnggotaKeluarga(anggota);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data berhasil disimpan')),
      );
      Navigator.of(
        context,
      ).popUntil((route) => route.isFirst); // Kembali ke homescreen
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    }
  }

  Future<bool> _handleBackPressed() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text(
              'Apakah kamu yakin ingin keluar? Data yang belum disimpan akan hilang.',
            ),
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
    return shouldExit ?? false;
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
                    'Jenis Kelamin: ${ctrl['jenis_kelamin'] == 'L'
                        ? 'Laki-laki'
                        : ctrl['jenis_kelamin'] == 'P'
                        ? 'Perempuan'
                        : '-'}',
                  ),
                  Text('Status: ${ctrl['status_dalam_keluarga'] ?? "-"}'),
                  if (ctrl['status_dalam_keluarga'] == 'Istri')
                    Text('Hamil: ${ctrl['hamil'] ?? "-"}'),
                  if (ctrl['hamil'] == 'Ya')
                    Text('HPHT: ${ctrl['hpht']!.text}'),
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
              validator:
                  (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            TextFormField(
              controller: ctrl['nik'],
              decoration: const InputDecoration(labelText: 'NIK'),
              keyboardType: TextInputType.number,
              validator:
                  (val) =>
                      val == null || val.length != 16 ? 'Harus 16 digit' : null,
            ),
            TextFormField(
              controller: ctrl['tanggal_lahir'],
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tanggal Lahir',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectTanggal(currentIndex),
              validator:
                  (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
              value: ctrl['jenis_kelamin'],
              items:
                  ['L', 'P'].map((jk) {
                    return DropdownMenuItem(
                      value: jk,
                      child: Text(jk == 'L' ? 'Laki-laki' : 'Perempuan'),
                    );
                  }).toList(),
              onChanged: (val) => setState(() => ctrl['jenis_kelamin'] = val),
              validator: (val) => val == null ? 'Pilih jenis kelamin' : null,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Status dalam Keluarga',
              ),
              value: ctrl['status_dalam_keluarga'],
              items:
                  ['Kepala Keluarga', 'Istri', 'Anak', 'Lainnya'].map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
              onChanged:
                  (val) => setState(() => ctrl['status_dalam_keluarga'] = val),
              validator: (val) => val == null ? 'Pilih status' : null,
            ),
            if (ctrl['status_dalam_keluarga'] == 'Istri') ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sedang Hamil?'),
                value: ctrl['hamil'],
                items:
                    ['Ya', 'Tidak'].map((val) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                onChanged: (val) {
                  setState(() {
                    ctrl['hamil'] = val;
                    if (val == 'Tidak') {
                      ctrl['hpht']?.text = '';
                    }
                  });
                },
                validator: (val) => val == null ? 'Pilih salah satu' : null,
              ),
              if (ctrl['hamil'] == 'Ya')
                TextFormField(
                  controller: ctrl['hpht'],
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'HPHT',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _selectHPHT(currentIndex),
                  validator: (val) {
                    if (ctrl['hamil'] == 'Ya' && (val == null || val.isEmpty)) {
                      return 'HPHT wajib diisi!';
                    }
                    return null;
                  },
                ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextOrSubmit,
              child: Text(
                currentIndex < widget.jumlah - 1
                    ? 'Selanjutnya'
                    : 'Review Data',
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
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await _handleBackPressed();
          if (shouldExit) Navigator.of(context).pop(false);
        }
      },
      child: showReview ? _buildReviewScreen() : _buildFormScreen(),
    );
  }
}
