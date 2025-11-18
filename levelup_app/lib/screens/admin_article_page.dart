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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Artigo deletado')));
      await _load();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao deletar')));
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
      MaterialPageRoute(
        builder: (_) => AdminArticleForm(api: widget.api),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Artigos'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _addArticle),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (_, i) {
                final item = articles[i] as Map<String, dynamic>;
                return ListTile(
                  title: Text(item['title'] ?? ''),
                  subtitle: Text(item['author'] ?? ''),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editArticle(item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteArticle(item['id'] as int),
                    )
                  ]),
                );
              },
            ),
    );
  }
}
