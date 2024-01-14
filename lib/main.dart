import 'package:flutter/material.dart';
import 'package:intro_project/providers/provider.dart';
import 'package:intro_project/views/archive.dart';
import 'package:intro_project/views/welcome_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SessionProvider()..initStorage(),
      child: Consumer<SessionProvider>(
          builder: (context, SessionProvider provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Login',
          home: provider.rememberMe ? const Archive() : const WelcomeScreen(),
        );
      }),
    );
  }
}
