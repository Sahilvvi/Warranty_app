import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.products);
      if (response['success'] == true) {
        _products = (response['data'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createProduct({
    required String name,
    required String model,
    String? description,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'name': name,
        'model': model,
        'description': description,
        'category': category,
      };

      final response = await ApiService.post(ApiConfig.products, body);
      _isLoading = false;

      if (response['success'] == true) {
        await fetchProducts();
        return true;
      } else {
        _error = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct({
    required int id,
    required String name,
    required String model,
    String? description,
    String? category,
    bool isActive = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'name': name,
        'model': model,
        'description': description,
        'category': category,
        'isActive': isActive,
      };

      final response = await ApiService.put(ApiConfig.productById(id), body);
      _isLoading = false;

      if (response['success'] == true) {
        await fetchProducts();
        return true;
      } else {
        _error = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await ApiService.delete(ApiConfig.productById(id));
      if (response['success'] == true) {
        await fetchProducts();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
