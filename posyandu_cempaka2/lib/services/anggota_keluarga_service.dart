import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:posyandu_cempaka2/models/kartu_keluarga.dart';

class AnggotaKeluargaService {
  static const String baseUrl = "http://192.168.1.5:5000/api";

  static Future<void> addAnggotaKeluarga(AnggotaKeluarga ak) async {
    final response = await http.post(
      Uri.parse("$baseUrl/anggota-keluarga"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(ak.toJson()),
    );

    if (response.statusCode == 201) {
      print("Data berhasil ditambahkan!");
    } else {
      throw Exception("Gagal menambahkan anggota keluarga: ${response.body}");
    }
  }
}
