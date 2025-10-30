import 'package:flutter/material.dart';
import '../services/api.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends StatelessWidget {
  final Api api;
  final Map product;
  const ProductDetailPage({Key? key, required this.api, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = product['affiliateUrl'];
    return Scaffold(
      appBar: AppBar(title: Text(product['title'] ?? 'Detalhe')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (product['imageUrl'] != null) Image.network(product['imageUrl']),
          SizedBox(height: 8),
          Text(product['title'] ?? '',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(product['description'] ?? ''),
          Spacer(),
          ElevatedButton(
            onPressed: url == null
                ? null
                : () async {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri))
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                  },
            child: Text('Comprar (link afiliado)'),
          )
        ]),
      ),
    );
  }
}
