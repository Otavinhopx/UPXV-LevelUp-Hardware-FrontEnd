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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produto deletado')));
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao deletar')));
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
      MaterialPageRoute(
        builder: (_) => AdminProductForm(api: widget.api),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Produtos'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _addProduct),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) {
                final item = products[i] as Map<String, dynamic>;
                return ListTile(
                  title: Text(item['title'] ?? ''),
                  subtitle: Text(item['brand'] ?? ''),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editProduct(item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(item['id'] as int),
                    )
                  ]),
                );
              },
            ),
    );
  }
}
