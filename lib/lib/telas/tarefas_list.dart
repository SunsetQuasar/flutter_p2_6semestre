import 'package:flutter/material.dart';
import 'package:flutter_f/models/tarefa.dart';
import 'package:flutter_f/telas/tarefa_details.dart';
import 'package:flutter_f/themes/app_themes.dart';
import 'package:flutter_f/widgets/main_drawer.dart';

class TarefasList extends StatefulWidget {
  const TarefasList({super.key, required this.title});
  final String title;

  @override
  State<StatefulWidget> createState() => _TarefasListState();
}

class _TarefasListState extends State<TarefasList> {
  @override
  void initState() {
    Tarefa.updateTarefas();
    super.initState();
  }

  String _query = "";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppThemes.currentTheme,
      builder: (context, value, child) {
        return Theme(
          data: AppThemes.currentThemeData,
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                TarefaDetails.criarNovaTarefa(context);
              },
              child: Icon(Icons.add),
            ),
            drawer: MainDrawer(),
            appBar: AppBar(
              backgroundColor: AppThemes.colorScheme.inversePrimary,
              title: Text(widget.title),
            ),
            body: Center(
              child: Row(
                children: [
                  Expanded(flex: 1, child: Column()),
                  Expanded(
                    flex: 8,
                    child: Column(
                      children: [
                        StreamBuilder(
                          stream: Tarefa.tarefas.stream.asBroadcastStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Column(
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    "Nenhuma tarefa cadastrada.",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              );
                            } else {
                              //pesquisa por título
                              List<Tarefa> list =
                                  (snapshot.data as List<Tarefa>)
                                      .where(
                                        (t) =>
                                            _query.isEmpty ||
                                            t.titulo.contains(_query),
                                      )
                                      .toList();
                              list.sort(
                                (a, b) => a.dataVencimento.compareTo(
                                  b.dataVencimento,
                                ),
                              );
                              return Expanded(
                                child: Column(
                                  mainAxisAlignment: .spaceAround,
                                  children: [
                                    SizedBox(height: 20),
                                    Row(
                                      spacing: 20,
                                      children: [
                                        Text(
                                          "${list.length} Tarefa${list.length != 1 ? "s" : ""}",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              icon: Icon(Icons.search),
                                              label: Text("Pesquisar"),
                                            ),
                                            onChanged: (text) {
                                              setState(() {
                                                _query = text;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20),
                                    Expanded(
                                      child: ListView.separated(
                                        itemCount: list.length,
                                        itemBuilder: (context, id) {
                                          Tarefa tarefa = list[id];
                                          bool jaFoi = tarefa.dataVencimento
                                              .isBefore(
                                                DateTime.now(),
                                              ); // prazo estourado
                                          return ListTile(
                                            onTap: tarefa.concluida
                                                ? null
                                                : () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return TarefaDetails(
                                                          tarefa: tarefa,
                                                        );
                                                      },
                                                    );
                                                    /*
                                              Navigator.push(
                                                context,
                                                TarefaDetailsPopUp(tarefa: tarefa),
                                              );
                                              */
                                                  },
                                            tileColor: !tarefa.concluida
                                                ? AppThemes
                                                      .colorScheme
                                                      .surfaceContainerHigh
                                                : AppThemes
                                                      .colorScheme
                                                      .surfaceContainer,
                                            title: Row(
                                              children: [
                                                Text(
                                                  tarefa.titulo,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                Text(
                                                  tarefa.statusText,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color:
                                                        AppThemes.textoContraste(
                                                          0.5,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            subtitle: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.priority_high,
                                                      color: tarefa.color,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "Prioridade: ${tarefa.prioridadeText}",
                                                      style: TextStyle(
                                                        color: AppThemes
                                                            .colorScheme
                                                            .inverseSurface,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .watch_later_outlined,
                                                      color: jaFoi
                                                          ? AppThemes
                                                                .colorScheme
                                                                .error
                                                          : AppThemes
                                                                .colorScheme
                                                                .surfaceTint,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "Prazo: ${tarefa.prazoText}",
                                                      style: TextStyle(
                                                        color: jaFoi
                                                            ? AppThemes
                                                                  .colorScheme
                                                                  .error
                                                            : AppThemes
                                                                  .colorScheme
                                                                  .inverseSurface,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                //pra não causar aquele overflow infinito
                                                maxWidth: 96,
                                              ),
                                              child: Row(
                                                mainAxisAlignment: .end,
                                                children: [
                                                  IconButton(
                                                    onPressed: tarefa.concluida
                                                        ? null
                                                        : () async {
                                                            bool?
                                                            marcar = await showDialog<bool>(
                                                              context: context,
                                                              builder: (context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                    "Marcar como concluída",
                                                                  ),
                                                                  content: Text(
                                                                    "Deseja marcar '${tarefa.titulo}' como concluída?",
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                          false,
                                                                        );
                                                                      },
                                                                      child:
                                                                          Text(
                                                                            "Cancelar",
                                                                          ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                          true,
                                                                        );
                                                                      },
                                                                      child:
                                                                          Text(
                                                                            "Marcar como concluída",
                                                                          ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                            if (marcar ??
                                                                false) {
                                                              tarefa.status =
                                                                  "concluida";
                                                              tarefa.save();
                                                            }
                                                          },
                                                    icon: Icon(
                                                      Icons.check,
                                                      color: tarefa.statusColor,
                                                    ),
                                                    iconSize: 24,
                                                  ),
                                                  IconButton(
                                                    onPressed: () async {
                                                      bool?
                                                      apagar = await showDialog<bool>(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                              "Apagar Tarefa",
                                                            ),
                                                            content: Text(
                                                              "Deseja mesmo apagar '${tarefa.titulo}'?",
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  );
                                                                },
                                                                child: Text(
                                                                  "Cancelar",
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  );
                                                                },
                                                                child: Text(
                                                                  "Apagar",
                                                                  style: TextStyle(
                                                                    color: AppThemes
                                                                        .colorScheme
                                                                        .error,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      if (apagar ?? false) {
                                                        tarefa.remove();
                                                      }
                                                    },
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: AppThemes
                                                          .colorScheme
                                                          .error,
                                                    ),
                                                    iconSize: 24,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, id) {
                                          return SizedBox(height: 20);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
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
}
