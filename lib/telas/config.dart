import 'package:flutter/material.dart';
import 'package:flutter_f/services/prefs.dart';
import 'package:flutter_f/themes/app_themes.dart';
import 'package:flutter_f/widgets/main_drawer.dart';

class Config extends StatefulWidget {
  const Config({super.key, required this.title});

  final String title;
  @override
  State<StatefulWidget> createState() => ConfigState();
}

class ConfigState extends State<Config> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppThemes.currentTheme,
      builder: ((context, value, child) {
        return Theme(
          data: AppThemes.currentThemeData,
          child: Scaffold(
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
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: .center,
                      children: [
                        Text(
                          "Tema: ${AppThemes.currentTheme.value == ThemeMode.dark ? "Escuro" : "Claro"}",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 20),
                        Switch(
                          value: AppThemes.currentTheme.value == ThemeMode.dark,
                          onChanged: (value) {
                            AppThemes.currentTheme.value =
                                AppThemes.currentTheme.value == ThemeMode.dark
                                ? ThemeMode.light
                                : ThemeMode.dark;
                            Prefs.salvarTema(AppThemes.currentTheme.value == ThemeMode.light);
                          },
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
      }),
    );
  }
}
