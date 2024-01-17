// ignore_for_file: use_build_context_synchronously, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  // late DatabaseHelper handler;

  late Stream<List<User>> usersStream;
  final db = Get.find<DatabaseHelper>();
  final formKey = GlobalKey<FormState>();

  RxList get filteredData => Get.find<DatabaseHelper>().filteredData;
  List get userData => Get.find<DatabaseHelper>().userData;

  final username = TextEditingController();
  final password = TextEditingController();
  final inputKey = TextEditingController();

  @override
  void initState() {
    chadMethod();

    super.initState();
  }

  chadMethod() async {
    await Get.find<DatabaseHelper>().init();

    // Get.find<DatabaseHelper>().listenAllUsers().listen((event) {
    //   userData = event.map((e) => User.fromJson(e)).toList();
    // });
    await Get.find<DatabaseHelper>().getUsers();
    filteredData.value = userData;
  }

  Future<List<User>> getAllUsers() {
    return Get.find<DatabaseHelper>().getUsers();
  }

  void searchUser() {
    filteredData.value = userData
        .where((user) =>
            user.userName!.toLowerCase().contains(inputKey.text.toLowerCase()))
        .toList();
  }

  void _deleteData(int id) async {
    await Get.find<DatabaseHelper>().deleteUser(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text("User Deleted Successfully!"),
      ),
    );
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
              MaterialPageRoute(builder: (context) => const CreateUser()));
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
                  print("Search");

                  searchUser();
                } else {
                  filteredData.value = userData;
                }
              },
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                  hintText: "Search"),
            ),
          ),
          Expanded(
            child: Obx(
              () => filteredData.value.isEmpty
                  ? const Center(child: Text('No users available'))
                  : Builder(
                      // future: users,listenAllUsers
                      //userStream
                      builder: (context) {
                        return Obx(
                          () => ListView.builder(
                            itemCount: filteredData.value.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditUser(
                                          user: filteredData.value[index]),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    title: Text(filteredData.value[index].userId
                                            ?.toString() ??
                                        ""),
                                    subtitle: Text(
                                        filteredData.value[index].userName ??
                                            ""),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        // db.deleteUser(userList[index].userId!);
                                        _deleteData(
                                            filteredData.value[index].userId ??
                                                0);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
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
}
