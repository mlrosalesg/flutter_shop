import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartListItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartListItem(this.id, this.productId, this.price, this.quantity, this.title);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to remove this item from the cart?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                    child: Text('No')),
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                    child: Text('Yes')),
              ],
            );
          },
        );
      },
      background: Container(
        color: Theme.of(context).errorColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete item',
              style: Theme.of(context).primaryTextTheme.headline6,
            ),
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.delete,
              color: Colors.white,
              size: 40,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(child: Text('$quantity')),
              ),
            ),
            title: Text(title),
            subtitle: Text('Unit price: \$${(price).toStringAsFixed(2)}'),
            trailing: Text('\$${(price * quantity).toStringAsFixed(2)}'),
          ),
        ),
      ),
    );
  }
}
