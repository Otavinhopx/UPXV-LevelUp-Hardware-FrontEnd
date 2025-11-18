import 'package:flutter/material.dart';
import '../services/api.dart';

class AdminArticleForm extends StatefulWidget {
  final Api api;
  final Map<String, dynamic>? article; // se null, é criação

  const AdminArticleForm({super.key, required this.api, this.article});

  @override
  State<AdminArticleForm> createState() => _AdminArticleFormState();
}

class _AdminArticleFormState extends State<AdminArticleForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController contentController;

  List products = [];
  bool loadingProducts = true;
  int? selectedProductId; // null = sem produto

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.article?['title']);
    authorController = TextEditingController(text: widget.article?['author']);
    contentController = TextEditingController(text: widget.article?['content']);
    // se for edição, set selectedProductId se existir
    if (widget.article != null && widget.article!['productId'] != null) {
      selectedProductId = widget.article!['productId'] as int;
    }
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => loadingProducts = true);
    final p = await widget.api.getProducts(); // usa endpoint público
    setState(() {
      products = p;
      loadingProducts = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      'title': titleController.text,
      'author': authorController.text,
      'content': contentController.text,
      'productId': selectedProductId // pode ser null
    };

    bool ok = false;
    if (widget.article != null) {
      final id = widget.article!['id'] as int;
      ok = await widget.api.adminUpdateArticle(id, body);
    } else {
      ok = await widget.api.adminCreateArticle(body);
    }

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Salvo com sucesso')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.article != null ? 'Editar Artigo' : 'Adicionar Artigo')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: titleController, decoration: InputDecoration(labelText: 'Título'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                  SizedBox(height: 12),
                  TextFormField(controller: authorController, decoration: InputDecoration(labelText: 'Autor (opcional)')),
                  SizedBox(height: 12),
                  TextFormField(controller: contentController, decoration: InputDecoration(labelText: 'Conteúdo'), maxLines: 6, validator: (v) => v!.isEmpty ? 'Conteúdo obrigatório' : null),
                  SizedBox(height: 12),
                  // Dropdown de produtos
                  loadingProducts
                      ? CircularProgressIndicator()
                      : DropdownButtonFormField<int?>(
                          initialValue: selectedProductId,
                          decoration: InputDecoration(labelText: 'Associar a produto (opcional)'),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Nenhum (artigo geral)'),
                            ),
                            ...products.map((p) {
                              final map = p as Map<String, dynamic>;
                              return DropdownMenuItem<int?>(
                                value: map['id'] as int?,
                                child: Text(map['title'] ?? ''),
                              );
                            }),
                          ],
                          onChanged: (v) => setState(() => selectedProductId = v),
                        ),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _save, child: Text('Salvar')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
