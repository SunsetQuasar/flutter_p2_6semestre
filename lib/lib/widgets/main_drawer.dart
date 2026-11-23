import 'package:flutter/material.dart';
import 'package:flutter_f/services/auth.dart';
import 'package:flutter_f/telas/async_transition.dart';
import 'package:flutter_f/themes/app_themes.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  usuario?.nome ?? "<ERRO>",
                  style: const TextStyle(fontSize: 24),
                ),
                Text(
                  usuario?.email ?? "<ERRO>",
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Página Inicial'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName('/main'));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
            onTap: () {
              Navigator.pushNamed(context, '/config');
            },
          ),
          ListTile(
            leading: Icon(Icons.pending_actions),
            title: Text('Minhas Tarefas'),
            onTap: () {
              Navigator.pushNamed(context, '/tarefas');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sair'),
            onTap: () {
              AsyncTransition.createTransition(
                context,

                Auth.signOut().then((success) {
                  return TransitionResult(
                    success: success,
                    error: !success ? "Erro ao sair" : null,
                  );
                }),
              ).then((result) {
                if (context.mounted) {
                  if (result?.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Erro: ${result?.error}"),
                        backgroundColor:
                            AppThemes.colorScheme.error,
                      ),
                    );
                  } else {
                    Navigator.popUntil(context, ModalRoute.withName('/inicio'));
                  }
                }
              });
              ;
            },
          ),
        ],
      ),
    );
  }
}
