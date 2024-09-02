import 'package:flutter/material.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/todo_screen.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'opt';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAt4eF5zeAlNXfY0NHAehl8DUFP-6_jyy8",
        appId: "1:886475484274:android:20b0093e94cff809df26eb",
        messagingSenderId: "886475484274",
        projectId: "to-do-app-22b4e"
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/todo': (context) => const TodoScreen()
      },
    );
  }
}
