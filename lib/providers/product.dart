import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final double price;
  bool isFavorite;

  Product({
    this.id,
    this.description,
    this.imageUrl,
    this.isFavorite = false,
    this.price,
    this.title,
  });

  Future<void> toggleFavorite(String token, String userId) async {
    var oldstate = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    var url = Uri.parse(
        'https://shop21-7ceff-default-rtdb.firebaseio.com/userFavorite/$userId/$id.json?auth=$token');
    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        isFavorite = oldstate;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = oldstate;
      notifyListeners();
    }
  }
}
