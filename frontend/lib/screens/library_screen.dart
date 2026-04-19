import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  final String _baseUrl = 'http://127.0.0.1:8000';

  late TabController _tabController;

  bool _loadingInfo = true;
  bool _loadingBooks = true;
  bool _loadingFeatured = true;
  bool _loadingCategories = true;

  String? _infoError;
  String? _booksError;
  String? _featuredError;
  String? _categoriesError;

  Map<String, dynamic>? _libraryInfo;
  List<dynamic> _books = [];
  List<dynamic> _featuredBooks = [];
  List<dynamic> _categories = [];
  final List<Map<String, dynamic>> _myBooks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllLibraryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllLibraryData() async {
    await Future.wait([
      _loadLibraryInfo(),
      _loadBooks(),
      _loadFeatured(),
      _loadCategories(),
    ]);
  }

  Future<void> _loadLibraryInfo() async {
    if (!mounted) return;

    setState(() {
      _loadingInfo = true;
      _infoError = null;
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/library/'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        setState(() {
          _libraryInfo = data;
          _loadingInfo = false;
          _infoError = null;
        });
      } else {
        setState(() {
          _infoError = 'Server error: ${response.statusCode}';
          _loadingInfo = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _infoError = 'Connection error';
        _loadingInfo = false;
      });
    }
  }

  Future<void> _loadBooks() async {
    if (!mounted) return;

    setState(() {
      _loadingBooks = true;
      _booksError = null;
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/library/books'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

        setState(() {
          _books = data;
          _loadingBooks = false;
          _booksError = null;

          if (_featuredBooks.isEmpty) {
            _featuredBooks =
                _books.where((b) => b is Map && b['featured'] == true).toList();
          }

          if (_categories.isEmpty) {
            _categories = _books
                .map((b) => b is Map ? b['category'] : null)
                .where((c) => c != null)
                .toSet()
                .toList();
          }
        });
      } else {
        setState(() {
          _booksError = 'Server error: ${response.statusCode}';
          _loadingBooks = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _booksError = 'Connection error';
        _loadingBooks = false;
      });
    }
  }

  Future<void> _loadFeatured() async {
    if (!mounted) return;

    setState(() {
      _loadingFeatured = true;
      _featuredError = null;
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/library/featured'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

        setState(() {
          _featuredBooks = data;
          _loadingFeatured = false;
          _featuredError = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _featuredBooks =
              _books.where((b) => b is Map && b['featured'] == true).toList();
          _loadingFeatured = false;
          _featuredError = null;
        });
      } else {
        setState(() {
          _featuredError = 'Server error: ${response.statusCode}';
          _loadingFeatured = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _featuredBooks =
            _books.where((b) => b is Map && b['featured'] == true).toList();
        _featuredError = null;
        _loadingFeatured = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;

    setState(() {
      _loadingCategories = true;
      _categoriesError = null;
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/library/categories'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> categories = [];
        if (decoded is Map<String, dynamic> && decoded['categories'] is List) {
          categories = decoded['categories'] as List<dynamic>;
        } else if (decoded is List) {
          categories = decoded;
        }

        setState(() {
          _categories = categories;
          _loadingCategories = false;
          _categoriesError = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _categories = _books
              .map((b) => b is Map ? b['category'] : null)
              .where((c) => c != null)
              .toSet()
              .toList();
          _loadingCategories = false;
          _categoriesError = null;
        });
      } else {
        setState(() {
          _categoriesError = 'Server error: ${response.statusCode}';
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _categories = _books
            .map((b) => b is Map ? b['category'] : null)
            .where((c) => c != null)
            .toSet()
            .toList();
        _loadingCategories = false;
        _categoriesError = null;
      });
    }
  }

  void _borrowBook(Map<String, dynamic> book) {
    final exists = _myBooks.any((b) => b['id'] == book['id']);

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This book is already in My Books')),
      );
      return;
    }

    setState(() {
      _myBooks.add(Map<String, dynamic>.from(book));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book['title']} added to My Books')),
    );
  }

  void _returnBook(Map<String, dynamic> book) {
    setState(() {
      _myBooks.removeWhere((b) => b['id'] == book['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book['title']} returned successfully')),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB0121B)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    if (_loadingInfo) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_infoError != null) {
      return Center(
        child: Text(
          _infoError!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final info = _libraryInfo ?? {};
    final services = (info['services'] as List?) ?? [];
    final categories = _categories;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFB0121B),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_library_outlined, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'University Library',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  Icons.access_time,
                  'Working Hours',
                  info['working_hours']?.toString() ?? '-',
                ),
                _buildInfoCard(
                  Icons.menu_book_outlined,
                  'Total Books',
                  (info['total_books'] ?? _books.length).toString(),
                ),
                _buildInfoCard(
                  Icons.star_border,
                  'Featured Books',
                  (info['featured_books_count'] ?? _featuredBooks.length)
                      .toString(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Available Services',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...services.map((service) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFFB0121B),
              ),
              title: Text(service.toString()),
            ),
          );
        }).toList(),
        const SizedBox(height: 18),
        const Text(
          'Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_loadingCategories)
          const Center(child: CircularProgressIndicator())
        else if (_categoriesError != null)
          Text(_categoriesError!, style: const TextStyle(color: Colors.red))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return Chip(
                label: Text(category.toString()),
                backgroundColor: Colors.red.shade50,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final bool alreadyBorrowed = _myBooks.any((b) => b['id'] == book['id']);
    final bool available = book['available'] == true;
    final bool featured = book['featured'] == true;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 70,
              decoration: BoxDecoration(
                color: featured ? Colors.amber.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: featured ? Colors.amber.shade800 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title']?.toString() ?? 'Book',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Author: ${book['author']}'),
                  Text('Category: ${book['category']}'),
                  Text('Price: ${book['price']} JOD'),
                  const SizedBox(height: 6),
                  Text(
                    book['description']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                if (featured)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Featured',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ElevatedButton(
                  onPressed: (!available || alreadyBorrowed)
                      ? null
                      : () => _borrowBook(book),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB0121B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    alreadyBorrowed
                        ? 'Added'
                        : available
                            ? 'Borrow'
                            : 'Unavailable',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksTab() {
    if (_loadingBooks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_booksError != null) {
      return Center(
        child: Text(
          _booksError!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_books.isEmpty) {
      return const Center(
        child: Text(
          'No books available.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        return _buildBookCard(_books[index] as Map<String, dynamic>);
      },
    );
  }

  Widget _buildMyBooksTab() {
    if (_myBooks.isEmpty) {
      return const Center(
        child: Text(
          'No borrowed books yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myBooks.length,
      itemBuilder: (context, index) {
        final book = _myBooks[index];

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(
              Icons.bookmark_added_outlined,
              color: Color(0xFFB0121B),
            ),
            title: Text(
              book['title']?.toString() ?? 'Book',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Author: ${book['author']}\nCategory: ${book['category']}',
            ),
            trailing: ElevatedButton(
              onPressed: () => _returnBook(book),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Return'),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: const Color(0xFFB0121B),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Books'),
            Tab(text: 'My Books'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildBooksTab(),
          _buildMyBooksTab(),
        ],
      ),
    );
  }
}