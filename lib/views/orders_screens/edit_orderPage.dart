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
  bool? status;
  String? orderType;
  String? _userId;
  int? _currencyId;
  String? currencyNameMenu;
  final formKey = GlobalKey<FormState>();
  final db = Get.find<DatabaseHelper>();

  RxList get filteredUserData => Get.find<DatabaseHelper>().filteredUserData;
  RxList<Currency> get filteredCurrencyData =>
      Get.find<DatabaseHelper>().filteredCurrencyData;
  List<User> get userData => Get.find<DatabaseHelper>().userData;
  List<Currency> get currencyData => Get.find<DatabaseHelper>().currencyData;

  RxList get filteredOrderData => Get.find<DatabaseHelper>().filteredOrderData;
  List get orderData => Get.find<DatabaseHelper>().orderData;

  double _currencyRate = Currency().currencyRate ?? 0.0;

  void calculateEqualOrderAmount() {
    if (currencyNameMenu?.toLowerCase() != null) {
      _currencyRate = _currencyRate;
    }

    if (currencyNameMenu == null) {
      // Default currency rate when currency is not selected

      _currencyRate = 1.0;
    }
    //equalOrderAmount Calculation

    double orderAmountValue = double.tryParse(orderAmount.text) ?? 0.0;
    double calculatedEqualOrderAmount = orderAmountValue / _currencyRate;
    equalOrderAmount.text = calculatedEqualOrderAmount.toStringAsFixed(2);
  }

  @override
  void initState() {
    chadMethod();
    //setting the values got from database .. no place for nulls
    orderDate.text =
        widget.order.orderDate == "null" ? "" : widget.order.orderDate ?? "";
    orderAmount.text = widget.order.orderAmount == null
        ? "0.0"
        : widget.order.orderAmount.toString();
    equalOrderAmount.text = widget.order.equalOrderAmount == null
        ? "0.0"
        : widget.order.equalOrderAmount.toString();
    status = widget.order.status;
    orderType = widget.order.orderType;
    _userId =
        widget.order.userId == null ? "0" : widget.order.userId.toString();
    _currencyId = widget.order.currencyId;

    orderAmount.addListener(() {
      //listener to listen to valeus inserted to orderamount and selected currency

      calculateEqualOrderAmount();
    });

    super.initState();
  }

  chadMethod() async {
    //getting data from database

    await Get.find<DatabaseHelper>().init();
    await Get.find<DatabaseHelper>().getCurrencies();
    filteredCurrencyData.value = currencyData;
  }

  @override
  void dispose() {
    orderDate.dispose();
    orderAmount.dispose();
    equalOrderAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Order", style: TextStyle(color: Colors.blue)),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Choosed Curr: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _currencyId,
                            onChanged: (int? value) {
                              setState(() {
                                _currencyId = value;
                              });
                            },
                            items: (filteredCurrencyData.value)
                                .map((Currency curr) {
                              return DropdownMenuItem<int>(
                                onTap: () {
                                  setState(() {
                                    currencyNameMenu =
                                        curr.currencyName.toString();
                                    _currencyRate = curr.currencyRate ?? 0.0;
                                  });
                                },
                                value: curr.currencyId,
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      autofocus: true,
                      controller: orderAmount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$')),
                      ],
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      enabled: false,
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
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              DropdownButtonHideUnderline(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
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
                        child: DropdownButton<bool>(
                          value: status,
                          onChanged: (bool? value) {
                            setState(() {
                              status = value;
                            });
                          },
                          items: const [
                            DropdownMenuItem<bool>(
                              value: true,
                              child: Text("Active"),
                            ),
                            DropdownMenuItem<bool>(
                              value: false,
                              child: Text("Inactive"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              DropdownButtonHideUnderline(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Choosed Order: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          value: orderType,
                          onChanged: (String? value) {
                            setState(() {
                              orderType = value ?? "";
                            });
                          },
                          items: [
                            "Sell Order",
                            "Purchase Order",
                            "Return Sell Order",
                            "Return Purchase Order",
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Choosed User: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _userId,
                            onChanged: (String? value) {
                              setState(() {
                                _userId = value ?? "";
                              });
                            },
                            items: (filteredUserData.value as List<User>)
                                .map((User user) {
                              return DropdownMenuItem<String>(
                                onTap: () {
                                  setState(() {});
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                child: const Text("Update Order"),
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
          .updateOrder(widget.order.orderId, orderDate.text, orderAmount.text,
              equalOrderAmount.text, _currencyId, status, orderType, _userId)
          .whenComplete(() {
        Get.back();
      });
    }
  }
}
