import 'package:flutter/material.dart';
import 'package:posyandu_cempaka2/models/kartu_keluarga.dart';
import 'add_anggota_form.dart';
import 'package:posyandu_cempaka2/services/kartu_keluarga_service.dart';

class AddKKForm extends StatefulWidget {
  final KartuKeluarga? existingKK;

  AddKKForm({Key? key, this.existingKK}) : super(key: key);

  @override
  _AddKKFormState createState() => _AddKKFormState();
}

class _AddKKFormState extends State<AddKKForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomorKKController = TextEditingController();
  final _alamatController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  final _teleponController = TextEditingController();
  final _jumlahAnggotaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingKK != null) {
      _nomorKKController.text = widget.existingKK!.nomorKK;
      _alamatController.text = widget.existingKK!.alamat;
      _rtController.text = widget.existingKK!.rt;
      _rwController.text = widget.existingKK!.rw ;
      _teleponController.text = widget.existingKK!.telepon;
      _jumlahAnggotaController.text = widget.existingKK!.anggota.length.toString();
    }
  }

  @override
  void dispose() {
    _nomorKKController.dispose();
    _alamatController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _teleponController.dispose();
    _jumlahAnggotaController.dispose();
    super.dispose();
  }

  void _submitKK() async {
    if (_formKey.currentState!.validate()) {
      final newKK = KartuKeluarga(
        nomorKK: _nomorKKController.text,
        alamat: _alamatController.text,
        rt: _rtController.text,
        rw: _rwController.text,
        telepon: _teleponController.text,
      );

      print('Data KK: $newKK');

      try {
        if (widget.existingKK == null) {
          final kkId = await KartuKeluargaService.addKartuKeluarga(newKK);
          final jumlahAnggota = int.parse(_jumlahAnggotaController.text);

          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) =>
                      AddAnggotaForm(kkId: kkId, jumlah: jumlahAnggota),
            ),
          );
          if (result == false) {
            // User cancelled, delete the KK data
            try {
              await KartuKeluargaService.deleteKK(kkId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data KK dibatalkan')),
              );
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Gagal menghapus KK: $e')));
            }
          }
        } else {
          // Update data existing
          await KartuKeluargaService.updateKartuKeluarga(
            widget.existingKK!.id!,
            newKK,
          );
          final jumlahAnggota = int.parse(_jumlahAnggotaController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diperbarui')),
          );
          final kk = await KartuKeluargaService.fetchKartuKeluargaById(
            widget.existingKK!.id!,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AddAnggotaForm(
                    kkId: widget.existingKK!.id!,
                    jumlah: jumlahAnggota,
                    existingAnggota: kk.anggota,
                  ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Kartu Keluarga')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomorKKController,
              decoration: InputDecoration(labelText: 'Nomor KK'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
            ),
            TextFormField(
              controller: _alamatController,
              decoration: InputDecoration(labelText: 'Alamat'),
              validator:
                  (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            TextFormField(
              controller: _rtController,
              decoration: InputDecoration(labelText: 'RT'),
              keyboardType: TextInputType.number,
              validator:
                  (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            TextFormField(
              controller: _rwController,
              decoration: InputDecoration(labelText: 'RW'),
              keyboardType: TextInputType.number,
              validator:
                  (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            TextFormField(
              controller: _teleponController,
              decoration: InputDecoration(labelText: 'Nomor Telepon'),
              keyboardType: TextInputType.phone,
              validator:
                  (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            TextFormField(
              controller: _jumlahAnggotaController,
              decoration: InputDecoration(labelText: 'Jumlah Anggota Keluarga'),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Wajib diisi';
                final jumlah = int.tryParse(val);
                if (jumlah == null || jumlah <= 0) {
                  return 'Harus angka lebih dari 0';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitKK,
              child: Text('Lanjut Isi Anggota'),
            ),
          ],
        ),
      ),
    );
  }
}
