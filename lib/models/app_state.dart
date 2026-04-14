/// Enum for managing loading/error/success states
enum AppDataState { initial, loading, success, error }

/// Model for handling async data with loading and error states
class AppAsyncState<T> {
  final AppDataState state;
  final T? data;
  final String? error;
  final bool isLoading;
  final bool isError;
  final bool isSuccess;
  final bool isEmpty;

  const AppAsyncState({
    required this.state,
    this.data,
    this.error,
  })  : isLoading = state == AppDataState.loading,
        isError = state == AppDataState.error,
        isSuccess = state == AppDataState.success,
        isEmpty = data == null;

  // Factory constructors for convenience
  factory AppAsyncState.initial() =>
      const AppAsyncState(state: AppDataState.initial);

  factory AppAsyncState.loading() =>
      const AppAsyncState(state: AppDataState.loading);

  factory AppAsyncState.success(T data) =>
      AppAsyncState(state: AppDataState.success, data: data);

  factory AppAsyncState.error(String error) =>
      AppAsyncState(state: AppDataState.error, error: error);

  // Map function for pattern matching
  R map<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(T data) onSuccess,
    required R Function(String error) onError,
  }) {
    switch (state) {
      case AppDataState.initial:
        return onInitial();
      case AppDataState.loading:
        return onLoading();
      case AppDataState.success:
        return onSuccess(data as T);
      case AppDataState.error:
        return onError(error ?? 'Unknown error');
    }
  }
}
