import 'package:flutter/material.dart';

class ShoppingCartOverlay extends StatelessWidget {
  final VoidCallback onClose;

  ShoppingCartOverlay({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Shopping Cart',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Add your shopping cart items here
        // Example item:
        ListTile(
          title: Text('Product 1'),
          subtitle: Text('Price: \$20.00'),
        ),
        ListTile(
          title: Text('Product 2'),
          subtitle: Text('Price: \$30.00'),
        ),
        // ... Add more items as needed
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: onClose,
          child: Text('Close'),
        ),
      ],
    );
  }
}