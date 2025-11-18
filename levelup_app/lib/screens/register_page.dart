import 'package:flutter/material.dart';
import 'package:levelup_app/services/api.dart';

class RegisterPage extends StatefulWidget {
  final Api api;
  const RegisterPage({super.key, required this.api});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  bool loading = false;

  void _register() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();

    setState(() => loading = true);

    // envio com nome
    final res = await widget.api.registerWithName(name, email, password);

    setState(() => loading = false);

    if (res) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conta criada! Faça login.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao registrar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1D2A),
      appBar: AppBar(
        title: Text("Criar conta"),
        backgroundColor: Color(0xFFFB9220),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFB9220)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFB9220), width: 2),
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Digite seu nome' : null,
                onSaved: (v) => name = v!.trim(),
              ),
              SizedBox(height: 16),
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFB9220)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFB9220), width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Email inválido' : null,
                onSaved: (v) => email = v!.trim(),
              ),
              SizedBox(height: 16),
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFB9220)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFB9220), width: 2),
                  ),
                ),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min. 6 caracteres' : null,
                onSaved: (v) => password = v!,
              ),
              SizedBox(height: 24),
              if (loading)
                CircularProgressIndicator(color: Color(0xFFFB9220)),
              if (!loading)
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFB9220),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Criar conta'),
                )
            ],
          ),
        ),
      ),
    );
  }
}
