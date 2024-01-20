// ignore_for_file: invalid_use_of_protected_member, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_project/models/user.dart';
import 'package:intro_project/providers/provider.dart';
import 'package:intro_project/widgets/navDrawer.dart';
import 'package:provider/provider.dart';

class OrderArchive extends StatelessWidget {
  OrderArchive({super.key});

  RxList filteredOrderData = [].obs;
  List<User> orderData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const navDrawer(),
      appBar: AppBar(
        title: const SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Order List",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Get.to(() => const CreateUser());
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
              // controller: inputKey,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  // searchUser();
                } else {
                  // filteredData.value = userData;
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
              () => filteredOrderData.value.isEmpty
                  ? const Center(child: Text('No Order Available'))
                  : Builder(
                      builder: (context) {
                        // Dummy data for testing
                        List<User> dummyData = [
                          User(userId: 1, userName: 'John Doe'),
                          User(userId: 2, userName: 'Jane Doe'),
                          // Add more dummy data as needed
                        ];

                        return Obx(
                          () => ListView.builder(
                            itemCount: dummyData.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  // Replace with actual navigation logic
                                  // Get.to(() => EditUser(user: dummyData[index]));
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
                                      "User ID: ${dummyData[index].userId?.toString() ?? ""}",
                                      style:
                                          const TextStyle(color: Colors.blue),
                                    ),
                                    subtitle: Text(
                                        "Name: ${dummyData[index].userName ?? ""} "),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () {
                                        // Replace with actual delete logic
                                        // _deleteData(dummyData[index].userId ?? 0);
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
