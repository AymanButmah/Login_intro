// ignore_for_file: invalid_use_of_protected_member, must_be_immutable, non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_project/providers/provider.dart';
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

  final inputKey = TextEditingController();

  @override
  void initState() {
    chadMethod();
    super.initState();
  }

  chadMethod() async {
    await Get.find<DatabaseHelper>().init();
    await Get.find<DatabaseHelper>().getOrders();
    filteredOrderData.value = orderData;
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

  // filter
  void searchOrder() {
    filteredOrderData.value =
        orderData.where((order) => order.orderId == inputKey.text).toList();
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
          Get.to(() => const CreateOrder());
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
                  searchOrder();
                } else {
                  filteredOrderData.value = orderData;
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
                  ? const Center(child: Text('No Order available'))
                  : Builder(
                      builder: (context) {
                        return Obx(
                          () => ListView.builder(
                            itemCount: filteredOrderData.value.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Get.to(() => EditOrder(
                                      order: filteredOrderData.value[index]));
                                },
                                child: Card(
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    leading: buildOrderIcon(index),
                                    title: Text(
                                      "Order ID: ${filteredOrderData.value[index].orderId?.toString() ?? ""} ~ Order Amount: ${filteredOrderData.value[index].orderAmount?.toString() ?? ""}",
                                      style:
                                          const TextStyle(color: Colors.blue),
                                    ),
                                    subtitle: Text(
                                        "User ID: ${filteredOrderData.value[index].userId ?? ""} "),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () {
                                        _deleteData(filteredOrderData
                                                .value[index].orderId ??
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
