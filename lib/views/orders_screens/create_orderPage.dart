// ignore_for_file: file_names, valid_regexps, unused_field, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intro_project/models/currency.dart';
import 'package:intro_project/models/user.dart';
import 'package:intro_project/sql/sqlite.dart';

import '../../models/order.dart';

class CreateOrder extends StatefulWidget {
  CreateOrder({Key? key}) : super(key: key);

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  final orderDate = TextEditingController();
  final orderAmount = TextEditingController();
  final equalOrderAmount = TextEditingController();
  final status = TextEditingController();
  final orderType = TextEditingController();
  String? _userId;
  String? _userName;
  String? _currencyId;
  String? currencyNameMenu;
  final formKey = GlobalKey<FormState>();
  final db = Get.find<DatabaseHelper>();
  RxList get filteredCurrencyData =>
      Get.find<DatabaseHelper>().filteredCurrencyData;
  RxList get filteredUserData => Get.find<DatabaseHelper>().filteredUserData;
  List<User> get userData => Get.find<DatabaseHelper>().userData;
  List<Currency> get currencyData => Get.find<DatabaseHelper>().currencyData;

  double _currencyRate = Currency().currencyRate ?? 0.0;

  @override
  void initState() {
    super.initState();
    chadMethod();
    orderAmount.addListener(() {
      calculateEqualOrderAmount();
    });
  }

  void calculateEqualOrderAmount() {
    double orderAmountValue = double.tryParse(orderAmount.text) ?? 0.0;

    if (currencyNameMenu == null) {
      // Default currency rate when currency is not selected
      _currencyRate = 1.0;
    }

    double calculatedEqualOrderAmount = orderAmountValue / _currencyRate;
    equalOrderAmount.text = calculatedEqualOrderAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    orderDate.dispose();
    orderAmount.dispose();
    equalOrderAmount.dispose();
    status.dispose();
    super.dispose();
  }

  chadMethod() async {
    await Get.find<DatabaseHelper>().init();
    await Get.find<DatabaseHelper>().getCurrencies();
    filteredCurrencyData.value = currencyData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Order",
          style: TextStyle(color: Colors.blue),
        ),
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
                        'Choose Curr: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            onChanged: (String? value) {
                              setState(() {
                                _currencyId = value ?? "";
                                print(_currencyRate);
                              });
                            },
                            items: (filteredCurrencyData.value).isEmpty
                                ? [
                                    const DropdownMenuItem<String>(
                                      value: '',
                                      child: Text('No currencies available'),
                                    ),
                                  ]
                                : (filteredCurrencyData.value)
                                    .map((dynamic item) {
                                    if (item is Currency) {
                                      return DropdownMenuItem<String>(
                                        onTap: () {
                                          setState(() {
                                            currencyNameMenu =
                                                item.currencyId.toString();
                                            _currencyRate =
                                                item.currencyRate ?? 0.0;
                                          });
                                        },
                                        value: item.currencyId.toString(),
                                        child:
                                            Text(item.currencyName.toString()),
                                      );
                                    } else {
                                      return const DropdownMenuItem<String>(
                                        value: '',
                                        child: Text('Invalid currency type'),
                                      );
                                    }
                                  }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "CurrencyType Selection is required";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          autofocus: true,
                          controller: orderAmount,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Order Amount is required";
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*$')),
                          ],
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
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                                RegExp(r'[^0-9/]')),
                          ],
                        ),
                      ),
                    ],
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
                        child: DropdownButtonFormField<String>(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Status Selection is required";
                            }
                            return null;
                          },
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
                        'Choose Order: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: Text(orderType.text),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Order Type Selection is required";
                            }
                            return null;
                          },
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
                        'Choose User: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "User Selection is required";
                              }
                              return null;
                            },
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
      double orderAmountValue = double.parse(orderAmount.text);
      double equalorderAmountValue = double.parse(equalOrderAmount.text);
      db
          .createOrder(Order(
        orderDate: orderDate.text,
        orderAmount: orderAmountValue,
        equalOrderAmount: equalorderAmountValue,
        currencyId: int.parse(_currencyId ?? "0"),
        status: status.text == "Active" ? true : false,
        orderType: orderType.text,
        userId: int.parse(_userId ?? "0"),
      ))
          .whenComplete(() {
        Get.back();
      });
    }
  }
}
