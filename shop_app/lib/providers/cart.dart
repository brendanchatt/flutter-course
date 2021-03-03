import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  //getters//
  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;

    _items.forEach((key, cartItem) => 
      total += cartItem.price * cartItem.quantity
    );

    return total;
  }

  void addItem(String productId, double price, String title) {
    if(_items.containsKey(productId))
      _items.update(productId, (old) => CartItem(
        id: old.id,
        price: old.price,
        title: old.title,
        quantity: old.quantity + 1
      ));
    else
      _items.putIfAbsent(productId, () => CartItem(
        id: DateTime.now().toString(),
        title: title,
        price: price,
        quantity: 1
      ));

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if(!_items.containsKey(productId))
      return;
    
    if(_items[productId].quantity > 1) {
      _items.update(productId, (existingItem) => 
        CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          quantity: existingItem.quantity - 1
        )
      );
    } else {
      _items.remove(productId);
    }

    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}