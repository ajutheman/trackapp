enum ResultStatus { idle, loading, success, failed }

class ValidationError {
  final String field;
  final String message;

  const ValidationError({required this.field, required this.message});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
    );
  }

  @override
  String toString() => "$field: $message";
}

class Result<T> {
  final ResultStatus status;
  final T? data;
  final String? message;
  final List<ValidationError>? errors;

  bool get isSuccess => status == ResultStatus.success;
  bool get hasFieldErrors => errors != null && errors!.isNotEmpty;

  const Result._({required this.status, this.data, this.message, this.errors});

  const Result.initial() : this._(status: ResultStatus.idle);

  const Result.loading() : this._(status: ResultStatus.loading);

  const Result.success(T data, {String? message}) : this._(status: ResultStatus.success, data: data, message: message);

  const Result.error(String message, {List<ValidationError>? errors}) : this._(status: ResultStatus.failed, message: message, errors: errors);

  /// Get error message for a specific field
  String? getFieldError(String fieldName) {
    if (errors == null || errors!.isEmpty) return null;
    try {
      return errors!.firstWhere((error) => error.field == fieldName).message;
    } catch (e) {
      return null;
    }
  }

  /// Get all error messages as a single formatted string
  String getFormattedErrors() {
    if (errors == null || errors!.isEmpty) {
      return message ?? 'An error occurred';
    }
    return errors!.map((e) => e.message).join('\n');
  }

  @override
  String toString() => "Status: $status, Message: $message, Data: $data, Errors: $errors";
}
