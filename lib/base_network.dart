import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class BaseNetwork {
  static const String _baseUrl = 'https://berita-indo-api-next.vercel.app';
  static final _logger = Logger();

  // Method untuk ambil semua berita
  static Future<List<Map<String, dynamic>>> getAll() async {
    final uri = Uri.parse("$_baseUrl/api/cnn-news");
    _logger.i("GET all: $uri");

    try {
      final response = await http.get(uri).timeout(Duration(seconds: 10));
      _logger.i("Response : ${response.statusCode}");
      _logger.t("Body : ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonObject = json.decode(response.body);
        final List<dynamic> jsonList = jsonObject['data'];
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        _logger.e("Error : ${response.statusCode}");
        throw Exception("Server Error : ${response.statusCode}");
      }
    } on TimeoutException {
      _logger.e("Request timeout : $uri");
      throw Exception("Request timeout");
    } catch (e) {
      _logger.e("Error fetching data from $uri : $e");
      throw Exception("Error fetching data : $e");
    }
  }

  // Method untuk ambil berita berdasarkan kategori
  static Future<List<Map<String, dynamic>>> getByCategory(
      String category) async {
    final uri = Uri.parse("$_baseUrl/api/cnn-news/$category");
    _logger.i("GET by Category: $uri");

    try {
      final response = await http.get(uri).timeout(Duration(seconds: 10));
      _logger.i("Response : ${response.statusCode}");
      _logger.t("Body : ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonObject = json.decode(response.body);
        final List<dynamic> jsonList = jsonObject['data'];
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        _logger.e("Error : ${response.statusCode}");
        throw Exception("Server Error : ${response.statusCode}");
      }
    } on TimeoutException {
      _logger.e("Request timeout : $uri");
      throw Exception("Request timeout");
    } catch (e) {
      _logger.e("Error fetching data from $uri : $e");
      throw Exception("Error fetching data : $e");
    }
  }
}
