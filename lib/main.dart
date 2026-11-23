import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_f/models/tarefa.dart';
import 'package:flutter_f/services/db.dart';
import 'package:flutter_f/services/auth.dart';
import 'package:flutter_f/services/prefs.dart';
import 'package:flutter_f/telas/config.dart';
import 'package:flutter_f/telas/main_screen.dart';
import 'package:flutter_f/telas/inicio.dart';
import 'package:flutter_f/telas/login.dart';
import 'package:flutter_f/telas/signup.dart';
import 'package:flutter_f/themes/app_themes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'telas/tarefas_list.dart';

WidgetsBinding? widgetsFlutterBinding;

void main() async {
  Intl.defaultLocale = 'pt_BR';

  await initializeDateFormatting(Intl.defaultLocale!);

  widgetsFlutterBinding = WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  AppThemes.currentTheme.value = (await Prefs.carregarTema() ?? true)
      ? ThemeMode.light
      : ThemeMode.dark;

  Database.init();

  Auth.escutarAlteracoes();

  Tarefa.escutarAlteracoes(); //escutar qualquer alteração
  Tarefa.updateTarefas(); //popular a lista inicial

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter P2',
      themeMode: AppThemes.currentTheme.value,
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      initialRoute: '/inicio',
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('en'),
        const Locale('pt', 'BR'),
      ],
      routes: {
        '/config': (context) => Config(title: "Configurações"),
        '/main': (context) => const MainScreen(title: 'Página Principal'),
        '/tarefas': (context) => const TarefasList(title: 'Minhas Tarefas'),
        '/inicio': (context) => const Inicio(title: 'Início'),
        '/login': (context) => const Login(title: 'Login'),
        '/signup': (context) => const Signup(title: 'Criar Usuário'),
      },
    );
  }
}
