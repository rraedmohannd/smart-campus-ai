import 'api_client.dart';

class RulesService {
  final ApiClient _client;

  const RulesService({ApiClient client = const ApiClient()}) : _client = client;

  Future<List<Map<String, dynamic>>> all() async {
    final data = await _client.get('/rules/');
    return ApiClient.asMapList(data);
  }

  Future<List<dynamic>> categories() async {
    final data = await _client.get('/rules/categories');
    return ApiClient.asList(data);
  }

  Future<List<Map<String, dynamic>>> byCategory(String categoryName) async {
    final data = await _client.get('/rules/category/$categoryName');
    return ApiClient.asMapList(data);
  }
}
