import 'package:flutter/material.dart';
import 'package:flutter_f/models/tarefa.dart';
import 'package:flutter_f/themes/app_themes.dart';

class TarefaDetails extends StatefulWidget {
  const TarefaDetails({super.key, required this._tarefa});

  final Tarefa _tarefa;

  @override
  State<StatefulWidget> createState() => _TarefaDetailsState();

  static Future<Tarefa?> criarNovaTarefa(BuildContext context) async {
    Tarefa nova = Tarefa(
      id: null,
      titulo: "Nova Tarefa",
      descricao: "Adicionar descrição.",
      dataVencimento: DateTime.now().add(Duration(days: 1)),
      prioridade: "baixa",
      status: "pendente",
    );
    //Navigator.push(context, TarefaDetailsPopUp(tarefa: nova));
    return showDialog(
      context: context,
      builder: (context) {
        return TarefaDetails(tarefa: nova);
      },
    );
  }
}

class _TarefaDetailsState extends State<TarefaDetails> {
  static List<DropdownMenuEntry<String>> prioridadeEntries = [
    DropdownMenuEntry<String>(value: "baixa", label: "Baixa"),
    DropdownMenuEntry<String>(value: "media", label: "Média"),
    DropdownMenuEntry<String>(value: "alta", label: "Alta"),
  ];

  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  String _prioridade = "baixa";
  void _changePrioridade(String para) {
    setState(() {
      _prioridade = para;
    });
  }

  DateTime _prazo = DateTime.now();
  void _changePrazo(DateTime novo) {
    setState(() {
      _prazo = novo;
    });
  }

  @override
  initState() {
    _prazo = widget._tarefa.dataVencimento;
    _tituloController.text = widget._tarefa.titulo;
    _descricaoController.text = widget._tarefa.descricao;
    _prioridade = widget._tarefa.prioridade;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppThemes.currentTheme,
      builder: (context, value, child) {
        return Material(
          //TextField precisa estar sob um Material (acho que o pop-up é separado do MaterialApp raiz?)
          child: Theme(
            data: AppThemes.currentThemeData,
            child: DefaultTextStyle(
              style: AppThemes.currentThemeData.textTheme.bodyMedium!,
              child: Center(
                child: Dialog(
                  backgroundColor: AppThemes.colorScheme.surfaceContainer,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        Text(
                          "Detalhes da tarefa:",
                          style: TextStyle(
                            color: AppThemes.textoContraste(0.5),
                          ),
                        ),
                        SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 640),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: .min,
                              children: [
                                TextFormField(
                                  controller: _tituloController,
                                  decoration: InputDecoration(
                                    labelText: 'Título',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Campo "Título" vazio';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                ConstrainedBox(
                                  // tentar não dar overflow quando a descrição for muito longa
                                  constraints: BoxConstraints(maxHeight: 180),
                                  child: SingleChildScrollView(
                                    child: TextFormField(
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      controller: _descricaoController,
                                      decoration: InputDecoration(
                                        labelText: 'Descrição',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Campo "Descrição" vazio';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),
                                DropdownMenu<String>(
                                  label: Text("Prioridade"),
                                  initialSelection: _prioridade,
                                  dropdownMenuEntries: prioridadeEntries,
                                  onSelected: (value) {
                                    _changePrioridade(value ?? "baixa");
                                  },
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    //botão um pouquinho mais quadrado (prioridades)
                                    shape:
                                        WidgetStateProperty.resolveWith<
                                          OutlinedBorder?
                                        >((Set<WidgetState> states) {
                                          return RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadiusGeometry.all(
                                                  Radius.circular(16),
                                                ),
                                          );
                                        }),
                                  ),
                                  onPressed: () async {
                                    DateTime? datahora = await abrirDataEHora(
                                      context,
                                    );
                                    if (datahora != null && context.mounted) {
                                      _changePrazo(datahora);
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 30,
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      "Prazo: ${Tarefa.getPrazoText(_prazo)}",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisSize: .min,
                          mainAxisAlignment: .spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, widget._tarefa);
                              },
                              child: Text("Voltar"),
                            ),
                            SizedBox(width: 128),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  widget._tarefa.titulo =
                                      _tituloController.text;
                                  widget._tarefa.descricao =
                                      _descricaoController.text;
                                  widget._tarefa.prioridade = _prioridade;
                                  widget._tarefa.dataVencimento = _prazo;
                                  widget._tarefa.save();
                                  Navigator.pop(context, widget._tarefa);
                                }
                              },
                              child: Text("Salvar"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //Abre seletor de data e hora em conjunto
  static Future<DateTime?> abrirDataEHora(BuildContext context) async {
    DateTime? date = await showDatePicker(
      locale: const Locale('pt', 'BR'),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null || !context.mounted) {
      return null;
    } else {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: date.hour, minute: date.minute),
      );
      if (time == null || !context.mounted) {
        return null;
      }
      date = date.add(Duration(hours: time.hour, minutes: time.minute));
    }

    return date;
  }
}
