import 'package:flutter/material.dart';
import '../services/api.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  final Api api;
  const ProductListPage({super.key, required this.api});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List products = [];
  bool loading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final p = await widget.api.getProducts();
    final admin = await widget.api.isAdmin();
    setState(() {
      products = p;
      isAdmin = admin;
      loading = false;
    });
  }

  Future<void> _deleteProduct(int id) async {
    final ok = await widget.api.adminDeleteProduct(id);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto deletado'), backgroundColor: Color(0xFFFB9220)));
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1D2A),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B1D2A),
        title: Text('Produtos', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await widget.api.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Color(0xFFFB9220),
        onRefresh: _load,
        child: loading
            ? Center(child: CircularProgressIndicator(color: Color(0xFFFB9220)))
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final item = products[i] as Map<String, dynamic>;
                  return Card(
                    color: Color(0xFFA0A0A0),
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: ListTile(
                      leading: item['imageUrl'] != null
                          ? Image.network(item['imageUrl'],
                              width: 56, height: 56, fit: BoxFit.cover)
                          : null,
                      title: Text(item['title'] ?? '', style: TextStyle(color: Colors.white)),
                      subtitle: Text(item['brand'] ?? '', style: TextStyle(color: Colors.white70)),
                      trailing: Text(item['price'] != null
                          ? 'R\$ ${item['price']}'
                          : '', style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailPage(api: widget.api, product: item)),
                      ),
                      onLongPress: isAdmin
                          ? () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: Color(0xFF0B1D2A),
                                  title: Text('Confirmar', style: TextStyle(color: Colors.white)),
                                  content: Text('Deletar "${item['title']}"?',
                                      style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Deletar', style: TextStyle(color: Color(0xFFFB9220))),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) _deleteProduct(item['id'] as int);
                            }
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
