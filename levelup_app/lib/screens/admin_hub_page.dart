import 'package:flutter/material.dart';
import '../services/api.dart';
import 'admin_product_page.dart';
import 'admin_article_page.dart';

class AdminHubPage extends StatelessWidget {
  final Api api;
  const AdminHubPage({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1D2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Admin Hub', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              context,
              icon: Icons.shopping_cart,
              label: 'Gerenciar Produtos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminProductPage(api: api)),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              icon: Icons.article,
              label: 'Gerenciar Artigos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminArticlePage(api: api)),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              icon: Icons.logout,
              label: 'Logout',
              color: Colors.red,
              onPressed: () async {
                await api.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onPressed, Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFFFB9220),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        onPressed: onPressed,
      ),
    );
  }
}
