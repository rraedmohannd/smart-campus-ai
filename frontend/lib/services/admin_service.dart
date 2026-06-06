import 'api_client.dart';

class AdminService {
  final ApiClient _client;

  const AdminService({ApiClient client = const ApiClient()}) : _client = client;

  Future<Map<String, dynamic>> dashboard() async {
    final data = await _client.get('/admin/dashboard');
    return ApiClient.asMap(data);
  }

  Future<List<Map<String, dynamic>>> users() async {
    final data = await _client.get('/admin/users');
    return ApiClient.asMapList(data);
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> body) async {
    final data = await _client.post('/admin/users', body: body);
    return ApiClient.asMap(data);
  }

  Future<Map<String, dynamic>> updateUser(
    Object userId,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.put('/admin/users/$userId', body: body);
    return ApiClient.asMap(data);
  }

  Future<void> deleteUser(Object userId) async {
    await _client.delete('/admin/users/$userId');
  }

  Future<List<Map<String, dynamic>>> students() async {
    final data = await _client.get('/admin/students');
    return ApiClient.asMapList(data);
  }

  Future<Map<String, dynamic>> createNotification(
    Map<String, dynamic> body,
  ) async {
    final data = await _client.post('/admin/notifications', body: body);
    return ApiClient.asMap(data);
  }
}
