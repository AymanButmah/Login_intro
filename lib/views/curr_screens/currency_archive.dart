// ignore_for_file: invalid_use_of_protected_member, must_be_immutable, non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_project/providers/provider.dart';
import 'package:intro_project/sql/sqlite.dart';
import 'package:intro_project/views/curr_screens/create_currPage.dart';
import 'package:intro_project/views/curr_screens/edit_currPage.dart';
import 'package:intro_project/widgets/navDrawer.dart';
import 'package:provider/provider.dart';

class CurrencyArchive extends StatefulWidget {
  const CurrencyArchive({super.key});

  @override
  State<CurrencyArchive> createState() => _CurrencyArchiveState();
}

class _CurrencyArchiveState extends State<CurrencyArchive> {
  final db = Get.find<DatabaseHelper>();
  final formKey = GlobalKey<FormState>();

  RxList get filteredCurrencyData =>
      Get.find<DatabaseHelper>().filteredCurrencyData;
  List get CurrencyData => Get.find<DatabaseHelper>().currencyData;

  final inputKey = TextEditingController();

  @override
  void initState() {
    chadMethod();
    super.initState();
  }

  chadMethod() async {
    //Get data from Database through list
    await Get.find<DatabaseHelper>().init();
    await Get.find<DatabaseHelper>().getCurrencies();
    filteredCurrencyData.value = CurrencyData;
  }

  void _deleteData(int id) async {
    //Getx Library widget to make delete animation
    // delete Currency through registerd ID
    await Get.find<DatabaseHelper>().deleteCurrency(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Currency Deleted Successfully!"),
      ),
    );
  }

  //filter
  void searchCurrency() {
    //search through currency name in database (inputkey)
    filteredCurrencyData.value = CurrencyData.where((currency) => currency
        .currencyName!
        .toLowerCase()
        .contains(inputKey.text.toLowerCase())).toList();
  }

  Widget buildCurrencyIcon(int index) {
    //the default currencies not linked with differenct Icon
    String currencySymbol =
        filteredCurrencyData.value[index].currencySymbol ?? "";

    if (currencySymbol == "\$") {
      return const Icon(Icons.attach_money);
    } else if (currencySymbol == "₪") {
      return const Icon(Icons.money);
    } else if (currencySymbol == "€") {
      return const Icon(Icons.euro);
    } else if (currencySymbol == "JOD") {
      return const Icon(Icons.join_left_rounded);
    } else {
      return const Icon(Icons.currency_exchange);
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
                "Currency List",
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
          Get.to(() => const CreateCurrency());
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
                  searchCurrency();
                } else {
                  //bring back the list if the field is empty
                  filteredCurrencyData.value = CurrencyData;
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
              () => filteredCurrencyData.value.isEmpty
                  ? const Center(child: Text('No Currency available'))
                  : Builder(
                      builder: (context) {
                        return Obx(
                          () => ListView.builder(
                            itemCount: filteredCurrencyData.value.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Get.to(() => EditCurrency(
                                      currency:
                                          filteredCurrencyData.value[index]));
                                },
                                child: Card(
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    leading: buildCurrencyIcon(index),
                                    title: Text(
                                      "Currency ID: ${filteredCurrencyData.value[index].currencyId?.toString() ?? ""}",
                                      style:
                                          const TextStyle(color: Colors.blue),
                                    ),
                                    subtitle: Text(
                                        "${filteredCurrencyData.value[index].currencyName ?? ""} "),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () {
                                        _deleteData(filteredCurrencyData
                                                .value[index].currencyId ??
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
