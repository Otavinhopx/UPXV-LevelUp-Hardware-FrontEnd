import 'package:flutter/material.dart';
import 'package:levelup_app/services/api.dart';

class LoginPage extends StatefulWidget {
  final Api api;
  const LoginPage({Key? key, required this.api}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;

  void _login() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    setState(() => loading = true);
    final token = await widget.api.login(email, password);
    setState(() => loading = false);
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/products');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login failed')));
    }
  }

  void _register() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    setState(() => loading = true);
    final ok = await widget.api.register(email, password);
    setState(() => loading = false);
    if (ok)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registered!')));
    else
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Register failed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LevelUp - Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Email inválido' : null,
                onSaved: (v) => email = v!.trim(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                onSaved: (v) => password = v!,
              ),
              SizedBox(height: 16),
              if (loading) CircularProgressIndicator(),
              if (!loading)
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(onPressed: _login, child: Text('Entrar')),
                      ElevatedButton(
                          onPressed: _register, child: Text('Registrar')),
                    ])
            ],
          ),
        ),
      ),
    );
  }
}
