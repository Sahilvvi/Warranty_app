import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class StockProvider with ChangeNotifier {
  List<ManufacturerStock> _manufacturerStocks = [];
  List<DistributorStock> _distributorStocks = [];
  List<DealerStock> _dealerStocks = [];
  bool _isLoading = false;
  String? _error;

  List<ManufacturerStock> get manufacturerStocks => _manufacturerStocks;
  List<DistributorStock> get distributorStocks => _distributorStocks;
  List<DealerStock> get dealerStocks => _dealerStocks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchManufacturerStocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.stockManufacturer);
      if (response['success'] == true) {
        _manufacturerStocks = (response['data'] as List)
            .map((e) => ManufacturerStock.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDistributorStocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.stockDistributor);
      if (response['success'] == true) {
        _distributorStocks = (response['data'] as List)
            .map((e) => DistributorStock.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDealerStocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.stockDealer);
      if (response['success'] == true) {
        _dealerStocks = (response['data'] as List)
            .map((e) => DealerStock.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createManufacturerStock({
    required int productId,
    required int quantity,
    String? batchNumber,
    required DateTime manufacturedDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(ApiConfig.stockManufacturer, {
        'productId': productId,
        'quantity': quantity,
        'batchNumber': batchNumber,
        'manufacturedDate': manufacturedDate.toIso8601String(),
      });

      _isLoading = false;
      if (response['success'] == true) {
        await fetchManufacturerStocks();
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

  Future<bool> createDistributorStock({
    required int manufacturerStockId,
    required int productId,
    required int quantity,
    required DateTime receivedDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(ApiConfig.stockDistributor, {
        'manufacturerStockId': manufacturerStockId,
        'productId': productId,
        'quantity': quantity,
        'receivedDate': receivedDate.toIso8601String(),
      });

      _isLoading = false;
      if (response['success'] == true) {
        await fetchDistributorStocks();
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

  Future<bool> createDealerStock({
    required int distributorStockId,
    required int productId,
    required DateTime date,
    required String model,
    required String invoiceNo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(ApiConfig.stockDealer, {
        'distributorStockId': distributorStockId,
        'productId': productId,
        'date': date.toIso8601String(),
        'model': model,
        'invoiceNo': invoiceNo,
      });

      _isLoading = false;
      if (response['success'] == true) {
        await fetchDealerStocks();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
