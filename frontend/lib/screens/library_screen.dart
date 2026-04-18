import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://localhost:8000';
const meuRed = Color(0xFF9E1B22);

class LibraryScreen extends StatefulWidget {
  final String studentId;

  const LibraryScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, dynamic>? _libraryInfo;
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _borrowed = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        http.get(Uri.parse('$_baseUrl/library/info')),
        http.get(Uri.parse('$_baseUrl/library/books')),
        http.get(Uri.parse('$_baseUrl/library/borrowed/${widget.studentId}')),
      ]);

      if (!mounted) return;

      setState(() {
        if (results[0].statusCode == 200) {
          _libraryInfo = jsonDecode(results[0].body) as Map<String, dynamic>;
        }

        if (results[1].statusCode == 200) {
          final decoded = jsonDecode(results[1].body) as List;
          _books = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        }

        if (results[2].statusCode == 200) {
          final decoded = jsonDecode(results[2].body) as List;
          _borrowed = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not connect to server.';
        _isLoading = false;
      });
    }
  }

  Future<void> _borrowBook(int bookId, String title) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/library/borrow'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': widget.studentId,
          'book_id': bookId,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? data['error'] ?? 'Done'),
          backgroundColor: data['error'] != null
              ? Colors.red
              : const Color(0xFF1B6E3C),
        ),
      );

      await _loadAll();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to borrow book'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: meuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.local_library_outlined, size: 22),
            SizedBox(width: 10),
            Text(
              'Library',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Books'),
            Tab(text: 'My Books'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: meuRed))
          : _error != null
              ? _buildError()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInfoTab(),
                    _buildBooksTab(),
                    _buildBorrowedTab(),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Unknown error',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: meuRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    if (_libraryInfo == null) {
      return const SizedBox();
    }

    final services =
        (_libraryInfo!['services'] as List?)?.map((e) => e.toString()).toList() ??
            [];

    final days = (_libraryInfo!['working_days'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final serviceIcons = [
      Icons.menu_book_outlined,
      Icons.chair_outlined,
      Icons.search_outlined,
      Icons.wifi_outlined,
      Icons.print_outlined,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: meuRed,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.local_library_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'University Library',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Working Hours',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _libraryInfo!['working_hours']?.toString() ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: days
                    .map(
                      (d) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          d,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Available Services',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          services.length,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  serviceIcons[i % serviceIcons.length],
                  color: meuRed,
                  size: 22,
                ),
              ),
              title: Text(
                services[i],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBooksTab() {
    if (_books.isEmpty) {
      return const Center(
        child: Text(
          'No books found.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _books.length,
      itemBuilder: (_, i) {
        final book = _books[i];
        final available = book['available'] as bool? ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: available
                    ? const Color(0xFFEAF7EE)
                    : const Color(0xFFFBEAEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.book_outlined,
                color: available ? const Color(0xFF1B6E3C) : meuRed,
              ),
            ),
            title: Text(
              book['title']?.toString() ?? 'Unknown Title',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Author: ${book['author'] ?? 'Unknown'}\n'
                'Category: ${book['category'] ?? 'General'}',
              ),
            ),
            isThreeLine: true,
            trailing: ElevatedButton(
              onPressed: available
                  ? () => _borrowBook(
                        book['id'] is int ? book['id'] as int : int.tryParse(book['id']?.toString() ?? '') ?? 0,
                        book['title']?.toString() ?? '',
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: available ? meuRed : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(available ? 'Borrow' : 'Taken'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBorrowedTab() {
    if (_borrowed.isEmpty) {
      return const Center(
        child: Text(
          'No borrowed books yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _borrowed.length,
      itemBuilder: (_, i) {
        final book = _borrowed[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.library_books_outlined,
                color: Colors.indigo,
              ),
            ),
            title: Text(
              book['title']?.toString() ?? 'Unknown Title',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Author: ${book['author'] ?? 'Unknown'}\n'
                'Borrowed: ${book['borrowed_at'] ?? '-'}',
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
