import 'package:flutter/material.dart';
import 'package:flutter_f/models/usuario.dart';
import 'package:flutter_f/services/auth.dart';
import 'package:flutter_f/telas/async_transition.dart';
import 'package:flutter_f/themes/app_themes.dart';
import 'package:flutter_f/widgets/main_drawer.dart';

class Signup extends StatefulWidget {
  const Signup({super.key, required this.title});

  final String title;

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _senhaRepeteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppThemes.currentTheme,
      builder: (context, value, child) {
        return Theme(
          data: AppThemes.currentThemeData,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor:
                  AppThemes.colorScheme.inversePrimary,
              title: Text(widget.title),
            ),
            body: Center(
              child: Row(
                children: [
                  Expanded(flex: 1, child: Column()),
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: .center,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nomeController,
                                decoration: InputDecoration(labelText: 'Nome'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo "Nome" vazio';
                                  }
                                  if (value.length < 4) {
                                    return 'Mínimo de 4 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 60),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo "E-mail" vazio';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 60),
                              TextFormField(
                                controller: _senhaController,
                                decoration: InputDecoration(labelText: 'Senha'),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo "Senha" vazio';
                                  }
                                  if (value.length < 8) {
                                    return 'Mínimo de 8 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 60),
                              TextFormField(
                                controller: _senhaRepeteController,
                                decoration: InputDecoration(
                                  labelText: 'Repetir Senha',
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value != _senhaController.text) {
                                    return 'Senha não coincide';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 60),
                              Row(
                                mainAxisAlignment: .spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        AsyncTransition.createTransition(
                                          context,
                                          Auth.createUserWithEmailPassword(
                                            _emailController.text,
                                            _senhaController.text,
                                            _nomeController.text,
                                          ).then((result) {
                                            return TransitionResult(
                                              success: result.uid != null,
                                              error: result.error,
                                            );
                                          }),
                                        ).then((result) {
                                          if (context.mounted) {
                                            if (result?.error != null) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Erro: ${result?.error}",
                                                  ),
                                                  backgroundColor: AppThemes
                                                      .currentThemeData
                                                      .colorScheme
                                                      .error,
                                                ),
                                              );
                                            } else {
                                              Navigator.pushNamed(
                                                context,
                                                '/main',
                                              );
                                            }
                                          }
                                        });
                                      }
                                    },
                                    child: Text('Criar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: Column()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    _emailController.dispose();
    _senhaRepeteController.dispose();

    super.dispose();
  }
}
