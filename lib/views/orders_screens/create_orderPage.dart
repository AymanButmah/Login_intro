// ignore_for_file: file_names, valid_regexps, unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intro_project/models/currency.dart';
import 'package:intro_project/models/user.dart';
import 'package:intro_project/sql/sqlite.dart';

class CreateOrder extends StatefulWidget {
  const CreateOrder({Key? key}) : super(key: key);

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  final orderDate = TextEditingController();
  final orderAmount = TextEditingController();
  final equalOrderAmount = TextEditingController();
  final status = TextEditingController();
  User? _userId;
  Currency? _currencyId;
  final formKey = GlobalKey<FormState>();
  final db = Get.find<DatabaseHelper>();

  @override
  void dispose() {
    orderDate.dispose();
    orderAmount.dispose();
    equalOrderAmount.dispose();
    status.dispose();
    super.dispose();
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
                decoration: const InputDecoration(
                  labelText: "Order Date",
                ),
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
              ),
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

              // TextFormField(
              //   autofocus: true,
              //   controller: currencyId,
              //   validator: (value) {
              //     if (value!.isEmpty) {
              //       return "Currency Id is required";
              //     }
              //     return null;
              //   },
              //   decoration: const InputDecoration(
              //     labelText: "Currency Id",
              //   ),
              //   onEditingComplete: () {
              //     FocusScope.of(context).nextFocus();
              //   },
              // ),
              TextFormField(
                autofocus: true,
                controller: status,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Status is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Status",
                ),
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
              ),
              TextFormField(
                // controller: userId,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "User is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "User Who's holding Order",
                ),
                onEditingComplete: () {
                  // _submitForm();
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // _submitForm();
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

//   void _submitForm() {
//     if (formKey.currentState!.validate()) {
//       double orderAmountValue = double.parse(orderAmount.text);
//       double equalorderAmountValue = double.parse(equalOrderAmount.text);
//       db.createOrder(Order(

//         orderDate: ,
//         orderAmount:orderAmountValue ,
//         equalOrderAmount:equalorderAmountValue ,

//         currencyId:currencyId.text ,
// status: status,
// userId: ,

//       )).whenComplete(() {
//         Get.back();
//       });
//     }
//   }
}
