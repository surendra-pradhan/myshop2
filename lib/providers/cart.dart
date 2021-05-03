import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({this.id, this.title, this.price, this.quantity});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totaAmount {
    var total = 0.0;

    _items.forEach((key, cartItem) {
      total += cartItem.quantity * cartItem.price;
    });

    return total;
  }

  void addItems(
    String productid,
    String title,
    double price,
  ) {
    if (_items.containsKey(productid)) {
      _items.update(
          productid,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity + 1));
    } else {
      _items.putIfAbsent(
        productid,
        () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            price: price,
            quantity: 1),
      );
    }
    notifyListeners();
  }

  void removeItem(productid) {
    _items.remove(productid);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (existingcartItem) => CartItem(
              id: existingcartItem.id,
              price: existingcartItem.price,
              title: existingcartItem.title,
              quantity: existingcartItem.quantity - 1));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void cleracart() {
    _items = {};
    notifyListeners();
  }
}
