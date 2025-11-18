import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final Api api;
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.api, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  List reviews = [];
  List articles = [];
  bool loading = true;
  bool loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadReviews();
    _subscribeToProductTopic();
  }

  Future<void> _loadArticles() async {
    final data = await widget.api.getArticlesForProduct(widget.product['id']);
    setState(() => articles = data);
  }

  Future<void> _loadReviews() async {
    setState(() => loadingReviews = true);
    final data = await widget.api.getReviews(widget.product['id']);
    setState(() {
      reviews = data;
      loadingReviews = false;
    });
  }

  void _launchAffiliateLink() async {
    final url = widget.product['affiliateUrl'];
    if (url != null && await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Link indisponível')));
    }
  }

  void _subscribeToProductTopic() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.subscribeToTopic("new_products");
  print("📨 Inscrito no tópico: new_products");
}


  void _openAddReviewModal() {
  int stars = 5;
  String comment = '';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: Color(0xFF0B1D2A),
            title: Text(
              "Adicionar Review",
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stars selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      icon: Icon(
                        Icons.star,
                        color: i < stars ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () {
                        setModalState(() {
                          stars = i + 1;
                        });
                      },
                    ),
                  ),
                ),

                TextField(
                  style: TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Comentário...",
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                  ),
                  onChanged: (v) => comment = v,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancelar", style: TextStyle(color: Colors.white70)),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFB9220),
                ),
                child: Text("Enviar"),
                onPressed: () async {
                  if (comment.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Escreva um comentário!")),
                    );
                    return;
                  }

                  await widget.api.createReview(
                    widget.product['id'],
                    stars,
                    comment,
                  );

                  Navigator.pop(context);
                  _loadReviews();
                },
              ),
            ],
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final price = widget.product['price'];
    final priceText = price != null
        ? "R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(price)}"
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1D2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.product['title'] ?? 'Produto',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFB9220),
        onPressed: _openAddReviewModal,
        child: Icon(Icons.rate_review, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.product['imageUrl'],
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            /// Marca
            Text(
              widget.product['brand'] ?? '',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),

            /// Preço
            if (priceText != null) ...[
              const SizedBox(height: 4),
              Text(
                priceText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFB9220),
                ),
              ),
            ],

            const SizedBox(height: 8),
            Text(
              widget.product['description'] ?? '',
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFB9220),
                foregroundColor: Colors.white,
              ),
              onPressed: _launchAffiliateLink,
              child: const Text('Comprar'),
            ),

            const SizedBox(height: 24),

            Text(
              "Reviews:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),

            if (loadingReviews)
              Center(
                child: CircularProgressIndicator(color: Color(0xFFFB9220)),
              )
            else if (reviews.isEmpty)
              Text(
                "Nenhum review ainda.",
                style: TextStyle(color: Colors.white70),
              )
            else
              Column(
                children: reviews.map((r) {
                  return Card(
                    color: Color(0xFF1A2A38),
                    child: ListTile(
                      title: Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            color: i < r['stars'] ? Colors.amber : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            r['comment'] ?? '',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Por: ${r['userName'] ?? 'Usuário'}",
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: FutureBuilder<bool>(
                        future: widget.api.isAdmin(),
                        builder: (context, snapshot) {
                          final isAdmin = snapshot.data ?? false;
                          final isOwner = false; // implementar opcional

                          if (!isAdmin && !isOwner) return SizedBox();

                          return IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await widget.api.deleteReview(r['id']);
                              _loadReviews();
                            },
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

            SizedBox(height: 24),

            const Text(
              'Artigos:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),

            if (articles.isEmpty)
              Text("Nenhum artigo disponível.",
                  style: TextStyle(color: Colors.white70))
            else
              Column(
                children: articles.map((a) {
                  return Card(
                    color: Color(0xFFA0A0A0),
                    child: ListTile(
                      title: Text(a['title'] ?? ''),
                      subtitle: Text(a['content'] ?? ''),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
