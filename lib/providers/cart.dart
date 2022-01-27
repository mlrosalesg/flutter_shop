import 'package:flutter/material.dart';

class CartProductItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartProductItem(
      {required this.id,
      required this.title,
      required this.quantity,
      required this.price});
}

class Cart with ChangeNotifier {
  Map<String, CartProductItem> _items = {};

  Map<String, CartProductItem> get items {
    return {..._items};
  }

  List<CartProductItem> get itemsList {
    return {..._items}.values.toList();
  }

  List<String> get productIdList {
    return {..._items}.keys.toList();
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void removeProduct(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void addProduct(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingCartItem) => CartProductItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartProductItem(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }
}
