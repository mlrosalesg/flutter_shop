import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  final mainUrl = 'flutter-shop-2502a-default-rtdb.firebaseio.com';
  final productsUrl = 'products.json';
  String getProductUrl(String id) {
    return 'products/$id.json';
  }

  Future<void> toggleFavoriteStatus() async {
    final newStatus = !isFavorite;
    try {
      final url = Uri.https(mainUrl, getProductUrl(id));
      //final url = Uri.https(mainUrl, 'products/$id');
      final response = await http.patch(url,
          body: json.encode({
            'isFavorite': newStatus,
          }));
      if (response.statusCode >= 400) {
        throw Exception('Failed to update product');
      }
      isFavorite = newStatus;
      notifyListeners();
      print('toggled favorite');
    } catch (error) {
      print('Error in updateProduct($id)');
      print(error.toString());
      throw error;
    }
  }
}
