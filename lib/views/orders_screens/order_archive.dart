// ignore_for_file: invalid_use_of_protected_member, must_be_immutable, non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_project/models/order.dart';
import 'package:intro_project/models/user.dart';
import 'package:intro_project/providers/provider.dart';
import 'package:intro_project/providers/switch_status.dart';
import 'package:intro_project/sql/sqlite.dart';
import 'package:intro_project/views/orders_screens/create_orderPage.dart';
import 'package:intro_project/views/orders_screens/edit_orderPage.dart';
import 'package:intro_project/widgets/navDrawer.dart';
import 'package:provider/provider.dart';

class OrderArchive extends StatefulWidget {
  const OrderArchive({super.key});

  @override
  State<OrderArchive> createState() => _OrderArchiveState();
}

class _OrderArchiveState extends State<OrderArchive> {
  final db = Get.find<DatabaseHelper>();
  final formKey = GlobalKey<FormState>();

  RxList get filteredOrderData => Get.find<DatabaseHelper>().filteredOrderData;
  List get orderData => Get.find<DatabaseHelper>().orderData;

  RxList<User> get filteredUserData =>
      Get.find<DatabaseHelper>().filteredUserData;
  List<User> get userData => Get.find<DatabaseHelper>().userData;

  final SwitchController sswitchController =
      Get.put(SwitchController(), permanent: true);

  @override
  void initState() {
    chadMethod();
    super.initState();
  }

  chadMethod() async {
    await Get.find<DatabaseHelper>().init();
    await Get.find<DatabaseHelper>().getOrders();
    await Get.find<DatabaseHelper>().getUsers();

    filteredOrderData.value = orderData;
    filteredUserData.value = userData;
  }

  Future<void> fetchAndSetOrders(int userId) async {
    List<Order> orders =
        await Get.find<DatabaseHelper>().getOrdersByUserId(userId);
    filteredOrderData.value = orders;
  }

  void _deleteData(int id) async {
    await Get.find<DatabaseHelper>().deleteOrder(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Order Deleted Successfully!"),
      ),
    );
  }

  Widget buildOrderIcon(int index) {
    bool OrderStatus = filteredOrderData.value[index].status ?? false;

    if (OrderStatus == true) {
      return const Icon(
        Icons.done_all_rounded,
        color: Colors.green,
      );
    } else if (OrderStatus == false) {
      return const Icon(
        Icons.warning_amber_rounded,
        color: Colors.orange,
      );
    } else {
      return const Icon(
        Icons.error,
        color: Colors.red,
      );
    }
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
                "Order List",
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
          Get.to(() => CreateOrder());
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
            child: Autocomplete<User>(
              optionsBuilder: (TextEditingValue value) {
                if (value.text.isEmpty) {
                  return [];
                }
                return filteredUserData.value
                    .where((user) => user.userName!
                        .toLowerCase()
                        .contains(value.text.toLowerCase()))
                    .toList();
              },
              onSelected: (value) {
                Get.find<DatabaseHelper>()
                    .getAllOrdersByUser(value.userId)
                    .then((value) {
                  filteredOrderData.value = value;
                });
              },
            ),
          ),
          Expanded(
            child: Obx(
              () => filteredOrderData.isEmpty
                  ? const Center(child: Text('No Order available'))
                  : Builder(
                      builder: (context) {
                        return ListView.builder(
                          itemCount: filteredOrderData.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrderData[index];
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => EditOrder(order: order));
                              },
                              child: Card(
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  leading: GetBuilder<SwitchController>(
                                    init: SwitchController(),
                                    builder: (switchController) => Switch(
                                      value: order.status,
                                      onChanged: (newStatus) {
                                        sswitchController
                                            .changeStatus(newStatus);
                                        order.status = newStatus;
                                        db.updateStatusOrder(
                                            newStatus, order.orderId);
                                        print(
                                            "Order status changed to: $newStatus");
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    "Order ID: ${order.orderId?.toString() ?? ""} ~ Order Amount: ${order.orderAmount?.toString() ?? ""}",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  subtitle: Text(
                                      "Name: ${userData.where((element) => element.userId == order.userId).first.userName ?? ""} "),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _deleteData(order.orderId ?? 0);
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
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
