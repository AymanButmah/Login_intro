class Currency {
  int? currencyId;
  String? currencyName;
  String? currencySymbol;
  double? rate;

  Currency(
      {this.currencyId, this.currencyName, this.currencySymbol, this.rate});

  Currency.fromJson(Map<String, dynamic> json) {
    currencyId = json['currencyId'];
    currencyName = json['currencyName'];
    currencySymbol = json['currencySymbol'];
    rate = json['Rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currencyId'] = currencyId;
    data['currencyName'] = currencyName;
    data['currencySymbol'] = currencySymbol;
    data['Rate'] = rate;
    return data;
  }
}
