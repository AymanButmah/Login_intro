// ignore_for_file: use_build_context_synchronously, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_project/providers/provider.dart';
import 'package:intro_project/views/user_screens/create_userPage.dart';
import 'package:intro_project/views/user_screens/edit_userPage.dart';
import 'package:intro_project/sql/sqlite.dart';
import 'package:intro_project/widgets/navDrawer.dart';
import 'package:provider/provider.dart';

class UserArchive extends StatefulWidget {
  const UserArchive({super.key});

  @override
  State<UserArchive> createState() => _UserArchiveState();
}

class _UserArchiveState extends State<UserArchive> {
  final db = Get.find<DatabaseHelper>();
  final formKey = GlobalKey<FormState>();

  RxList get filteredData => Get.find<DatabaseHelper>().filteredUserData;
  List get userData => Get.find<DatabaseHelper>().userData;

  final inputKey = TextEditingController();

  @override
  void initState() {
    chadMethod();
    super.initState();
  }

  chadMethod() async {
    await Get.find<DatabaseHelper>().init();
    await Get.find<DatabaseHelper>().getUsers();
    filteredData.value = userData;
  }

  //filter
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
      drawer: const navDrawer(),
      appBar: AppBar(
        title: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "User List",
                style: TextStyle(color: Colors.blue),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const CreateUser());
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
                      builder: (context) {
                        return Obx(
                          () => ListView.builder(
                            itemCount: filteredData.value.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Get.to(() => EditUser(
                                      user: filteredData.value[index]));
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
                                      "User ID: ${filteredData.value[index].userId?.toString() ?? ""}",
                                      style:
                                          const TextStyle(color: Colors.blue),
                                    ),
                                    subtitle: Text(
                                        "Name: ${filteredData.value[index].userName ?? ""} "),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
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
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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
