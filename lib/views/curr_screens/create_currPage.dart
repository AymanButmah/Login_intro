// ignore_for_file: file_names, valid_regexps

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intro_project/models/currency.dart';
import 'package:intro_project/sql/sqlite.dart';

class CreateCurrency extends StatefulWidget {
  const CreateCurrency({Key? key}) : super(key: key);

  @override
  State<CreateCurrency> createState() => _CreateCurrencyState();
}

class _CreateCurrencyState extends State<CreateCurrency> {
  final currencyName = TextEditingController();
  final currencySymbol = TextEditingController();
  final currencyRate = TextEditingController();
  final orderDate = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final db = Get.find<DatabaseHelper>();

  @override
  void dispose() {
    currencyName.dispose();
    currencySymbol.dispose();
    currencyRate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Currency ~ \$ ₪ €",
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
                controller: currencyName,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Currency Name is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Currency Name",
                ),
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
              ),
              TextFormField(
                autofocus: true,
                controller: currencySymbol,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Currency Symbol is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Currency Symbol",
                ),
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
              ),
              TextFormField(
                controller: currencyRate,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}$'),
                  ),
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Currency Rate is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Currency Rate",
                ),
                onEditingComplete: () {
                  _submitForm();
                },
              ),
              const SizedBox(height: 20),
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
                child: const Text("Create Currency"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      double rateValue = double.parse(currencyRate.text);

      db
          .createCurrency(Currency(
        currencyName: currencyName.text,
        currencySymbol: currencySymbol.text,
        currencyRate: rateValue,
      ))
          .whenComplete(() {
        Get.back();
      });
    }
  }
}
