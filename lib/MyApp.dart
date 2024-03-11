import 'package:flutter/material.dart';

class AddCart extends StatelessWidget {
  const AddCart({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart Overlay',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Show the shopping cart overlay
            showShoppingCartOverlay(context);
          },
          child: Text('Open Shopping Cart'),
        ),
      ),
    );
  }

  void showShoppingCartOverlay(BuildContext context) {
    // Create a transparent overlay to cover the whole screen
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.black.withOpacity(0.5), // Semi-transparent black background
          child: ShoppingCartOverlay(
            onClose: () {
              // Remove the overlay when the user closes the shopping cart
              overlayEntry!.remove();
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}

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
