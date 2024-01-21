// ignore_for_file: file_names, must_be_immutable, unrelated_type_equality_checks, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intro_project/models/currency.dart';
import 'package:intro_project/models/order.dart';
import 'package:intro_project/models/user.dart';
import 'package:intro_project/sql/sqlite.dart';

class EditOrder extends StatefulWidget {
  Order order;
  EditOrder({super.key, required this.order});

  @override
  State<EditOrder> createState() => _EditOrderState();
}

class _EditOrderState extends State<EditOrder> {
  final orderDate = TextEditingController();
  final orderAmount = TextEditingController();
  final equalOrderAmount = TextEditingController();
  final status = TextEditingController();
  final orderType = TextEditingController();
  String? _userId;
  String? _currencyId;
  String? _userName;
  String? _currencyName;
  final formKey = GlobalKey<FormState>();
  final db = Get.find<DatabaseHelper>();

  RxList get filteredUserData => Get.find<DatabaseHelper>().filteredUserData;
  RxList get filteredCurrencyData =>
      Get.find<DatabaseHelper>().filteredCurrencyData;
  List<User> get userData => Get.find<DatabaseHelper>().userData;
  List<Currency> get currencyData => Get.find<DatabaseHelper>().currencyData;

  @override
  void initState() {
    orderDate.text =
        widget.order.orderDate == "null" ? "" : widget.order.orderDate ?? "";
    orderAmount.text = widget.order.orderAmount == null
        ? "0.0"
        : widget.order.orderAmount.toString();
    equalOrderAmount.text = widget.order.equalOrderAmount == null
        ? "0.0"
        : widget.order.equalOrderAmount.toString();
    status.text =
        widget.order.status == "null" ? "" : widget.order.status.toString();
    orderType.text =
        widget.order.orderType == "null" ? "" : widget.order.orderType ?? "";
    _userId =
        widget.order.userId == null ? "0" : widget.order.userId.toString();
    _currencyId = widget.order.currencyId == null
        ? "0"
        : widget.order.currencyId.toString();

    super.initState();
  }

  @override
  void dispose() {
    orderDate.dispose();
    orderAmount.dispose();
    equalOrderAmount.dispose();
    status.dispose();
    orderType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Order", style: TextStyle(color: Colors.blue)),
        actions: [
          IconButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  db
                      .updateOrder(
                          widget.order.orderId,
                          orderDate.text,
                          orderAmount.text,
                          equalOrderAmount.text,
                          _currencyId,
                          status.text,
                          orderType.text,
                          _userId)
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
                controller: orderDate,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Order Date is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[^0-9/]')),
                ],
                decoration: InputDecoration(
                  labelText: "Order Date",
                  suffixIcon: IconButton(
                      onPressed: () async {
                        await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 1),
                          initialDate: DateTime.now(),
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              orderDate.text =
                                  DateFormat("dd/MM/yyyy").format(value);
                            });
                          }
                        });
                      },
                      icon: const Icon(Icons.date_range_outlined)),
                ),
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
              ),
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Choose Curr: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text(_currencyName ?? "Choose Curr"),
                            onChanged: (String? value) {
                              setState(() {
                                _currencyId = value ?? "";
                              });
                            },
                            items:
                                (filteredCurrencyData.value as List<Currency>)
                                    .map((Currency curr) {
                              return DropdownMenuItem<String>(
                                onTap: () {
                                  setState(() {
                                    _currencyName =
                                        curr.currencyName.toString();
                                  });
                                },
                                value: curr.currencyId.toString(),
                                child: Text(curr.currencyName.toString()),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                autofocus: true,
                controller: orderAmount,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Order Amount is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Order Amount",
                ),
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                autofocus: true,
                controller: equalOrderAmount,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Equal Order Amount is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Equal Order Amount",
                ),
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
              ),
              const SizedBox(height: 5),
              DropdownButtonHideUnderline(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey), // Add a border for styling
                    borderRadius:
                        BorderRadius.circular(8), // Add rounded corners
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Status: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          hint: Text(status.text),
                          onChanged: (String? value) {
                            setState(() {
                              status.text = value ?? "";
                            });
                          },
                          items: ["Active", "Inactive"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              DropdownButtonHideUnderline(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey), // Add a border for styling
                    borderRadius:
                        BorderRadius.circular(8), // Add rounded corners
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Choose Order: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          hint: Text(orderType.text), // Add a hint
                          onChanged: (String? value) {
                            setState(() {
                              orderType.text = value ?? "";
                            });
                          },
                          items: [
                            "Sell Order",
                            "Purchase Order",
                            "Return Sell Order",
                            "Return Purchase Order"
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Choose User: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text(_userName ?? "Choose User"),
                            onChanged: (String? value) {
                              setState(() {
                                _userId = value ?? "";
                              });
                            },
                            items: (filteredUserData.value as List<User>)
                                .map((User user) {
                              return DropdownMenuItem<String>(
                                onTap: () {
                                  setState(() {
                                    _userName = user.userName.toString();
                                  });
                                },
                                value: user.userId.toString(),
                                child: Text(user.userName.toString()),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  _submitForm();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Create Order"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      db
          .updateOrder(
              widget.order.orderId,
              orderDate.text,
              orderAmount.text,
              equalOrderAmount.text,
              _currencyId,
              status.text,
              orderType.text,
              _userId)
          .whenComplete(() {
        Get.back();
      });
    }
  }
}
