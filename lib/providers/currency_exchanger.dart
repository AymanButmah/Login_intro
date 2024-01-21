import 'package:get/get.dart';

class CurrencyExchanger extends GetxController {
  RxDouble equalAmount = 0.0.obs;

  void exchangeCurrency(String currency, double rate, double amount) {
    if (currency.toLowerCase() == 'shekel' || currency == '₪') {
      equalAmount.value = amount;
    } else {
      equalAmount.value = amount / rate;
    }
  }
}
