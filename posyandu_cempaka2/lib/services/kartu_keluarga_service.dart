import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:posyandu_cempaka2/models/kartu_keluarga.dart';

class KartuKeluargaService {
  static const String baseUrl = "http://192.168.1.5:5000/api";

  static Future<List<KartuKeluarga>> fetchKartuKeluarga() async {
    final response = await http.get(Uri.parse("$baseUrl/kartu-keluarga"));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => KartuKeluarga.fromJson(e)).toList();
    } else {
      throw Exception("Gagal memuat data kartu keluarga");
    }
  }

  static Future<String> addKartuKeluarga(KartuKeluarga kk) async {
    final response = await http.post(
      Uri.parse("$baseUrl/kartu-keluarga"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(kk.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception("Gagal menambahkan kartu keluarga: ${response.body}");
    }
  }

  static Future<void> deleteKK(String kkId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/kartu-keluarga/$kkId"),
       headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal hapus KK: ${response.body}");
    }
  }

}
