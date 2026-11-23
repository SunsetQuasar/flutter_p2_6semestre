import 'package:flutter/material.dart';
import 'package:flutter_f/models/usuario.dart';
import 'package:flutter_f/services/auth.dart';
import 'package:flutter_f/telas/async_transition.dart';
import 'package:flutter_f/themes/app_themes.dart';
import 'package:flutter_f/widgets/main_drawer.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key, required this.title});

  final String title;

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.currentUser != null) {
        AsyncTransition.createTransition(
          context,
          Auth.getUsuario(auth.currentUser!).then((u) {
            return TransitionResult(
              success: u != null,
              error: u == null ? "Usuário não encontrado" : null,
            );
          }),
        ).then((result) {
          if (context.mounted) {
            if (result?.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Erro: ${result?.error}"),
                  backgroundColor: AppThemes.colorScheme.error,
                ),
              );
            } else {
              Navigator.pushNamed(context, '/main');
            }
          }
        });
      }
    });

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
                        Text("Iniciar Sessão:", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
                        SizedBox(height: 80),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/login");
                          },
                          child: Text("Login", style: TextStyle(fontSize: 18)),
                        ),
                        SizedBox(height: 80),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/signup");
                          },
                          child: Text("Criar Usuário", style: TextStyle(fontSize: 18)),
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
}
