// ignore_for_file: prefer_final_fields

import 'package:get/get.dart';

class SwitchController extends GetxController {
  RxBool _status = false.obs;
  RxBool get status => _status;

  void changeStatus(bool newStatus) {
    status.value = newStatus;
    print("Status changed to: $newStatus");
  }
}
