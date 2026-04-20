import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  final String _baseUrl = 'http://localhost:8000';
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

  static const Color bgPrimary = Color(0xFF0A0E27);
  static const Color bgSecondary = Color(0xFF1E0A3C);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color electricBlue = Color(0xFF0080FF);
  static const Color brightCyan = Color(0xFF00FFFF);
  static const Color cardBase = Color(0xFF1A1F3A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color mutedText = Color(0xFFB8C1D9);

  bool get _isArabic =>
      SmartCampusApp.of(context).locale.languageCode == 'ar';

  String get _appBarTitle => _isArabic ? 'المكتبة' : 'Library';
  String get _tabInfo => _isArabic ? 'معلومات' : 'Info';
  String get _tabBooks => _isArabic ? 'الكتب' : 'Books';
  String get _tabMyBooks => _isArabic ? 'كتبي' : 'My Books';

  String get _smartLibraryTitle =>
      _isArabic ? 'المكتبة الذكية' : 'Smart Library';
  String get _workingHoursLabel =>
      _isArabic ? 'ساعات العمل' : 'Working Hours';
  String get _totalBooksLabel => _isArabic ? 'إجمالي الكتب' : 'Total Books';
  String get _featuredBooksLabel =>
      _isArabic ? 'الكتب المميزة' : 'Featured Books';
  String get _availableServicesTitle =>
      _isArabic ? 'الخدمات المتاحة' : 'Available Services';
  String get _categoriesTitle => _isArabic ? 'التصنيفات' : 'Categories';

  String get _searchHint => _isArabic
      ? 'ابحث بالعنوان أو المؤلف أو التصنيف أو كلمة مفتاحية...'
      : 'Search by title, author, category, or keyword...';

  String get _bookText => _isArabic ? 'كتاب' : 'Book';
  String get _generalText => _isArabic ? 'عام' : 'General';
  String get _featuredText => _isArabic ? 'مميز' : 'Featured';
  String get _availableText => _isArabic ? 'متاح' : 'Available';
  String get _unavailableText => _isArabic ? 'غير متاح' : 'Unavailable';
  String get _closeText => _isArabic ? 'إغلاق' : 'Close';
  String get _borrowText => _isArabic ? 'استعارة' : 'Borrow';
  String get _addedText => _isArabic ? 'مضاف' : 'Added';
  String get _returnText => _isArabic ? 'إرجاع' : 'Return';

  String get _authorLabel => _isArabic ? 'المؤلف' : 'Author';
  String get _categoryLabel => _isArabic ? 'التصنيف' : 'Category';
  String get _priceLabel => _isArabic ? 'السعر' : 'Price';
  String get _availabilityLabel => _isArabic ? 'التوفر' : 'Availability';
  String get _descriptionTitle => _isArabic ? 'الوصف' : 'Description';

  String get _noDescriptionText => _isArabic
      ? 'لا يوجد وصف متاح.'
      : 'No description available.';

  String get _noBooksAvailableText =>
      _isArabic ? 'لا توجد كتب متاحة.' : 'No books available.';

  String get _noMatchingBooksTitle =>
      _isArabic ? 'لا توجد كتب مطابقة' : 'No matching books found';

  String get _noMatchingBooksSubtitle => _isArabic
      ? 'جرّب البحث بالعنوان أو المؤلف أو التصنيف أو بكلمة مفتاحية.'
      : 'Try searching by title, author, category, or keyword.';

  String get _noBorrowedBooksText =>
      _isArabic ? 'لا توجد كتب مستعارة بعد.' : 'No borrowed books yet.';

  String get _alreadyInMyBooksText => _isArabic
      ? 'هذا الكتاب موجود بالفعل في كتبي'
      : 'This book is already in My Books';

  String _addedToMyBooksText(String title) => _isArabic
      ? 'تمت إضافة $title إلى كتبي'
      : '$title added to My Books';

  String _returnedSuccessfullyText(String title) => _isArabic
      ? 'تم إرجاع $title بنجاح'
      : '$title returned successfully';

  String get _connectionErrorText =>
      _isArabic ? 'خطأ في الاتصال' : 'Connection error';

  String _serverErrorText(int code) =>
      _isArabic ? 'خطأ من الخادم: $code' : 'Server error: $code';

  String get _authorPrefix => _isArabic ? 'المؤلف: ' : 'Author: ';
  String get _categoryPrefix => _isArabic ? 'التصنيف: ' : 'Category: ';
  String get _byPrefix => _isArabic ? 'بواسطة ' : 'by ';

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
          _infoError = _serverErrorText(response.statusCode);
          _loadingInfo = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _infoError = _connectionErrorText;
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
          _booksError = _serverErrorText(response.statusCode);
          _loadingBooks = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _booksError = _connectionErrorText;
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
          _featuredError = _serverErrorText(response.statusCode);
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
          _categoriesError = _serverErrorText(response.statusCode);
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
        SnackBar(content: Text(_alreadyInMyBooksText)),
      );
      return;
    }

    setState(() {
      _myBooks.add(Map<String, dynamic>.from(book));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_addedToMyBooksText(book['title'].toString()))),
    );
  }

  void _returnBook(Map<String, dynamic> book) {
    setState(() {
      _myBooks.removeWhere((b) => b['id'] == book['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_returnedSuccessfullyText(book['title'].toString())),
      ),
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
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 760),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cardBase.withOpacity(0.96),
                      const Color(0xFF16132F).withOpacity(0.96),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: neonCyan.withOpacity(0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonCyan.withOpacity(0.10),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        _isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 84,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: featured
                                    ? [
                                        const Color(0xFF5C4300),
                                        const Color(0xFF2E2410),
                                      ]
                                    : [
                                        const Color(0xFF10204F),
                                        const Color(0xFF1A0F49),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: featured
                                    ? Colors.amber.withOpacity(0.25)
                                    : neonCyan.withOpacity(0.18),
                              ),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: featured ? Colors.amber : neonCyan,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: _isArabic
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book['title']?.toString() ?? _bookText,
                                  textAlign:
                                      _isArabic ? TextAlign.right : TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$_byPrefix${book['author']}',
                                  textAlign:
                                      _isArabic ? TextAlign.right : TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: mutedText,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _DetailBadge(
                                      text:
                                          book['category']?.toString() ?? _generalText,
                                      color: neonCyan,
                                    ),
                                    if (featured)
                                      _DetailBadge(
                                        text: _featuredText,
                                        color: const Color(0xFFF59E0B),
                                      ),
                                    _DetailBadge(
                                      text: available
                                          ? _availableText
                                          : _unavailableText,
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
                            childAspectRatio: isSmall ? 4.0 : 3.0,
                            children: [
                              _buildDetailTile(
                                icon: Icons.person_outline,
                                label: _authorLabel,
                                value: book['author']?.toString() ?? '-',
                              ),
                              _buildDetailTile(
                                icon: Icons.category_outlined,
                                label: _categoryLabel,
                                value: book['category']?.toString() ?? '-',
                              ),
                              _buildDetailTile(
                                icon: Icons.payments_outlined,
                                label: _priceLabel,
                                value: '${book['price']} JOD',
                              ),
                              _buildDetailTile(
                                icon: Icons.inventory_2_outlined,
                                label: _availabilityLabel,
                                value: available ? _availableText : _unavailableText,
                                valueColor: available
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFDC2626),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _descriptionTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: neonCyan.withOpacity(0.08),
                          ),
                        ),
                        child: Text(
                          book['description']?.toString() ?? _noDescriptionText,
                          textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.6,
                            color: textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              _closeText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
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
                            child: Text(alreadyBorrowed ? _addedText : _borrowText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: neonCyan.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: neonCyan.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.circle,
              size: 0,
              color: Colors.transparent,
            ),
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Container(),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: neonCyan.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: neonCyan,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13.5,
                  color: textSecondary,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: valueColor ?? textSecondary,
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: neonCyan.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: neonCyan.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: neonCyan, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: textSecondary, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
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
      return const Center(
        child: CircularProgressIndicator(color: neonCyan),
      );
    }

    if (_infoError != null) {
      return Center(
        child: _ErrorCard(message: _infoError!),
      );
    }

    final info = _libraryInfo ?? {};
    final services = (info['services'] as List?) ?? [];
    final categories = _categories;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10204F).withOpacity(0.95),
                const Color(0xFF1A0F49).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: neonCyan.withOpacity(0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: neonCyan.withOpacity(0.08),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                _isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_library_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _smartLibraryTitle,
                    style: const TextStyle(
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
                _workingHoursLabel,
                info['working_hours']?.toString() ?? '-',
              ),
              _buildInfoCard(
                Icons.menu_book_outlined,
                _totalBooksLabel,
                (info['total_books'] ?? _books.length).toString(),
              ),
              _buildInfoCard(
                Icons.star_border,
                _featuredBooksLabel,
                (info['featured_books_count'] ?? _featuredBooks.length)
                    .toString(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          _availableServicesTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...services.map((service) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: neonCyan.withOpacity(0.08)),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: neonCyan,
              ),
              title: Text(
                service.toString(),
                style: const TextStyle(color: textPrimary),
                textAlign: _isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 18),
        Text(
          _categoriesTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        if (_loadingCategories)
          const Center(child: CircularProgressIndicator(color: neonCyan))
        else if (_categoriesError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _categoriesError!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: neonCyan.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: neonCyan.withOpacity(0.14)),
                ),
                child: Text(
                  category.toString(),
                  style: const TextStyle(
                    color: neonCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonCyan.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withOpacity(0.03),
            blurRadius: 18,
            spreadRadius: 1,
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
        style: const TextStyle(color: textPrimary),
        decoration: InputDecoration(
          hintText: _searchHint,
          hintStyle: const TextStyle(color: mutedText),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: mutedText,
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
                  icon: const Icon(Icons.close_rounded, color: mutedText),
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showBookDetails(book),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: neonCyan.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: neonCyan.withOpacity(0.03),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 78,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: featured
                          ? [
                              const Color(0xFF5C4300),
                              const Color(0xFF2E2410),
                            ]
                          : [
                              const Color(0xFF10204F),
                              const Color(0xFF1A0F49),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: featured
                          ? Colors.amber.withOpacity(0.25)
                          : neonCyan.withOpacity(0.12),
                    ),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: featured ? Colors.amber : neonCyan,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        _isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title']?.toString() ?? _bookText,
                        textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_byPrefix${book['author']}',
                        textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: mutedText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniInfoChip(
                            icon: Icons.category_outlined,
                            text: book['category']?.toString() ?? _generalText,
                          ),
                          _MiniInfoChip(
                            icon: Icons.payments_outlined,
                            text: '${book['price']} JOD',
                          ),
                          if (featured)
                            _MiniTextBadge(
                              text: _featuredText,
                              color: const Color(0xFFF59E0B),
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
                      text: available ? _availableText : _unavailableText,
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
                        backgroundColor: neonCyan,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(88, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(alreadyBorrowed ? _addedText : _borrowText),
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
      return const Center(child: CircularProgressIndicator(color: neonCyan));
    }

    if (_booksError != null) {
      return Center(
        child: _ErrorCard(message: _booksError!),
      );
    }

    final books = _filteredBooks;

    if (_books.isEmpty) {
      return Center(
        child: Text(
          _noBooksAvailableText,
          style: const TextStyle(color: mutedText, fontSize: 16),
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
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: neonCyan.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: mutedText,
                ),
                const SizedBox(height: 12),
                Text(
                  _noMatchingBooksTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _noMatchingBooksSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: mutedText,
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
      return Center(
        child: Text(
          _noBorrowedBooksText,
          style: const TextStyle(color: mutedText, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myBooks.length,
      itemBuilder: (context, index) {
        final book = _myBooks[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: neonCyan.withOpacity(0.08)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: neonCyan.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bookmark_added_outlined,
                color: neonCyan,
              ),
            ),
            title: Text(
              book['title']?.toString() ?? _bookText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            subtitle: Text(
              '$_authorPrefix${book['author']}\n$_categoryPrefix${book['category']}',
              style: const TextStyle(color: mutedText),
            ),
            trailing: ElevatedButton(
              onPressed: () => _returnBook(book),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.10),
                foregroundColor: textPrimary,
                minimumSize: const Size(84, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(_returnText),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _appBarTitle,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      elevation: 0,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: neonCyan,
        indicatorWeight: 3,
        labelColor: textPrimary,
        unselectedLabelColor: mutedText,
        dividerColor: Colors.white.withOpacity(0.06),
        tabs: [
          Tab(text: _tabInfo),
          Tab(text: _tabBooks),
          Tab(text: _tabMyBooks),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              bgPrimary,
              bgSecondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -60,
              child: _GlowCircle(color: neonCyan),
            ),
            Positioned(
              bottom: -120,
              right: -70,
              child: _GlowCircle(color: electricBlue),
            ),
            TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildBooksTab(),
                _buildMyBooksTab(),
              ],
            ),
          ],
        ),
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _LibraryScreenState.neonCyan.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: _LibraryScreenState.mutedText,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: _LibraryScreenState.textSecondary,
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

class _GlowCircle extends StatelessWidget {
  final Color color;

  const _GlowCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.08),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 120,
            spreadRadius: 26,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.18),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}