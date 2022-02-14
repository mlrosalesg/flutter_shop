import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/providers/product.dart';
import 'dart:convert';

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

final mainUrl = 'flutter-shop-2502a-default-rtdb.firebaseio.com';
final ordersUrl = 'orders.json';
String getOrderUrl(String id) {
  return 'orders/$id.json';
}

class Orders with ChangeNotifier {
  List<OrderItem> _orderList = [];

  List<OrderItem> get orderList {
    return [..._orderList];
  }

  Future<void> addOrder(List<CartItem> items, double total) async {
    final url = Uri.https(mainUrl, ordersUrl);
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'totalAmount': total,
            'date': timeStamp.toIso8601String(),
            'products': items
                .map((item) => {
                      'id': item.id,
                      'title': item.title,
                      'quantity': item.quantity,
                      'price': item.price,
                    })
                .toList(),
          }));
      final newOrderItem = OrderItem(
        id: json.decode(response.body)['name'],
        totalAmount: total,
        products: items,
        date: timeStamp,
      );
      _orderList.insert(0, newOrderItem);
      notifyListeners();
    } catch (error) {
      print('Error in addOrder()');
      print(error.toString());
      throw error;
    }
  }

  Future<void> fetchAndSetOrders() async {
    //final url = Uri.parse(productsUrl);
    final url = Uri.https(mainUrl, ordersUrl);
    print('fetch and set');
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data == null) return;

      final List<OrderItem> loadedOrders = [];

      data.forEach((id, map) {
        loadedOrders.add(OrderItem(
          id: id,
          totalAmount: map['totalAmount'],
          date: DateTime.parse(map['date']),
          products: (map['totalAmount'] as List<dynamic>)
              .map((p) => CartItem(
                  id: p['id'],
                  title: p['title'],
                  quantity: p['quantity'],
                  price: p['price']))
              .toList(),
        ));
      });
      _orderList = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print('Error in fetchAndSetOrders()');
      print(error.toString());
      throw error;
    }
  }
}
