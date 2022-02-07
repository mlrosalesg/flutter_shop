import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/widgets/user_product_item.dart';

import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    var products = productsData.items;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Products'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemBuilder: (_, i) {
            return UserProductItem(
                title: products[i].title, imageUrl: products[i].imageUrl);
          },
          itemCount: products.length,
        ),
      ),
    );
  }
}
