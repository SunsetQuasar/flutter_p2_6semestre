import 'package:flutter/material.dart';
import 'package:flutter_f/themes/app_themes.dart';

class TransitionResult {
  TransitionResult({required this.success, this.error});
  final bool success;
  final String? error;
}

class AsyncTransition extends PopupRoute<TransitionResult> {
  AsyncTransition({required this.promise});
  final Future<TransitionResult> promise;

  static Future<TransitionResult?> createTransition(
    BuildContext context,
    Future<TransitionResult> promise,
  ) {
    return Navigator.push(context, AsyncTransition(promise: promise));
  }

  @override
  Color? get barrierColor => Colors.black.withAlpha(0x50);

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => "Aguarde...";

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return ValueListenableBuilder(
      valueListenable: AppThemes.currentTheme,
      builder: (context, value, child) {
        return Theme(
          data: AppThemes.currentThemeData,
          child: FutureBuilder(
            future: promise,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context, snapshot.data as TransitionResult);
                });
              }
              return DefaultTextStyle(
                style: AppThemes.currentThemeData.textTheme.bodyMedium!,
                child: Center(
                  child: Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(height: 20),
                      Text("Aguarde...", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Duration get transitionDuration => Durations.medium1;
}
