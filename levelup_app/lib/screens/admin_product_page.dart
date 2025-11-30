import 'package:flutter/material.dart';
import '../services/api.dart';
import 'admin_product_form.dart';

class AdminProductPage extends StatefulWidget {
  final Api api;
  const AdminProductPage({super.key, required this.api});

  @override
  State<AdminProductPage> createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  List products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final p = await widget.api.getProducts();
    setState(() {
      products = p;
      loading = false;
    });
  }

  Future<void> _deleteProduct(int id) async {
    final ok = await widget.api.adminDeleteProduct(id);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto deletado')),
      );
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao deletar')),
      );
    }
  }

  void _editProduct(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductForm(api: widget.api, product: product),
      ),
    ).then((_) => _load());
  }

  void _addProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminProductForm(api: widget.api)),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1D2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Admin - Produtos', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFFB9220)),
            onPressed: _addProduct,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFB9220)))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) {
                final item = products[i] as Map<String, dynamic>;
                return Card(
                  color: const Color(0xFF1A2A38),
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(item['title'] ?? '', style: const TextStyle(color: Colors.white)),
                    subtitle: Text(item['brand'] ?? '', style: const TextStyle(color: Colors.white70)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editProduct(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(item['id'] as int),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
