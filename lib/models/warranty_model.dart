class WarrantyRegistration {
  final int id;
  final String dealerName;
  final String productName;
  final String model;
  final String serialNumber;
  final DateTime manufacturedDate;
  final String billNumber;
  final int quantity;
  final String? vendor;
  final String warrantyPeriod;
  final String warrantyType;
  final String? photoUrl;
  final DateTime warrantyStartDate;
  final DateTime warrantyEndDate;
  final String status;
  final ConsumerInfo? consumer;
  final DateTime createdAt;

  WarrantyRegistration({
    required this.id,
    required this.dealerName,
    required this.productName,
    required this.model,
    required this.serialNumber,
    required this.manufacturedDate,
    required this.billNumber,
    required this.quantity,
    this.vendor,
    required this.warrantyPeriod,
    required this.warrantyType,
    this.photoUrl,
    required this.warrantyStartDate,
    required this.warrantyEndDate,
    required this.status,
    this.consumer,
    required this.createdAt,
  });

  factory WarrantyRegistration.fromJson(Map<String, dynamic> json) {
    return WarrantyRegistration(
      id: json['id'],
      dealerName: json['dealerName'] ?? '',
      productName: json['productName'] ?? '',
      model: json['model'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      manufacturedDate: DateTime.parse(json['manufacturedDate']),
      billNumber: json['billNumber'] ?? '',
      quantity: json['quantity'] ?? 0,
      vendor: json['vendor'],
      warrantyPeriod: json['warrantyPeriod'] ?? '',
      warrantyType: json['warrantyType'] ?? '',
      photoUrl: json['photoUrl'],
      warrantyStartDate: DateTime.parse(json['warrantyStartDate']),
      warrantyEndDate: DateTime.parse(json['warrantyEndDate']),
      status: json['status'] ?? '',
      consumer: json['consumer'] != null ? ConsumerInfo.fromJson(json['consumer']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ConsumerInfo {
  final int id;
  final String name;
  final String mobileNumber;

  ConsumerInfo({required this.id, required this.name, required this.mobileNumber});

  factory ConsumerInfo.fromJson(Map<String, dynamic> json) {
    return ConsumerInfo(
      id: json['id'],
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
    );
  }
}

class WarrantyRule {
  final int id;
  final String name;
  final int durationMonths;
  final String? description;
  final String ruleType;

  WarrantyRule({
    required this.id,
    required this.name,
    required this.durationMonths,
    this.description,
    required this.ruleType,
  });

  factory WarrantyRule.fromJson(Map<String, dynamic> json) {
    return WarrantyRule(
      id: json['id'],
      name: json['name'] ?? '',
      durationMonths: json['durationMonths'] ?? 0,
      description: json['description'],
      ruleType: json['ruleType'] ?? '',
    );
  }
}
