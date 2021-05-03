import 'package:flutter/material.dart';
import 'package:shop/model/httpexception.dart';

import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  final String token;
  final String userId;
  Products(this.token, this._items, this.userId);
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchandSetproduct([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shop21-7ceff-default-rtdb.firebaseio.com/products.json?auth=$token&$filterString');

    try {
      final respons = await http.get(url);

      final extrctionData = json.decode(respons.body) as Map<String, dynamic>;
      final List<Product> loadedproduct = [];

      url = Uri.parse(
          'https://shop21-7ceff-default-rtdb.firebaseio.com/userFavorite/$userId.json?auth=$token');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      extrctionData.forEach((prodid, data) {
        loadedproduct.add(Product(
            id: prodid,
            title: data['title'],
            price: data['price'],
            description: data['description'],
            imageUrl: data['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodid] ?? false));
      });
      _items = loadedproduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.parse(
        'https://shop21-7ceff-default-rtdb.firebaseio.com/products.json?auth=$token');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'creatorId': userId
        }),
      );

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);

    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://shop21-7ceff-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
      await http.patch(url,
          body: json.encode({
            "title": newProduct.title,
            "imageUrl": newProduct.imageUrl,
            "description": newProduct.description,
            "price": newProduct.price
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> removeProduct(String id) async {
    final url = Uri.parse(
        'https://shop21-7ceff-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    final existingproductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingproduct = _items[existingproductIndex];

    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingproductIndex, existingproduct);
      notifyListeners();
      throw HttpException('Could not be delete');
    }
    existingproduct = null;
  }
}
