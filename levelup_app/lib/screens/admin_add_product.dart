import 'package:flutter/material.dart';
import '../services/api.dart';

class AdminAddProduct extends StatefulWidget {
  final Api api;
  const AdminAddProduct({Key? key, required this.api}) : super(key: key);

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
      appBar: AppBar(title: Text('Adicionar Produto')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _form,
          child: Column(children: [
            TextFormField(
                decoration: InputDecoration(labelText: 'Título'),
                onSaved: (v) => title = v ?? ''),
            TextFormField(
                decoration: InputDecoration(labelText: 'Marca'),
                onSaved: (v) => brand = v ?? ''),
            TextFormField(
                decoration: InputDecoration(labelText: 'Descrição'),
                onSaved: (v) => description = v ?? ''),
            TextFormField(
                decoration: InputDecoration(labelText: 'Link Afiliado'),
                onSaved: (v) => affiliateUrl = v ?? ''),
            TextFormField(
                decoration: InputDecoration(labelText: 'URL Imagem'),
                onSaved: (v) => imageUrl = v ?? ''),
            SizedBox(height: 12),
            submitting
                ? CircularProgressIndicator()
                : ElevatedButton(
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
                      if (ok)
                        Navigator.pop(context);
                      else
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao criar')));
                    },
                    child: Text('Criar Produto'))
          ]),
        ),
      ),
    );
  }
}
