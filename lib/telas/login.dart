import 'package:flutter/material.dart';
import 'package:flutter_f/services/auth.dart';
import 'package:flutter_f/telas/async_transition.dart';
import 'package:flutter_f/themes/app_themes.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});

  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

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
                                  return null;
                                },
                              ),
                              SizedBox(height: 60),
                              Row(
                                mainAxisAlignment: .spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        AsyncTransition.createTransition(
                                          context,

                                          Auth.signInWithEmailPassword(
                                            _emailController.text,
                                            _senhaController.text,
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
                                    child: Text('Entrar'),
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
    _senhaController.dispose();
    _emailController.dispose();

    super.dispose();
  }
}
