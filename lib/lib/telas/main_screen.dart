import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_f/models/tarefa.dart';
import 'package:flutter_f/services/auth.dart';
import 'package:flutter_f/services/db.dart';
import 'package:flutter_f/telas/tarefa_details.dart';
import 'package:flutter_f/telas/tarefas_list.dart';
import 'package:flutter_f/themes/app_themes.dart';
import 'package:flutter_f/widgets/main_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    Tarefa.updateTarefas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppThemes.currentTheme,
      builder: (context, value, child) {
        return Theme(
          data: AppThemes.currentThemeData,
          child: Scaffold(
            drawer: MainDrawer(),
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
                        Text(
                          "Olá, ${usuario?.nome ?? "<ERRO>"}!",
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 60),
                        StreamBuilder(
                          stream: Tarefa.tarefas.stream.asBroadcastStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                              return Column( 
                                spacing: 20, children: [
                                Text("Nenhuma tarefa cadastrada."),
                                ElevatedButton(onPressed: () async {
                                  Tarefa? retornada = await TarefaDetails.criarNovaTarefa(context);
                                  if (context.mounted && retornada != null) {
                                    Navigator.pushNamed(context, '/tarefas');
                                  }
                                }, child: Text("Criar Tarefa"))
                              ]);
                            }
                            else if (snapshot.hasData) {
                              List<Tarefa> list = snapshot.data as List<Tarefa>;
                              List<Tarefa> concluidas = list.where((tarefa) => tarefa.status == "concluida").toList();
                              List<Tarefa> pendentes = list.where((tarefa) => tarefa.status == "pendente").toList();
                              return Column(
                                children: [
                                  Text(
                                    "${list.length} tarefa${list.length != 1 ? "s" : ""} cadastrada${list.length != 1 ? "s" : ""}.",
                                  ),
                                  Text(
                                    "(${pendentes.length} pendente${pendentes.length != 1 ? "s" : ""}, ${concluidas.length} concluída${concluidas.length != 1 ? "s" : ""})",
                                  ),

                                ],
                              );
                            }
                            return Text("");
                          },
                          initialData: Tarefa.tarefasCache,
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
    super.dispose();
  }
}
