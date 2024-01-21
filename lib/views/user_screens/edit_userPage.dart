// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_project/models/user.dart';
import 'package:intro_project/sql/sqlite.dart';

class EditUser extends StatefulWidget {
  User user;
  EditUser({super.key, required this.user});

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final username = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final db = Get.find<DatabaseHelper>();

  @override
  void initState() {
    username.text =
        widget.user.userName == "null" ? "" : widget.user.userName ?? "";
    password.text = widget.user.userPassword == "null"
        ? ""
        : widget.user.userPassword ?? "";
    super.initState();
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User", style: TextStyle(color: Colors.blue)),
        actions: [
          IconButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  db
                      .updateUser(
                    username.text,
                    password.text,
                    widget.user.userId,
                  )
                      .whenComplete(() {
                    Get.back();
                  });
                }
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  controller: username,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Username is required";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    label: Text("Username"),
                  ),
                  onEditingComplete: () {
                    FocusScope.of(context).nextFocus();
                  },
                ),
                TextFormField(
                  controller: password,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password is required";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    label: Text("Password"),
                  ),
                  onEditingComplete: () {
                    _submitForm();
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Update User"),
                ),
              ],
            ),
          )),
    );
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      db
          .updateUser(
        username.text,
        password.text,
        widget.user.userId,
      )
          .whenComplete(() {
        Get.back();
      });
    }
  }
}
