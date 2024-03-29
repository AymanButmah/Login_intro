import 'package:flutter/material.dart';

class Order {
  int? orderId;
  String? orderDate;
  double? orderAmount;
  double? equalOrderAmount;
  int? currencyId;
  bool? status;
  String? orderType;
  int? userId;

  Order(
      {this.orderId,
      this.orderDate,
      this.orderAmount,
      this.equalOrderAmount,
      this.currencyId,
      this.status,
      this.orderType,
      this.userId});

  Order.fromJson(Map<String, dynamic> json) {
    debugPrint("object ${json['status']}");
    orderId = json['orderId'];
    orderDate = json['orderDate'];
    orderAmount = json['orderAmount'];
    equalOrderAmount = json['equalOrderAmount'];
    currencyId = json['currencyId'];
    status = json['status'] == 1 ? true : false;
    orderType = json['orderType'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['orderDate'] = orderDate;
    data['orderAmount'] = orderAmount;
    data['equalOrderAmount'] = equalOrderAmount;
    data['currencyId'] = currencyId;
    data['status'] = status;
    data['orderType'] = orderType;
    data['userId'] = userId;
    return data;
  }
}
