import 'package:flutter/material.dart';
import 'package:path/path.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Quita la pantalla actual y la sustituye por newScreen.
  static void replaceScreen(BuildContext context, Widget newScreen) {
    removeScreen(context);
    showScreen(context, newScreen);
  }

  static void removeScreen(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static void showScreen(BuildContext context, Widget newScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => newScreen),
    );
  }

  // Quita la pantalla actual e inicia la navegación a una nueva pantalla según su ruta
  static void replaceWithNamed(String routeName, BuildContext context, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Restablece el árbol de widgets y muestra newScreen.
  static void clearStackAndShowScreen(BuildContext context, Widget newScreen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => newScreen),
      (Route<dynamic> route) => false,
    );
  }

  // Abre una alerta y pide confirmación para salir.
  static Future<bool> confirmExit(BuildContext context, String message) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí'),
          ),
        ],
      ),
    )) ?? false;
  }
}