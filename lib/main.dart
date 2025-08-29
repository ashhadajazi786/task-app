import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Screens
import 'screens/splashscreen.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/userdetails.dart';
import 'screens/api_product_screen.dart';

// Provider
import 'provider/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(), // constructor already calls listenToTasks
        ),
      ],
      child: MaterialApp(
        title: 'Task Manager App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const Login(),
          '/signup': (context) => const Signup(),
          '/home': (context) => HomePage(),
          '/userdetails': (context) => UserDetailsPage(),
          '/api_product_screen': (context) => const UserListPage(),
        },
      ),
    );
  }
}

// Auth wrapper to check if user is logged in
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData) {
          return HomePage(); // logged in
        } else {
          return const Login(); // not logged in
        }
      },
    );
  }
}
