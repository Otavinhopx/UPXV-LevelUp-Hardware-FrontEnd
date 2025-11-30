import 'package:flutter/material.dart';
import '../services/api.dart';

class AdminAddProduct extends StatefulWidget {
  final Api api;
  const AdminAddProduct({super.key, required this.api});

  @override
  State<AdminAddProduct> createState() => _AdminAddProductState();
}

class _AdminAddProductState extends State<AdminAddProduct> {
  final _form = GlobalKey<FormState>();
  String title = '';
  String brand = '';
  String description = '';
  String affiliateUrl = '';
  String imageUrl = '';
  bool submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1D2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Adicionar Produto', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              _buildTextField('Título', (v) => title = v ?? ''),
              _buildTextField('Marca', (v) => brand = v ?? ''),
              _buildTextField('Descrição', (v) => description = v ?? ''),
              _buildTextField('Link Afiliado', (v) => affiliateUrl = v ?? ''),
              _buildTextField('URL Imagem', (v) => imageUrl = v ?? ''),
              const SizedBox(height: 16),
              submitting
                  ? const CircularProgressIndicator(color: Color(0xFFFB9220))
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFB9220),
                        ),
                        onPressed: () async {
                          _form.currentState!.save();
                          setState(() => submitting = true);
                          final ok = await widget.api.adminCreateProduct({
                            'title': title,
                            'brand': brand,
                            'description': description,
                            'affiliateUrl': affiliateUrl,
                            'imageUrl': imageUrl,
                          });
                          setState(() => submitting = false);
                          if (ok) Navigator.pop(context);
                          else ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Erro ao criar')));
                        },
                        child: const Text('Criar Produto', style: TextStyle(color: Colors.white)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
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
        onSaved: onSaved,
      ),
    );
  }
}
