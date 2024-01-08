import 'dart:convert';

class CartItem {
  List<String> includes;
  String name;
  String price;
  String quantity;

  CartItem({
    required this.includes,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    List<String> includes = List<String>.from(json['includes'] ?? []);
    return CartItem(
      includes: includes,
      name: json['item'] ?? '',
      price: json['price'] ?? '',
      quantity: json['quantity'] ?? '',
    );
  }
}

class Cart {
  List<CartItem> items;

  Cart({required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    List<CartItem> items = [];
    json.forEach((key, value) {
      items.add(CartItem.fromJson(value));
    });

    return Cart(items: items);
  }
}
