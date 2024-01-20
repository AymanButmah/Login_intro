import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_project/providers/provider.dart';
import 'package:intro_project/sql/sqlite.dart';
import 'package:intro_project/views/user_archive.dart';
import 'package:intro_project/views/welcome_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(DatabaseHelper()).init();
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
        return GetMaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          title: 'Flutter Login',
          home:
              provider.rememberMe ? const UserArchive() : const WelcomeScreen(),
        );
      }),
    );
  }
}
