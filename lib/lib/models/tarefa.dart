import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_f/models/usuario.dart';
import 'package:flutter_f/services/auth.dart';
import 'package:flutter_f/services/db.dart';
import 'package:flutter_f/telas/tarefa_details.dart';
import 'package:flutter_f/themes/app_themes.dart';
import 'package:intl/intl.dart';

class Tarefa {
  String? id;
  String titulo;
  String descricao;
  DateTime dataVencimento;
  String prioridade;
  String status;
  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.dataVencimento,
    required this.prioridade,
    required this.status,
  });

  Color get statusColor => concluida ? AppThemes.currentThemeData.extension<ThemeColorExtension>()!.prioBaixa ?? Colors.green : AppThemes.colorScheme.inverseSurface;

  Color get color => prioridade.toLowerCase() == "alta"
      ? AppThemes.currentThemeData.extension<ThemeColorExtension>()!.prioAlta ?? Colors.redAccent
      : prioridade.toLowerCase() == "media"
      ? AppThemes.currentThemeData.extension<ThemeColorExtension>()!.prioMedia ?? Colors.amber
      : AppThemes.currentThemeData.extension<ThemeColorExtension>()!.prioBaixa ?? Colors.green;

  String get prioridadeText => prioridade.toLowerCase() == "alta"
      ? "Alta"
      : prioridade.toLowerCase() == "media"
      ? "Média"
      : "Baixa";

  bool get concluida => status == "concluida";

  String get statusText => concluida ? "Concluída" : "Pendente";

  static final DateFormat _dateFormat = DateFormat('EEE d/M/y').add_Hm();

  String get prazoText => _dateFormat.format(dataVencimento);

  static String getPrazoText(DateTime prazo) {
    return _dateFormat.format(prazo);
  }

  void save() async {
    if (auth.currentUser == null) return;
    Usuario? usuario = await Auth.getUsuario(auth.currentUser!);
    if (usuario == null) return;

    if (id == null) { //criar nova entrada no banco de dados
      status = "pendente";
      DatabaseReference ref = database.ref('tasks/${usuario.uid}').push();
      try {
        await ref.set(toMap());
      } catch (error) {
        print(error);
      }
    } else {
      DatabaseReference ref = database.ref('tasks/${usuario.uid}/$id');
      try {
        await ref.set(toMap());
      } catch (error) {
        print(error);
      }
    }
  }

  void remove() async {
    if (auth.currentUser == null) return;
    Usuario? usuario = await Auth.getUsuario(auth.currentUser!);
    if (usuario == null) return;

    if (id == null) return; //não dá pra remover uma tarefa que nem está no banco.

    DatabaseReference ref = database.ref('tasks/${usuario.uid}/$id');
    try {
      await ref.set(null); //morre
    } catch (error) {
      print(error);
    }
  }

  Map toMap() {
    return {
      "titulo": titulo,
      "desc": descricao,
      "dataVenc": dataVencimento.toIso8601String(),
      "prioridade": prioridade,
      "status": status,
    };
  }

  factory Tarefa.fromMap(Map map) {
    return Tarefa(
      id: map["id"],
      titulo: map["titulo"],
      descricao: map["desc"],
      dataVencimento: DateTime.parse(map["dataVenc"]),
      prioridade: map["prioridade"],
      status: map["status"],
    );
  }

  static Future<Tarefa?> read(String id) async {
    if (auth.currentUser == null) return null;
    Usuario? usuario = await Auth.getUsuario(auth.currentUser!);
    if (usuario == null) return null;

    DatabaseReference ref = database.ref('tasks/${usuario.uid}/$id');
    DatabaseEvent event = await ref.once();
    if (event.snapshot.exists) {
      Map map = event.snapshot.value as Map;
      map["id"] = event.snapshot.key ?? "";
      return Tarefa.fromMap(map);
    } else {
      print("nenhum dado encontrado em 'tasks/${usuario.uid}/$id'");
      return null;
    }
  }

  static Future<List<Tarefa>?> listTarefas() async {
    if (auth.currentUser == null) return [];
    Usuario? usuario = await Auth.getUsuario(auth.currentUser!);
    if (usuario == null) return [];

    DatabaseReference ref = database.ref('tasks/${usuario.uid}');
    DatabaseEvent event = await ref.once();
    List<Tarefa> tasks = [];
    if (event.snapshot.value != null) {
      Map map = event.snapshot.value as Map;
      map.forEach((key, value) {
        final taskMap = Map.from(value as Map);
        taskMap["id"] = key;
        tasks.add(Tarefa.fromMap(taskMap));
      });
      return tasks;
    }
    return null;
  }

  static List<Tarefa> tarefasCache = [];
  static StreamController<List<Tarefa>> tarefas = StreamController.broadcast();
  static void updateTarefas({bool? allowEmpty}) {
    listTarefas().then((list) {
      if (list != null) {
        tarefasCache = list;
        tarefas.add(list);
      } else if (allowEmpty ?? false) {
        tarefasCache = [];
        tarefas.add([]);
      }
    });
  }

  static StreamSubscription<DatabaseEvent>? onAddedSubscription;
  static StreamSubscription<DatabaseEvent>? onRemovedSubscription;
  static StreamSubscription<DatabaseEvent>? onChangedSubscription;

  static void escutarAlteracoes(User user) async { //escutar de um user especifico
    Usuario? usuario = await Auth.getUsuario(user);
    if (usuario == null) return;

    DatabaseReference ref = database.ref("tasks");
    onAddedSubscription = ref.onChildAdded.listen((_) {
      updateTarefas();
    });
    onRemovedSubscription = ref.onChildRemoved.listen((_) {
      //quando uma tarefa for removida, interprete "null" como uma tabela vazia em vez de ignorar
      updateTarefas(allowEmpty: true);
    });
    onChangedSubscription = ref.onChildChanged.listen((_) {
      updateTarefas();
    });
  }

  static void pararDeEscutar() {
    onAddedSubscription?.cancel();
    onRemovedSubscription?.cancel();
    onChangedSubscription?.cancel();
  }
}
