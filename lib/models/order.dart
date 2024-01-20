class Order {
  int? orderId;
  String? orderDate;
  double? orderAmount;
  double? orderOrderAmount;
  int? currencyId;
  bool? status;
  int? userId;

  Order(
      {this.orderId,
      this.orderDate,
      this.orderAmount,
      this.orderOrderAmount,
      this.currencyId,
      this.status,
      this.userId});

  Order.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    orderDate = json['orderDate'];
    orderAmount = json['orderAmount'];
    orderOrderAmount = json['orderOrderAmount'];
    currencyId = json['currencyId'];
    status = json['status'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['orderDate'] = orderDate;
    data['orderAmount'] = orderAmount;
    data['orderOrderAmount'] = orderOrderAmount;
    data['currencyId'] = currencyId;
    data['status'] = status;
    data['userId'] = userId;
    return data;
  }
}
