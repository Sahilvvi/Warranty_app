class DashboardData {
  final int totalProducts;
  final int totalWarranties;
  final int activeWarranties;
  final int expiringSoonWarranties;
  final int expiredWarranties;
  final int totalConsumers;
  final int totalDealers;
  final int totalDistributors;
  final int totalManufacturerStock;
  final int totalDistributorStock;
  final int totalDealerStock;
  final List<WarrantySummaryByProduct> warrantiesByProduct;
  final List<RecentWarranty> recentWarranties;

  DashboardData({
    required this.totalProducts,
    required this.totalWarranties,
    required this.activeWarranties,
    required this.expiringSoonWarranties,
    required this.expiredWarranties,
    required this.totalConsumers,
    required this.totalDealers,
    required this.totalDistributors,
    required this.totalManufacturerStock,
    required this.totalDistributorStock,
    required this.totalDealerStock,
    required this.warrantiesByProduct,
    required this.recentWarranties,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalProducts: json['totalProducts'] ?? 0,
      totalWarranties: json['totalWarranties'] ?? 0,
      activeWarranties: json['activeWarranties'] ?? 0,
      expiringSoonWarranties: json['expiringSoonWarranties'] ?? 0,
      expiredWarranties: json['expiredWarranties'] ?? 0,
      totalConsumers: json['totalConsumers'] ?? 0,
      totalDealers: json['totalDealers'] ?? 0,
      totalDistributors: json['totalDistributors'] ?? 0,
      totalManufacturerStock: json['totalManufacturerStock'] ?? 0,
      totalDistributorStock: json['totalDistributorStock'] ?? 0,
      totalDealerStock: json['totalDealerStock'] ?? 0,
      warrantiesByProduct: (json['warrantiesByProduct'] as List? ?? [])
          .map((e) => WarrantySummaryByProduct.fromJson(e))
          .toList(),
      recentWarranties: (json['recentWarranties'] as List? ?? [])
          .map((e) => RecentWarranty.fromJson(e))
          .toList(),
    );
  }
}

class WarrantySummaryByProduct {
  final String productName;
  final int active;
  final int expiringSoon;
  final int expired;

  WarrantySummaryByProduct({
    required this.productName,
    required this.active,
    required this.expiringSoon,
    required this.expired,
  });

  factory WarrantySummaryByProduct.fromJson(Map<String, dynamic> json) {
    return WarrantySummaryByProduct(
      productName: json['productName'] ?? '',
      active: json['active'] ?? 0,
      expiringSoon: json['expiringSoon'] ?? 0,
      expired: json['expired'] ?? 0,
    );
  }
}

class RecentWarranty {
  final int id;
  final String productName;
  final String serialNumber;
  final String dealerName;
  final String status;
  final DateTime warrantyEndDate;
  final DateTime createdAt;

  RecentWarranty({
    required this.id,
    required this.productName,
    required this.serialNumber,
    required this.dealerName,
    required this.status,
    required this.warrantyEndDate,
    required this.createdAt,
  });

  factory RecentWarranty.fromJson(Map<String, dynamic> json) {
    return RecentWarranty(
      id: json['id'],
      productName: json['productName'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      dealerName: json['dealerName'] ?? '',
      status: json['status'] ?? '',
      warrantyEndDate: DateTime.parse(json['warrantyEndDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
