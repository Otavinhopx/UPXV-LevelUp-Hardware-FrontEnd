import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Api {
  final String baseUrl;
  final storage = FlutterSecureStorage();

  Api(this.baseUrl);

  // =======================
  // AUTH
  // =======================
  Future<bool> register(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> registerWithName(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<String?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final token = body['token'] ?? body['access_token'] ?? body['accessToken'];

      if (token != null) {
        await storage.write(key: 'jwt', value: token);
        print("Login bem-sucedido! Token armazenado: $token");
        return token;
      }
    }

    print("Falha no login: ${res.statusCode} - ${res.body}");
    return null;
  }

  Future<void> logout() async => await storage.delete(key: 'jwt');

  Future<String?> getToken() async => await storage.read(key: 'jwt');

  // =======================
  // JWT CLAIMS
  // =======================
  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAdmin() async {
    final token = await getToken();
    if (token == null) return false;
    final payload = _decodeJwtPayload(token);
    if (payload == null) return false;

    final claim = payload['isAdmin'];
    if (claim == null) return false;
    if (claim is bool) return claim;
    if (claim is String) return claim.toLowerCase() == 'true';
    return false;
  }

  // =======================
  // PRODUCTS
  // =======================
  Future<List<dynamic>> getProducts() async {
    final res = await http.get(Uri.parse('$baseUrl/products'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  Future<Map<String, dynamic>?> getProduct(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  Future<bool> adminCreateProduct(Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null) return false;

    final res = await http.post(
      Uri.parse('$baseUrl/admin/products'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(body),
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> adminUpdateProduct(int id, Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null) return false;

    final res = await http.put(
      Uri.parse('$baseUrl/admin/products/$id'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(body),
    );

    return res.statusCode == 200;
  }

  Future<bool> adminDeleteProduct(int id) async {
    final token = await getToken();
    if (token == null) return false;

    final res = await http.delete(
      Uri.parse('$baseUrl/admin/products/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return res.statusCode == 200 || res.statusCode == 204;
  }

  // =======================
  // ARTICLES
  // =======================
  Future<List<dynamic>> getArticles() async {
    final res = await http.get(Uri.parse('$baseUrl/articles'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  Future<List<dynamic>> getArticlesForProduct(int productId) async {
    final res = await http.get(Uri.parse('$baseUrl/products/$productId/articles'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  Future<bool> adminCreateArticle(Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null) return false;

    final res = await http.post(
      Uri.parse('$baseUrl/admin/articles'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(body),
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> adminUpdateArticle(int id, Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null) return false;

    final res = await http.put(
      Uri.parse('$baseUrl/admin/articles/$id'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(body),
    );

    return res.statusCode == 200;
  }

  Future<bool> adminDeleteArticle(int id) async {
    final token = await getToken();
    if (token == null) return false;

    final res = await http.delete(
      Uri.parse('$baseUrl/admin/articles/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return res.statusCode == 200 || res.statusCode == 204;
  }

  Future<List<dynamic>> getAdminArticles() async {
  final token = await storage.read(key: 'jwt');

  final res = await http.get(
    Uri.parse('$baseUrl/admin/articles'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  }

  return [];
}

  Future<List<dynamic>> getReviews(int productId) async {
    final res = await http.get(Uri.parse('$baseUrl/products/$productId/reviews'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  Future<bool> createReview(int productId, int stars, String comment) async {
    final token = await getToken();
    if (token == null) {
      print("TOKEN NULO! Usuário não está logado.");
      return false;
    }

    print("Token usado no createReview: $token");

    final res = await http.post(
      Uri.parse('$baseUrl/products/$productId/reviews'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'stars': stars, 'comment': comment}),
    );

    print("Status code do createReview: ${res.statusCode}");
    print("Body do createReview: ${res.body}");

    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> deleteReview(int reviewId) async {
    final token = await getToken();
    if (token == null) {
      print("TOKEN NULO! Usuário não está logado.");
      return false;
    }

    print("Token usado no deleteReview: $token");

    final res = await http.delete(
      Uri.parse('$baseUrl/reviews/$reviewId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("Status code do deleteReview: ${res.statusCode}");
    print("Body do deleteReview: ${res.body}");

    return res.statusCode == 200 || res.statusCode == 204;
  }
}
