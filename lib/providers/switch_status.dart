// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwitchController extends GetxController {
  //Status Variable Switcher Order Page
  RxBool _status = false.obs;

  void changeStatus(bool newStatus) {
    _status.value = newStatus;
    update();
    debugPrint("Status changed to: $newStatus");
  }
}
