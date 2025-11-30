import 'package:flutter/material.dart';
import '../services/api.dart';
import 'admin_article_form.dart';

class AdminArticlePage extends StatefulWidget {
  final Api api;
  const AdminArticlePage({super.key, required this.api});

  @override
  State<AdminArticlePage> createState() => _AdminArticlePageState();
}

class _AdminArticlePageState extends State<AdminArticlePage> {
  List articles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final a = await widget.api.getAdminArticles();
    setState(() {
      articles = a;
      loading = false;
    });
  }

  Future<void> _deleteArticle(int id) async {
    final ok = await widget.api.adminDeleteArticle(id);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artigo deletado')),
      );
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao deletar')),
      );
    }
  }

  void _editArticle(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminArticleForm(api: widget.api, article: article),
      ),
    ).then((_) => _load());
  }

  void _addArticle() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminArticleForm(api: widget.api)),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1D2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Admin - Artigos', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFFB9220)),
            onPressed: _addArticle,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFB9220)))
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (_, i) {
                final item = articles[i] as Map<String, dynamic>;
                return Card(
                  color: const Color(0xFF1A2A38),
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(item['title'] ?? '', style: const TextStyle(color: Colors.white)),
                    subtitle: Text(item['author'] ?? '', style: const TextStyle(color: Colors.white70)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editArticle(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteArticle(item['id'] as int),
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
