import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/notification_service.dart';

class AdminArticleForm extends StatefulWidget {
  final Api api;
  final Map<String, dynamic>? article;

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
  int? selectedProductId;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.article?['title']);
    authorController = TextEditingController(text: widget.article?['author']);
    contentController = TextEditingController(text: widget.article?['content']);
    selectedProductId = widget.article?['productId'];
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => loadingProducts = true);
    final p = await widget.api.getProducts();
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
      'productId': selectedProductId,
    };

    bool ok = false;
    bool isCreating = widget.article == null;

    if (widget.article != null) {
      final id = widget.article!['id'] as int;
      ok = await widget.api.adminUpdateArticle(id, body);
    } else {
      ok = await widget.api.adminCreateArticle(body);
    }

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvo com sucesso')),
      );

      if (isCreating) {
        NotificationService.showNativeNotification("Novo artigo publicado", titleController.text);
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1D2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.article != null ? 'Editar Artigo' : 'Adicionar Artigo',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildField('Título', titleController, required: true),
                  _buildField('Autor (opcional)', authorController),
                  _buildField('Conteúdo', contentController, maxLines: 6, required: true),
                  const SizedBox(height: 12),
                  loadingProducts
                      ? const CircularProgressIndicator(color: Color(0xFFFB9220))
                      : DropdownButtonFormField<int?>(
                          value: selectedProductId,
                          decoration: InputDecoration(
                            labelText: 'Associar a produto (opcional)',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white24)),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFFB9220))),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Nenhum (artigo geral)')),
                            ...products.map((p) {
                              final map = p as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: map['id'],
                                child: Text(map['title']),
                              );
                            }),
                          ],
                          onChanged: (v) => setState(() => selectedProductId = v),
                        ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFB9220)),
                      onPressed: _save,
                      child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFB9220)),
          ),
        ),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null
            : null,
      ),
    );
  }
}
