import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.bay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // bool _isFavoritesOnly = false;
  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);
  List<Product> get items {
    // if (_isFavoritesOnly) {
    //   return _items.where((productItem) => productItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favorites {
    return _items.where((element) => element.isFavorite).toList();
  }
  // void showfavoritesOnly() {
  //   _isFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _isFavoritesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetPtoducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    try {
      var url = Uri.parse(
          'https://flutter-update-34138-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          "https://flutter-update-34138-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken");

      final favoriteResponse = await http.get(url);
      final favoritedata = json.decode(favoriteResponse.body);
      final List<Product> _loadedProducts = [];
      extractedData.forEach((produId, productData) {
        _loadedProducts.add(
          Product(
            id: produId,
            title: productData['title'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            price: productData['price'],
            isFavorite:
                favoritedata == null ? false : favoritedata[produId] ?? false,
          ),
        );
      });
      _items = _loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    // const url =
    //     "https://flutter-update-34138-default-rtdb.firebaseio.com/products.json";
    final url = Uri.parse(
        "https://flutter-update-34138-default-rtdb.firebaseio.com/products.json?auth=$authToken");
    try {
      final response = await http.post(url,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
            "creatorId": userId,
          }));
      _items.add(Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      ));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

// https://cdn.pixabay.com/photo/2014/08/16/18/17/book-419589_960_720.jpg
  Future<void> updateProduct(String id, Product updateProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url = Uri.parse(
          "https://flutter-update-34138-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken");
      await http.patch(url,
          body: json.encode({
            'title': updateProduct.title,
            'description': updateProduct.description,
            'imageUrl': updateProduct.imageUrl,
            'price': updateProduct.price,
          }));
      _items[productIndex] = updateProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        "https://flutter-update-34138-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken");
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not be delete product.");
    }
    existingProduct = null;
  }
}
