class Currency {
  int? currencyId;
  String? currencyName;
  String? currencySymbol;
  double? currencyRate;

  Currency(
      {this.currencyId,
      this.currencyName,
      this.currencySymbol,
      this.currencyRate});

  Currency.fromJson(Map<String, dynamic> json) {
    currencyId = json['currencyId'];
    currencyName = json['currencyName'];
    currencySymbol = json['currencySymbol'];
    currencyRate = json['currencyRate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currencyId'] = currencyId;
    data['currencyName'] = currencyName;
    data['currencySymbol'] = currencySymbol;
    data['currencyRate'] = currencyRate;
    return data;
  }
}
