import 'package:app_final/models/AppUser.dart';
import 'package:collection/collection.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/services/StorageService.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static List<AppUser> registeredUsers = [];
  static ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  static Future<void> initSupabaseListeners() async {
    final supabaseClient = Supabase.instance.client;

    supabaseClient.auth.onAuthStateChange.listen((data) async {
      if (data.session != null) {
        AppUser? userAfterEvent = registeredUsers.firstWhereOrNull(
          (user) => user.id == data.session!.user.id);        

        switch (data.event) {
          case AuthChangeEvent.signedIn:
            currentUser.value = userAfterEvent;
            print(toJson(userAfterEvent!));
            break;
          case AuthChangeEvent.initialSession:
            currentUser.value = userAfterEvent;
            print(toJson(userAfterEvent!));
            break;
          case AuthChangeEvent.userDeleted:
            await ApiService.deleteItem(userAfterEvent!.id);
            break;
          case AuthChangeEvent.signedOut:
            await handleSignOut();
            break;
          case AuthChangeEvent.userUpdated:
            await updateCurrentUser(userAfterEvent!);
            break;
          default:
            break;
        }
      }
    }); 
  }

  static Future<void> handleSignOut() async {
    await StorageService.saveGeneric('lastUser', currentUser.value!, AppUser.toJson);
    currentUser.value = null;
    ApiService.userToken = null;
  }

  static Future<void> updateCurrentUser(AppUser updatedUser) async {
    await ApiService.updateItem<AppUser>(updatedUser, updatedUser.id);
    currentUser.value = updatedUser;
  }
}