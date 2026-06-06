import 'api_client.dart';

class LibrarianService {
  final ApiClient _client;

  const LibrarianService({ApiClient client = const ApiClient()})
      : _client = client;

  Future<Map<String, dynamic>> dashboard() async {
    final data = await _client.get('/librarian/dashboard');
    return ApiClient.asMap(data);
  }

  Future<List<Map<String, dynamic>>> books() async {
    final data = await _client.get('/librarian/books');
    return ApiClient.asMapList(data);
  }

  Future<Map<String, dynamic>> createBook(Map<String, dynamic> body) async {
    final data = await _client.post('/librarian/books', body: body);
    return ApiClient.asMap(data);
  }

  Future<Map<String, dynamic>> updateBook(
    Object bookId,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.put('/librarian/books/$bookId', body: body);
    return ApiClient.asMap(data);
  }

  Future<void> deleteBook(Object bookId) async {
    await _client.delete('/librarian/books/$bookId');
  }

  Future<List<Map<String, dynamic>>> reservations() async {
    final data = await _client.get('/librarian/reservations');
    return ApiClient.asMapList(data);
  }

  Future<Map<String, dynamic>> updateReservation(
    Object reservationId,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.put(
      '/librarian/reservations/$reservationId',
      body: body,
    );
    return ApiClient.asMap(data);
  }

  Future<List<Map<String, dynamic>>> borrowings() async {
    final data = await _client.get('/librarian/borrowings');
    return ApiClient.asMapList(data);
  }

  Future<Map<String, dynamic>> returnBorrowing(Object borrowingId) async {
    final data = await _client.put(
      '/librarian/borrowings/$borrowingId/return',
    );
    return ApiClient.asMap(data);
  }
}
