// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_project/models/currency.dart';
import 'package:intro_project/sql/sqlite.dart';

class EditCurrency extends StatefulWidget {
  Currency currency;
  EditCurrency({super.key, required this.currency});

  @override
  State<EditCurrency> createState() => _EditCurrencyState();
}

class _EditCurrencyState extends State<EditCurrency> {
  final currencyName = TextEditingController();
  final currencySymbol = TextEditingController();
  final currencyRate = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final db = Get.find<DatabaseHelper>();

  @override
  void initState() {
    // Preventing system from accepting null values
    currencyName.text = widget.currency.currencyName == "null"
        ? ""
        : widget.currency.currencyName ?? "";

    currencySymbol.text = widget.currency.currencySymbol == "null"
        ? ""
        : widget.currency.currencySymbol ?? "";

    currencyRate.text = widget.currency.currencyRate == null
        ? "0.0"
        : widget.currency.currencyRate.toString();
    super.initState();
  }

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
        title: const Text("Edit Currency ~ \$ ₪ €",
            style: TextStyle(color: Colors.blue)),
      ),
      body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
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
                    label: Text("Currency Name"),
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
                    label: Text("Currency Symbol"),
                  ),
                  onEditingComplete: () {
                    FocusScope.of(context).nextFocus();
                  },
                ),
                TextFormField(
                  controller: currencyRate,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Currency Rate is required";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    label: Text("Currency Rate"),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Update Currency"),
                ),
              ],
            ),
          )),
    );
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      db
          .updateCurrency(
        widget.currency.currencyId,
        currencyName.text,
        currencySymbol.text,
        currencyRate.text,
      )
          .whenComplete(() {
        Get.back();
      });
    }
  }
}
