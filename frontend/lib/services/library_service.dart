import 'api_client.dart';

class LibraryService {
  final ApiClient _client;

  const LibraryService({ApiClient client = const ApiClient()}) : _client = client;

  Future<Map<String, dynamic>> info() async {
    final data = await _client.get('/library/');
    return ApiClient.asMap(data);
  }

  Future<List<Map<String, dynamic>>> books() async {
    final data = await _client.get('/library/books');
    return ApiClient.asMapList(data);
  }

  Future<List<Map<String, dynamic>>> featured() async {
    final data = await _client.get('/library/featured');
    return ApiClient.asMapList(data);
  }

  Future<List<dynamic>> categories() async {
    final data = await _client.get('/library/categories');
    return ApiClient.asList(data);
  }
}
