// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intro_project/models/user.dart';
import 'package:intro_project/providers/provider.dart';
import 'package:intro_project/views/create_userPage.dart';
import 'package:intro_project/views/edit_userPage.dart';
import 'package:intro_project/views/welcome_screen.dart';
import 'package:intro_project/sql/sqlite.dart';
import 'package:provider/provider.dart';

class Archive extends StatefulWidget {
  const Archive({super.key});

  @override
  State<Archive> createState() => _ArchiveState();
}

class _ArchiveState extends State<Archive> {
  late DatabaseHelper handler;
  late Future<List<User>> users;
  final db = DatabaseHelper();
  final formKey = GlobalKey<FormState>();

  final username = TextEditingController();
  final password = TextEditingController();
  final inputKey = TextEditingController();

  @override
  void initState() {
    handler = DatabaseHelper();
    users = handler.getUsers();

    handler.initDB().whenComplete(() {
      users = getAllUsers();
    });
    super.initState();
  }

  Future<List<User>> getAllUsers() {
    return handler.getUsers();
  }

  Future<List<User>> searchUser() {
    return handler.searchUser(inputKey.text);
  }

  void _deleteData(int id) async {
    await handler.deleteUser(id);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text("User Deleted Successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.maybePop(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WelcomeScreen()));
                  },
                  icon: const Icon(Icons.arrow_back_rounded)),
              const Text("User List"),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CreateUser()))
              .then((value) {
            if (value) {
              // _refresh();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.2),
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              controller: inputKey,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    users = searchUser();
                  });
                } else {
                  setState(() {
                    users = getAllUsers();
                  });
                }
              },
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                  hintText: "Search"),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<User>>(
              stream: DatabaseHelper().listenAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final userList = snapshot.data ?? <User>[];

                  return userList.isEmpty
                      ? const Center(child: Text('No users available'))
                      : ListView.builder(
                          itemCount: userList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditUser(user: userList[index]),
                                  ),
                                );

                                // showDialog(
                                //     context: context,
                                //     builder: (context) {
                                //       return AlertDialog(
                                //         actions: [
                                //           Row(
                                //             children: [
                                //               TextButton(
                                //                 onPressed: () {
                                //                   if (formKey.currentState!
                                //                       .validate()) {
                                //                     db
                                //                         .updateUser(
                                //                       username.text,
                                //                       password.text,
                                //                       userList[index].userId,
                                //                     )
                                //                         .whenComplete(() {
                                //                       _refresh();
                                //                       Navigator.pop(context);
                                //                     });
                                //                   }
                                //                 },
                                //                 child: const Text("Update"),
                                //               ),
                                //               TextButton(
                                //                 onPressed: () {
                                //                   Navigator.pop(context);
                                //                 },
                                //                 child: const Text("Cancel"),
                                //               ),
                                //             ],
                                //           ),
                                //         ],
                                //         title: const Text("Update User"),
                                //         content: Form(
                                //           key: formKey,
                                //           child: Column(
                                //               mainAxisSize: MainAxisSize.min,
                                //               children: [
                                //                 TextFormField(
                                //                   controller: username,
                                //                   validator: (value) {
                                //                     if (value == null ||
                                //                         value.isEmpty) {
                                //                       return "Username is required";
                                //                     }
                                //                     return null;
                                //                   },
                                //                   decoration:
                                //                       const InputDecoration(
                                //                     label: Text("Username"),
                                //                   ),
                                //                 ),
                                //                 TextFormField(
                                //                   controller: password,
                                //                   validator: (value) {
                                //                     if (value == null ||
                                //                         value.isEmpty) {
                                //                       return "Password is required";
                                //                     }
                                //                     return null;
                                //                   },
                                //                   decoration:
                                //                       const InputDecoration(
                                //                     label: Text("Password"),
                                //                   ),
                                //                 ),
                                //               ]),
                                //         ),
                                //       );
                                //     });
                              },
                              child: Card(
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  title: Text(
                                      userList[index].userId?.toString() ?? ""),
                                  subtitle:
                                      Text(userList[index].userName ?? ""),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      // db.deleteUser(userList[index].userId!);
                                      _deleteData(userList[index].userId ?? 0);
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                }
              },
            ),
          ),
          Consumer<SessionProvider>(
            builder: (context, SessionProvider provider, child) {
              return ElevatedButton(
                onPressed: () {
                  provider.logout(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color(0xFF416FDF),
                  ),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  elevation: MaterialStateProperty.all<double>(5.0),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                child: const Text('Sign Out'),
              );
            },
          )
        ],
      ),
    );
  }

  // bool validate() {
  //   if (username.text.isEmpty) {
  //     return false;
  //   }

  //   if (password.text.isEmpty) {
  //     return false;
  //   }

  //   return true;
  // }
}
