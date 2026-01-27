/// Result type for functional error handling
/// Replaces Either pattern for cleaner error handling
sealed class Result<T> {
  const Result();

  /// Create a success result
  factory Result.success(T data) = Success<T>;

  /// Create a failure result
  factory Result.failure(String message, {Exception? exception}) = Failure<T>;

  /// Execute different callbacks based on result type
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Exception? exception) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Failure(message: final message, exception: final exception) => failure(
        message,
        exception,
      ),
    };
  }

  /// Map success value
  Result<R> map<R>(R Function(T data) transform) {
    return when(
      success: (data) => Result.success(transform(data)),
      failure: (message, exception) =>
          Result.failure(message, exception: exception),
    );
  }

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull =>
      when(success: (data) => data, failure: (message, exception) => null);
}

/// Success result
class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

/// Failure result
class Failure<T> extends Result<T> {
  const Failure(this.message, {this.exception});
  final String message;
  final Exception? exception;
}
