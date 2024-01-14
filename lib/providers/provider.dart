import 'package:flutter/material.dart';
import 'package:intro_project/views/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionProvider extends ChangeNotifier {
  bool _isChecked = false;
  bool get isChecked => _isChecked;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  late SharedPreferences storage;

  toggleChecked() {
    _isChecked = !isChecked;
    notifyListeners();
  }

  setRememberMe() {
    _rememberMe = true;

    storage.setBool("rememberMe", _rememberMe);
    notifyListeners();
  }

  logout(context) {
    _rememberMe = false;

    storage.setBool("rememberMe", _rememberMe);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SignInScreen()));
    notifyListeners();
  }

  initStorage() async {
    storage = await SharedPreferences.getInstance();
    _rememberMe = storage.getBool("rememberMe") ?? false;
    notifyListeners();
  }
}
