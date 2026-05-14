import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas/models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] ??
          data['access_token'] ??
          data['data']?['token'] ??
          data['data']?['access_token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return true;
      }
    }

    return false;
  }

  Future<List<ProductModel>> getProducts() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/products');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List listProduk = ambilListProduk(data);

      return listProduk.map((item) {
        return ProductModel.fromJson(item);
      }).toList();
    } else {
      throw Exception('Gagal mengambil data produk');
    }
  }

  List ambilListProduk(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        return data['data'];
      }

      if (data['products'] is List) {
        return data['products'];
      }

      if (data['data'] is Map<String, dynamic>) {
        final isiData = data['data'];

        if (isiData['products'] is List) {
          return isiData['products'];
        }

        if (isiData['data'] is List) {
          return isiData['data'];
        }
      }
    }

    return [];
  }

  Future<bool> addProduct(ProductModel product) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/products');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(product.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> submitTask(ProductModel product, String githubUrl) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/products/submit');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'github_url': githubUrl,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
