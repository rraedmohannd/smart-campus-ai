import 'api_client.dart';

class AuthService {
  final ApiClient _client;

  const AuthService({ApiClient client = const ApiClient()}) : _client = client;

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    required String role,
  }) async {
    final data = await _client.post(
      '/auth/login',
      body: {
        'identifier': identifier,
        'university_id': identifier,
        'email': identifier,
        'password': password,
        'role': role,
      },
    );
    return ApiClient.asMap(data);
  }
}
