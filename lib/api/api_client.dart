import 'dart:async';

/// Minimal API client abstraction.
///
/// Swap [FakeApiClient] with a real implementation (Dio/http) later without
/// changing UI/providers.
abstract class ApiClient {
  Future<T> get<T>(String path);
  Future<T> post<T>(String path, Map<String, Object?> body);
}

class FakeApiClient implements ApiClient {
  final Duration latency;
  final Map<String, Object?> _db = {};

  FakeApiClient({this.latency = const Duration(milliseconds: 450)});

  @override
  Future<T> get<T>(String path) async {
    await Future<void>.delayed(latency);
    final value = _db[path];
    if (value == null) {
      throw StateError('404 $path');
    }
    return value as T;
  }

  @override
  Future<T> post<T>(String path, Map<String, Object?> body) async {
    await Future<void>.delayed(latency);
    // For demo, we just store last payload per path.
    _db[path] = body;
    return body as T;
  }
}

