import 'package:flutter/material.dart';
import '../services/api.dart';
import 'product_detail_page.dart';
import 'admin_add_product.dart';

class ProductListPage extends StatefulWidget {
  final Api api;
  const ProductListPage({Key? key, required this.api}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produtos'), actions: [
        IconButton(
            onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AdminAddProduct(api: widget.api)))
                .then((_) => _load()),
            icon: Icon(Icons.add))
      ]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final item = products[i] as Map<String, dynamic>;
                  return ListTile(
                    leading: item['imageUrl'] != null
                        ? Image.network(item['imageUrl'],
                            width: 56, height: 56, fit: BoxFit.cover)
                        : null,
                    title: Text(item['title'] ?? ''),
                    subtitle: Text(item['brand'] ?? ''),
                    trailing: Text(
                        item['price'] != null ? 'R\$ ${item['price']}' : ''),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                                api: widget.api, product: item))),
                  );
                },
              ),
      ),
    );
  }
}
