import 'api_client.dart';

class BusService {
  final ApiClient _client;

  const BusService({ApiClient client = const ApiClient()}) : _client = client;

  Future<List<Map<String, dynamic>>> all() async {
    final data = await _client.get('/buses/');
    return ApiClient.asMapList(data);
  }

  Future<List<Map<String, dynamic>>> routes() async {
    final data = await _client.get('/buses/routes');
    return ApiClient.asMapList(data);
  }

  Future<List<Map<String, dynamic>>> live() async {
    final data = await _client.get('/buses/live');
    return ApiClient.asMapList(data);
  }

  Future<Map<String, dynamic>> byId(Object busId) async {
    final data = await _client.get('/buses/$busId');
    return ApiClient.asMap(data);
  }

  Future<List<Map<String, dynamic>>> logs(Object busId) async {
    final data = await _client.get('/buses/$busId/logs');
    return ApiClient.asMapList(data);
  }
}
