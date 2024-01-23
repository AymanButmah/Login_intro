// ignore_for_file: prefer_final_fields

import 'package:get/get.dart';

class SwitchController extends GetxController {
  RxBool _status = false.obs;

  void changeStatus(bool newStatus) {
    _status.value = newStatus;
    update();
    print("Status changed to: $newStatus");
  }
}
