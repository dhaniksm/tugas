import 'package:flutter/material.dart';
import 'package:tugas/models/product_model.dart';
import 'package:tugas/services/api_service.dart';
import 'package:tugas/widgets/product_card.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';
import 'submit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final apiService = ApiService();

  bool isLoading = true;
  String errorMessage = '';
  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<void> getProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await apiService.getProducts();
      if (!mounted) return;
      setState(() {
        products = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
      });
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> logout() async {
    await apiService.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> bukaTambahProduk() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );

    if (hasil == true) {
      getProducts();
    }
  }

  void bukaSubmitTugas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubmitTaskScreen()),
    );
  }

  Widget tampilkanBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(errorMessage),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Text('Belum ada produk'),
      );
    }

    return RefreshIndicator(
      onRefresh: getProducts,
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: [
          IconButton(
            onPressed: bukaSubmitTugas,
            icon: const Icon(Icons.send),
            tooltip: 'Submit Tugas',
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: tampilkanBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: bukaTambahProduk,
        child: const Icon(Icons.add),
      ),
    );
  }
}
