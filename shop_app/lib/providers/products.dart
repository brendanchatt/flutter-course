import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    //   Product(
    //     id: 'p1',
    //     title: 'Red Shirt',
    //     description: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl:
    //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   ),
    //   Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    //   ),
    //   Product(
    //     id: 'p3',
    //     title: 'Yellow Scarf',
    //     description: 'Warm and cozy - exactly what you need for the winter.',
    //     price: 19.99,
    //     imageUrl:
    //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    //   ),
    //   Product(
    //     id: 'p4',
    //     title: 'A Pan',
    //     description: 'Prepare any meal you want.',
    //     price: 49.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    //   ),
  ];

  final String _token;
  final String _userId;

  Products(this._token, this._items, this._userId);

  List<Product> get items => [..._items];

  List<Product> get favorites =>
      _items.where((prod) => prod.isFavorite).toList();

  Product findById(String id) => _items.firstWhere((prod) => prod.id == id);

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? '&orderBy="creatorId"&equalTo="$_userId"' : '';
    final url = 
        'https://flutter-update-194c5.firebaseio.com/products.json?auth=$_token$filterString';

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      final favoriteResponse = await http.get('https://flutter-update-194c5.firebaseio.com/userFavorites/$_userId.json?auth=$_token');
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodBod) {
        loadedProducts.add(Product(
            id: prodId,
            description: prodBod['description'],
            imageUrl: prodBod['imageUrl'],
            price: prodBod['price'],
            title: prodBod['title'],
            isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      throw (err);
    }
  }

  Future<void> addProduct(Product prod) async {
    final url =
        'https://flutter-update-194c5.firebaseio.com/products.json?auth=$_token';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': prod.title,
          'description': prod.description,
          'imageUrl': prod.imageUrl,
          'price': prod.price,
          'creatorId': _userId
        }),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        description: prod.description,
        imageUrl: prod.imageUrl,
        price: prod.price,
        title: prod.title,
      );
      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product prod) async {
    final prodIndex = _items.indexWhere((p) => p.id == id);

    //if(prodIndex >= 0) {
    final url =
        'https://flutter-update-194c5.firebaseio.com/products/$id.json?auth=$_token';
    await http.patch(url,
        body: json.encode({
          'title': prod.title,
          'imageUrl': prod.imageUrl,
          'price': prod.price,
          'description': prod.description
        }));
    _items[prodIndex] = prod;

    notifyListeners();
    //}
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-update-194c5.firebaseio.com/products/$id.json?auth=$_token';
    final existingProductIndex = _items.indexWhere((p) => p.id == id);
    var existingProduct = _items[existingProductIndex];
    final response = await http.delete(url);

    _items.removeAt(existingProductIndex);
    notifyListeners();

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Couldn\'t delete the product');
    }

    existingProduct = null;
  }

  Future<void> favoriteProduct(Product product) async {
    final url =
        'https://flutter-update-194c5.firebaseio.com/userFavorites/$_userId/${product.id}.json?auth=$_token';
    product.toggleFavorite();
    final response = await http.put(url, body: json.encode(product.isFavorite));

    if (response.statusCode >= 400) {
      product.toggleFavorite();
      throw HttpException('Favorite change failed');
    }
  }
}
