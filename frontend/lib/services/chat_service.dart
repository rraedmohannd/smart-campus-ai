import 'api_client.dart';

class ChatService {
  final ApiClient _client;

  const ChatService({ApiClient client = const ApiClient()}) : _client = client;

  Future<List<Map<String, dynamic>>> history(String sessionId) async {
    final data = await _client.get('/chat/history/$sessionId');
    return ApiClient.asMapList(data);
  }

  Future<Map<String, dynamic>> send({
    required String sessionId,
    required String message,
    String? userId,
  }) async {
    final data = await _client.post(
      '/chat/',
      body: {
        'session_id': sessionId,
        'message': message,
        if (userId != null) 'student_id': userId,
        if (userId != null) 'user_id': userId,
      },
    );
    return ApiClient.asMap(data);
  }

  Future<void> clear(String sessionId) async {
    await _client.delete('/chat/history/$sessionId');
  }
}
