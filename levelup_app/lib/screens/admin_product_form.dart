import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/notification_service.dart';


class AdminProductForm extends StatefulWidget {
  final Api api;
  final Map<String, dynamic>? product; // se null, é criação

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
      SnackBar(content: Text('Salvo com sucesso')),
    );

    // NOTIFICAÇÃO MOCKADA QUANDO CRIAR UM NOVO PRODUTO
    if (isCreating) {
      NotificationService().showLocalNotification(
        context,
        "Novo produto adicionado",
        "${titleController.text} foi cadastrado!",
      );
    }

    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao salvar')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product != null ? 'Editar Produto' : 'Adicionar Produto')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: titleController, decoration: InputDecoration(labelText: 'Título'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              TextFormField(controller: brandController, decoration: InputDecoration(labelText: 'Marca')),
              TextFormField(controller: descriptionController, decoration: InputDecoration(labelText: 'Descrição')),
              TextFormField(controller: priceController, decoration: InputDecoration(labelText: 'Preço'), keyboardType: TextInputType.number),
              TextFormField(controller: affiliateController, decoration: InputDecoration(labelText: 'Link Afiliado')),
              TextFormField(controller: imageController, decoration: InputDecoration(labelText: 'URL da Imagem')),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
