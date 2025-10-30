import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Api {
  final String baseUrl;
  final storage = FlutterSecureStorage();

  Api(this.baseUrl);

  Future<bool> register(String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<String?> login(String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final token =
          body['token'] ?? body['access_token'] ?? body['accessToken'];
      if (token != null) {
        await storage.write(key: 'jwt', value: token);
        return token;
      }
    }
    return null;
  }

  Future<List<dynamic>> getProducts() async {
    final res = await http.get(Uri.parse('$baseUrl/products'));
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    return [];
  }

  Future<Map<String, dynamic>?> getProduct(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    return null;
  }

  Future<bool> adminCreateProduct(Map<String, dynamic> body) async {
    final token = await storage.read(key: 'jwt');
    final res = await http.post(Uri.parse('$baseUrl/admin/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(body));
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> adminDeleteProduct(int id) async {
    final token = await storage.read(key: 'jwt');
    final res = await http.delete(Uri.parse('$baseUrl/admin/products/$id'),
        headers: {'Authorization': 'Bearer $token'});
    return res.statusCode == 200 || res.statusCode == 204;
  }

  Future<List<dynamic>> getArticles() async {
    final res = await http.get(Uri.parse('$baseUrl/articles'));
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    return [];
  }
}
