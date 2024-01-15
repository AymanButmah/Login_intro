// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
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

  final db = DatabaseHelper();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User"),
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
                    Navigator.pop(context);
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
                ),
              ],
            ),
          )),
    );
  }
}
