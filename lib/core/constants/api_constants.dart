class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'quickslot-backend-production.up.railway.app',
    defaultValue: 'http://10.0.2.2:3000',
  );
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);
}
