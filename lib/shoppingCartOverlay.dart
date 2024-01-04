import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:gka/cart_item.dart';

class ShoppingCartOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final Cart cart;

  ShoppingCartOverlay({required this.cart, required this.onClose});

  @override
  Widget build(BuildContext context) {

    double totalAmount = 0.0;

    for (CartItem item in cart.items) {

      totalAmount += double.parse(item.price);
      print("fjkdjhkghfdkghkf ${totalAmount}");
    }

    return Material(
      color: Colors.redAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shopping_cart, color: Colors.white,),
                Text(
                  'Your Cart',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ],
            ),
          ),

          Container(
            child: ListView.builder(
              shrinkWrap: true,
              controller: ScrollController(),
              itemBuilder: (context, index) {
                if (index < cart.items.length) {
                  String includedItems = "";
                  for (String item in cart.items[index].includes) {
                    includedItems += "$item, ";
                  }

                  return ListTile(
                    /// To remove extra padding
                    visualDensity: const VisualDensity(
                        horizontal: 0, vertical: -2),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                    leading: Icon(Icons.emoji_food_beverage_outlined),
                    title: Text(
                      cart.items[index].name,
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                    subtitle: Text(
                      includedItems,
                      style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.white
                      ),
                    ),
                    trailing: SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            '${cart.items[index].quantity}',
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.white
                            ),
                          ),
                          Text(
                            '\$${cart.items[index].price}',
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return null;
              },
              itemCount: cart.items.length,
            ),
          ),

          ListTile(
            /// To remove extra padding
            visualDensity: const VisualDensity(
                horizontal: 0, vertical: -2),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white, width: 1),
              borderRadius: BorderRadius.zero,
            ),
            title: Text(
              "Total to Pay (Including All Taxes)",
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 28.0),
              child: Text(
                "\$${totalAmount.toString()}",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onClose,
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}