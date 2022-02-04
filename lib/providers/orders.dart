import 'package:flutter/material.dart';
import 'cart.dart';

class OrderItem {
  final String id;
  final double totalAmount;
  final List<CartItem> products;
  final DateTime date;

  OrderItem({
    required this.id,
    required this.totalAmount,
    required this.products,
    required this.date,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orderList = [];

  List<OrderItem> get orderList {
    return [..._orderList];
  }

  void addOrder(List<CartItem> items, double total) {
    _orderList.insert(
        0,
        OrderItem(
          id: DateTime.now().toString(),
          totalAmount: total,
          products: items,
          date: DateTime.now(),
        ));
    notifyListeners();
  }
}
