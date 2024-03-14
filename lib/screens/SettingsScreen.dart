import 'package:app_final/screens/ProfileScreen.dart';
import 'package:app_final/screens/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_final/services/NavigationService.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          NavigationService.replaceScreen(context, const ProfileScreen());
        },
      ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _confirmSignOut(context),
          child: const Text('Cerrar Sesión'),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    bool confirm = await NavigationService.confirmExit(context, '¿Estás seguro de que quieres cerrar sesión?');
    if (confirm) {
      await _signOut(context);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    NavigationService.clearStackAndShowScreen(context, SignInScreen());
  }
}
