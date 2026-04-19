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
  final TextEditingController _searchController = TextEditingController();

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

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllLibraryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBooks {
    final query = _searchQuery.trim().toLowerCase();
    final books = _books.cast<Map<String, dynamic>>();

    if (query.isEmpty) return books;

    return books.where((book) {
      final title = book['title']?.toString().toLowerCase() ?? '';
      final author = book['author']?.toString().toLowerCase() ?? '';
      final category = book['category']?.toString().toLowerCase() ?? '';
      final description = book['description']?.toString().toLowerCase() ?? '';

      return title.contains(query) ||
          author.contains(query) ||
          category.contains(query) ||
          description.contains(query);
    }).toList();
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

  void _showBookDetails(Map<String, dynamic> book) {
    final bool alreadyBorrowed = _myBooks.any((b) => b['id'] == book['id']);
    final bool available = book['available'] == true;
    final bool featured = book['featured'] == true;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 760),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 84,
                        decoration: BoxDecoration(
                          color: featured
                              ? Colors.amber.shade100
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: featured
                              ? Colors.amber.shade800
                              : const Color(0xFF64748B),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['title']?.toString() ?? 'Book',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'by ${book['author']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _DetailBadge(
                                  text: book['category']?.toString() ?? 'General',
                                  color: const Color(0xFF06B6D4),
                                ),
                                if (featured)
                                  _DetailBadge(
                                    text: 'Featured',
                                    color: const Color(0xFFF59E0B),
                                  ),
                                _DetailBadge(
                                  text: available ? 'Available' : 'Unavailable',
                                  color: available
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFDC2626),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmall = constraints.maxWidth < 560;

                      return GridView.count(
                        crossAxisCount: isSmall ? 1 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isSmall ? 4.2 : 3.0,
                        children: [
                          _buildDetailTile(
                            icon: Icons.person_outline,
                            label: 'Author',
                            value: book['author']?.toString() ?? '-',
                          ),
                          _buildDetailTile(
                            icon: Icons.category_outlined,
                            label: 'Category',
                            value: book['category']?.toString() ?? '-',
                          ),
                          _buildDetailTile(
                            icon: Icons.payments_outlined,
                            label: 'Price',
                            value: '${book['price']} JOD',
                          ),
                          _buildDetailTile(
                            icon: Icons.inventory_2_outlined,
                            label: 'Availability',
                            value: available ? 'Available' : 'Unavailable',
                            valueColor: available
                                ? const Color(0xFF10B981)
                                : const Color(0xFFDC2626),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      book['description']?.toString() ?? 'No description available.',
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: (!available || alreadyBorrowed)
                            ? null
                            : () {
                                Navigator.pop(context);
                                _borrowBook(book);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          alreadyBorrowed ? 'Added' : 'Borrow',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 19,
              color: const Color(0xFF06B6D4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF475569),
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: valueColor ?? const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
          Icon(icon, color: const Color(0xFF06B6D4)),
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
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_library_outlined, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Smart Library',
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF06B6D4),
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
                backgroundColor: const Color(0xFFE0F2FE),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by title, author, category, or keyword...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildBookRowCard(Map<String, dynamic> book) {
    final bool alreadyBorrowed = _myBooks.any((b) => b['id'] == book['id']);
    final bool available = book['available'] == true;
    final bool featured = book['featured'] == true;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showBookDetails(book),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 78,
                  decoration: BoxDecoration(
                    color: featured
                        ? Colors.amber.shade100
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: featured
                        ? Colors.amber.shade800
                        : const Color(0xFF64748B),
                    size: 28,
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
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'by ${book['author']}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniInfoChip(
                            icon: Icons.category_outlined,
                            text: book['category']?.toString() ?? 'General',
                          ),
                          _MiniInfoChip(
                            icon: Icons.payments_outlined,
                            text: '${book['price']} JOD',
                          ),
                          if (featured)
                            const _MiniTextBadge(
                              text: 'Featured',
                              color: Color(0xFFF59E0B),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MiniTextBadge(
                      text: available ? 'Available' : 'Unavailable',
                      color: available
                          ? const Color(0xFF10B981)
                          : const Color(0xFFDC2626),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: (!available || alreadyBorrowed)
                          ? null
                          : () => _borrowBook(book),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(88, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(alreadyBorrowed ? 'Added' : 'Borrow'),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

    final books = _filteredBooks;

    if (_books.isEmpty) {
      return const Center(
        child: Text(
          'No books available.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _buildSearchBar(),
        if (books.isEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: Color(0xFF94A3B8),
                ),
                SizedBox(height: 12),
                Text(
                  'No matching books found',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Try searching by title, author, category, or keyword.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )
        else
          ...books.map(_buildBookRowCard),
      ],
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
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bookmark_added_outlined,
                  color: Color(0xFF06B6D4),
                ),
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
                  backgroundColor: const Color(0xFF334155),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(84, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Return'),
              ),
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
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF06B6D4),
          labelColor: const Color(0xFF0F172A),
          unselectedLabelColor: const Color(0xFF64748B),
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

class _MiniInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTextBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniTextBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _DetailBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}