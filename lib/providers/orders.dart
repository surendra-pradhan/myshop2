import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import './cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({this.id, this.amount, this.dateTime, this.products});
}

class Orders with ChangeNotifier {
  final String token;
  final String userId;
  Orders(this.token, this.userId, this._orders);
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> setAndFetchOrders() async {
    final url = Uri.parse(
        'https://shop21-7ceff-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final response = await http.get(url);
    // print(json.decode(response.body));
    final List<OrderItem> loadedOrders = [];
    var extractedOrders = json.decode(response.body) as Map<String, dynamic>;
    print(extractedOrders);
    if (extractedOrders == null) {
      return;
    }
    extractedOrders.forEach((orderId, orderdata) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderdata['amount'],
          dateTime: DateTime.parse(orderdata['dateTime']),
          products: (orderdata['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ))
              .toList()));
    });
    _orders = loadedOrders.reversed.toList();

    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shop21-7ceff-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          "amount": total,
          "dateTime": timeStamp.toIso8601String(),
          "products": cartProducts
              .map((prod) => {
                    "id": prod.id,
                    "title": prod.title,
                    "quantity": prod.quantity,
                    "price": prod.price
                  })
              .toList()
        }));
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            dateTime: timeStamp,
            products: cartProducts));
    notifyListeners();
  }
}
