import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/user_products_screen.dart';
import 'screens/products_overview_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/edit_product_screen.dart';

import 'providers/products.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';
import 'providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          //I use create instead of value with all because I am creating a new
          //instance, not using an existing instance
          ChangeNotifierProvider(create: (ctx) => Products()),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          ChangeNotifierProvider(create: (ctx) => Orders()),
          ChangeNotifierProvider(create: (ctx) => Auth()),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) {
            return MaterialApp(
              title: 'MyShop',
              theme: ThemeData(
                primarySwatch: Colors.purple,
                colorScheme:
                    ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                        .copyWith(secondary: Colors.pink),
                fontFamily: 'Lato',
              ),
              //home: ProductsOverviewScreen(),
              home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
              routes: {
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrdersScreen.routeName: (ctx) => OrdersScreen(),
                ProductsOverviewScreen.routeName: (ctx) =>
                    ProductsOverviewScreen(),
                UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                EditProductScreen.routeName: (ctx) => EditProductScreen(),
              },
              debugShowCheckedModeBanner: false,
            );
          },
        ));
  }
}
