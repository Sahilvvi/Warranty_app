class ManufacturerStock {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final String? batchNumber;
  final DateTime manufacturedDate;
  final DateTime createdAt;

  ManufacturerStock({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    this.batchNumber,
    required this.manufacturedDate,
    required this.createdAt,
  });

  factory ManufacturerStock.fromJson(Map<String, dynamic> json) {
    return ManufacturerStock(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      batchNumber: json['batchNumber'],
      manufacturedDate: DateTime.parse(json['manufacturedDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class DistributorStock {
  final int id;
  final int manufacturerStockId;
  final int distributorId;
  final String distributorName;
  final int productId;
  final String productName;
  final int quantity;
  final DateTime receivedDate;
  final DateTime createdAt;

  DistributorStock({
    required this.id,
    required this.manufacturerStockId,
    required this.distributorId,
    required this.distributorName,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.receivedDate,
    required this.createdAt,
  });

  factory DistributorStock.fromJson(Map<String, dynamic> json) {
    return DistributorStock(
      id: json['id'],
      manufacturerStockId: json['manufacturerStockId'],
      distributorId: json['distributorId'],
      distributorName: json['distributorName'] ?? '',
      productId: json['productId'],
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      receivedDate: DateTime.parse(json['receivedDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class DealerStock {
  final int id;
  final int distributorStockId;
  final int dealerId;
  final String dealerName;
  final int productId;
  final String productName;
  final DateTime date;
  final String model;
  final String serialNumber;
  final String invoiceNo;
  final DateTime createdAt;

  DealerStock({
    required this.id,
    required this.distributorStockId,
    required this.dealerId,
    required this.dealerName,
    required this.productId,
    required this.productName,
    required this.date,
    required this.model,
    required this.serialNumber,
    required this.invoiceNo,
    required this.createdAt,
  });

  factory DealerStock.fromJson(Map<String, dynamic> json) {
    return DealerStock(
      id: json['id'],
      distributorStockId: json['distributorStockId'],
      dealerId: json['dealerId'],
      dealerName: json['dealerName'] ?? '',
      productId: json['productId'],
      productName: json['productName'] ?? '',
      date: DateTime.parse(json['date']),
      model: json['model'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
