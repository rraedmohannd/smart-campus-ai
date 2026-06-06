import 'api_client.dart';

class NotificationService {
  final ApiClient _client;

  const NotificationService({ApiClient client = const ApiClient()})
      : _client = client;

  Future<List<Map<String, dynamic>>> forUser(Object userId) async {
    final data = await _client.get('/notifications/user/$userId');
    return ApiClient.asMapList(data);
  }

  Future<void> markRead(Object notificationId) async {
    await _client.put('/notifications/$notificationId/read');
  }

  Future<void> delete(Object notificationId) async {
    await _client.delete('/notifications/$notificationId');
  }
}
