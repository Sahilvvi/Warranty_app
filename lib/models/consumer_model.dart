class ConsumerModel  {
  final int id;
  final String name;
  final String? address;
  final String mobileNumber;
  final int warrantyCount;
  final DateTime createdAt;

  ConsumerModel ({
    required this.id,
    required this.name,
    this.address,
    required this.mobileNumber,
    required this.warrantyCount,
    required this.createdAt,
  });

  factory ConsumerModel .fromJson(Map<String, dynamic> json) {
    return ConsumerModel (
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'],
      mobileNumber: json['mobileNumber'] ?? '',
      warrantyCount: json['warrantyCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
