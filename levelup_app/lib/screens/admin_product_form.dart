import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/notification_service.dart';

class AdminProductForm extends StatefulWidget {
  final Api api;
  final Map<String, dynamic>? product;

  const AdminProductForm({super.key, required this.api, this.product});

  @override
  State<AdminProductForm> createState() => _AdminProductFormState();
}

class _AdminProductFormState extends State<AdminProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController brandController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController affiliateController;
  late TextEditingController imageController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.product?['title']);
    brandController = TextEditingController(text: widget.product?['brand']);
    descriptionController = TextEditingController(text: widget.product?['description']);
    priceController = TextEditingController(text: widget.product?['price']?.toString());
    affiliateController = TextEditingController(text: widget.product?['affiliateUrl']);
    imageController = TextEditingController(text: widget.product?['imageUrl']);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      'title': titleController.text,
      'brand': brandController.text,
      'description': descriptionController.text,
      'price': double.tryParse(priceController.text),
      'affiliateUrl': affiliateController.text,
      'imageUrl': imageController.text,
    };

    bool ok = false;
    bool isCreating = widget.product == null;

    if (widget.product != null) {
      final id = widget.product!['id'] as int;
      ok = await widget.api.adminUpdateProduct(id, body);
    } else {
      ok = await widget.api.adminCreateProduct(body);
    }

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvo com sucesso')),
      );

      if (isCreating) {
        NotificationService.showNativeNotification(
          "Novo produto publicado!!",
          titleController.text,
        );
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
          widget.product != null ? 'Editar Produto' : 'Adicionar Produto',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('Título', titleController, required: true),
              _buildField('Marca', brandController),
              _buildField('Descrição', descriptionController),
              _buildField('Preço', priceController, keyboard: TextInputType.number),
              _buildField('Link Afiliado', affiliateController),
              _buildField('URL da Imagem', imageController),
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
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
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
