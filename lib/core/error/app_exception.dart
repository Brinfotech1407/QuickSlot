class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final dynamic details;

  @override
  String toString() =>
      'AppException(message: $message, statusCode: $statusCode)';
}
