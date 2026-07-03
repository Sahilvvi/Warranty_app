class ApiConfig {
  static const String baseUrl = 'https://maruthimotorpump.somee.com';
  static const String apiUrl = '$baseUrl/api';

  // Auth
  static const String login = '$apiUrl/Auth/login';
  static const String register = '$apiUrl/Auth/register';
  static const String users = '$apiUrl/Auth/users';

  // Warranty
  static const String warrantyRegister = '$apiUrl/Warranty/register';
  static const String warranties = '$apiUrl/Warranty';
  static const String warrantyRules = '$apiUrl/Warranty/rules';
  static const String warrantyMy = '$apiUrl/Warranty/my';
  static String warrantyById(int id) => '$apiUrl/Warranty/$id';
  static String warrantyByDealer(int dealerId) => '$apiUrl/Warranty/dealer/$dealerId';
  static String warrantyByStatus(String status) => '$apiUrl/Warranty/status/$status';
  static String warrantySearch(String serial) => '$apiUrl/Warranty/search?serialNumber=$serial';

  // Products
  static const String products = '$apiUrl/Products';
  static String productById(int id) => '$apiUrl/Products/$id';

  // Stock
  static const String stockManufacturer = '$apiUrl/Stock/manufacturer';
  static const String stockDistributor = '$apiUrl/Stock/distributor';
  static const String stockDealer = '$apiUrl/Stock/dealer';

  // Consumers
  static const String consumers = '$apiUrl/Consumers';
  static String consumerById(int id) => '$apiUrl/Consumers/$id';
  static String consumerSearch(String mobile) => '$apiUrl/Consumers/search?mobile=$mobile';

  // Dashboard
  static const String dashboard = '$apiUrl/Dashboard';

  // Reports
  static const String reportFull = '$apiUrl/Reports/full';
  static const String reportWarranty = '$apiUrl/Reports/warranty';
  static const String reportStock = '$apiUrl/Reports/stock';
  static const String reportProduct = '$apiUrl/Reports/product';
  static String reportWarrantyByStatus(String status) => '$apiUrl/Reports/warranty?status=$status';
}
