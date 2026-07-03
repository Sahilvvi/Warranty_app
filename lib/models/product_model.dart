class Product {
  final int id;
  final String name;
  final String model;
  final String? description;
  final String? category;
  final bool isActive;
  final int activeWarranties;
  final int expiringSoonWarranties;
  final int expiredWarranties;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.model,
    this.description,
    this.category,
    required this.isActive,
    required this.activeWarranties,
    required this.expiringSoonWarranties,
    required this.expiredWarranties,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      description: json['description'],
      category: json['category'],
      isActive: json['isActive'] ?? true,
      activeWarranties: json['activeWarranties'] ?? 0,
      expiringSoonWarranties: json['expiringSoonWarranties'] ?? 0,
      expiredWarranties: json['expiredWarranties'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
