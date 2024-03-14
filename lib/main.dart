
import 'package:app_final/models/Restaurant.dart';
import 'package:app_final/screens/HomeScreen.dart';
import 'package:app_final/screens/MapScreen.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/services/StorageService.dart';
import 'package:app_final/screens/SignUpScreen.dart';
import 'package:app_final/models/AppUser.dart';
import 'package:app_final/screens/SignInScreen.dart';
import 'package:app_final/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(ChangeNotifierProvider.value(
    value: UserService.currentUser,
    child: MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final NavigationService navigation = NavigationService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Authentication(),
      routes: {
        '/signIn': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        // Añadir más rutas según las pantallas
      },
    );
  }
}

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  AuthenticationState createState() => AuthenticationState();
}

class AuthenticationState extends State<Authentication> {
  bool isLoading = true;
  bool? remembered;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    await dotenv.load(fileName: 'supabase_initialize.env');
    await Supabase.initialize(anonKey: dotenv.env['SUPABASE_KEY']!, url: dotenv.env['SUPABASE_URL']!);
    await UserService.initSupabaseListeners();
    UserService.registeredUsers = await ApiService.getAllItems<AppUser>(fromJson: AppUser.fromJson);
    UserService.currentUser.value = await StorageService.loadGeneric('lastUser', AppUser.fromJson);
    
    remembered = await StorageService.loadBool("rememberMe") ?? false;
    
    Restaurant.restaurants = await ApiService.getAllItems<Restaurant>(fromJson: Restaurant.fromJson);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    if (isLoading) {
      return const LoadingScreen();
    } 
    if (UserService.currentUser.value == null || !remembered!) {
      return const SignInScreen();
    }
    return const HomeScreen();
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Image.network('https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/Recurso%2090.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL1JlY3Vyc28gOTAucG5nIiwiaWF0IjoxNzA5MDU4MzE5LCJleHAiOjE3NDA1OTQzMTl9.0engAy6Xk3U-Z8BZ8JnxBZ4evMa03BY_aaPxHkS6AFg&t=2024-02-27T18%3A25%3A23.095Z'),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        )
      ),
    );
  }
}

