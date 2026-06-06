import 'api_client.dart';

class TransporterService {
  final ApiClient _client;

  const TransporterService({ApiClient client = const ApiClient()})
      : _client = client;

  Future<Map<String, dynamic>> dashboard() async {
    final data = await _client.get('/transporter/dashboard');
    return ApiClient.asMap(data);
  }

  Future<List<Map<String, dynamic>>> buses() async {
    final data = await _client.get('/transporter/buses');
    return ApiClient.asMapList(data);
  }

  Future<Map<String, dynamic>> createBus(Map<String, dynamic> body) async {
    final data = await _client.post('/transporter/buses', body: body);
    return ApiClient.asMap(data);
  }

  Future<Map<String, dynamic>> updateBus(
    Object busId,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.put('/transporter/buses/$busId', body: body);
    return ApiClient.asMap(data);
  }

  Future<void> deleteBus(Object busId) async {
    await _client.delete('/transporter/buses/$busId');
  }

  Future<List<Map<String, dynamic>>> busLogs(Object busId) async {
    final data = await _client.get('/transporter/buses/$busId/logs');
    return ApiClient.asMapList(data);
  }
}
