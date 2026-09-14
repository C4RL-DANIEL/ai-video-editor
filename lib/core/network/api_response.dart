/// Generic wrapper for API responses.
class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    required this.data,
    this.message,
    this.isSuccess = true,
  });

  /// Creates a successful response.
  factory ApiResponse.success(T? data, {String? message, int statusCode = 200}) {
    return ApiResponse(
      statusCode: statusCode,
      data: data,
      message: message,
      isSuccess: true,
    );
  }

  /// Creates an error response.
  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse(
      statusCode: statusCode,
      data: null as T,
      message: message,
      isSuccess: false,
    );
  }

  /// Creates a response from a JSON map. You must supply [fromJson] to
  /// deserialise the payload.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson, {
    int defaultStatusCode = 200,
  }) {
    final statusCode = json['statusCode'] as int? ?? defaultStatusCode;
    final isSuccess = json['isSuccess'] as bool? ?? statusCode >= 200 && statusCode < 300;
    final message = json['message'] as String?;
    final data = json['data'];
    return ApiResponse(
      statusCode: statusCode,
      data: isSuccess ? fromJson(data) : null as T,
      message: message,
      isSuccess: isSuccess,
    );
  }

  final int statusCode;
  final T? data;
  final String? message;
  final bool isSuccess;

  @override
  String toString() =>
      'ApiResponse(statusCode: $statusCode, isSuccess: $isSuccess, message: $message)';
}
