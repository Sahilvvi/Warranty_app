import 'dart:io';
import 'package:flutter/material.dart';
import '../models/warranty_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class WarrantyProvider with ChangeNotifier {
  List<WarrantyRegistration> _warranties = [];
  List<WarrantyRule> _rules = [];
  bool _isLoading = false;
  String? _error;

  List<WarrantyRegistration> get warranties => _warranties;
  List<WarrantyRule> get rules => _rules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWarranties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.warranties);
      if (response['success'] == true) {
        _warranties = (response['data'] as List)
            .map((e) => WarrantyRegistration.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyWarranties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.warrantyMy);
      if (response['success'] == true) {
        _warranties = (response['data'] as List)
            .map((e) => WarrantyRegistration.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWarrantyRules() async {
    try {
      final response = await ApiService.get(ApiConfig.warrantyRules);
      if (response['success'] == true) {
        _rules = (response['data'] as List)
            .map((e) => WarrantyRule.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> searchBySerial(String serial) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.warrantySearch(serial));
      if (response['success'] == true) {
        _warranties = (response['data'] as List)
            .map((e) => WarrantyRegistration.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> filterByStatus(String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.warrantyByStatus(status));
      if (response['success'] == true) {
        _warranties = (response['data'] as List)
            .map((e) => WarrantyRegistration.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> registerWarranty({
    required int productId,
    required String model,
    required DateTime manufacturedDate,
    required String billNumber,
    required int quantity,
    String? vendor,
    required String warrantyPeriod,
    String warrantyType = 'Standard',
    int? consumerId,
    File? photo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fields = {
        'ProductId': productId.toString(),
        'Model': model,
        'ManufacturedDate': manufacturedDate.toIso8601String(),
        'BillNumber': billNumber,
        'Quantity': quantity.toString(),
        'WarrantyPeriod': warrantyPeriod,
        'WarrantyType': warrantyType,
      };

      if (vendor != null && vendor.isNotEmpty) {
        fields['Vendor'] = vendor;
      }
      if (consumerId != null) {
        fields['ConsumerId'] = consumerId.toString();
      }

      final response = await ApiService.postMultipart(
        ApiConfig.warrantyRegister,
        fields: fields,
        file: photo,
      );

      _isLoading = false;
      if (response['success'] == true) {
        notifyListeners();
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
