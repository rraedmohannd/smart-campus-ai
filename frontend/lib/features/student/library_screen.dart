import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../core/widgets/smart_cards.dart';
import '../../services/library_service.dart';

class LibraryScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const LibraryScreen({
    super.key,
    this.user = const <String, dynamic>{},
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _libraryService = const LibraryService();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _books = const [];
  List<Map<String, dynamic>> _featured = const [];
  List<String> _categories = const ['All', 'AI & ML', 'Engineering', 'Mathematics'];
  String _activeCategory = 'All';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _libraryService.books(),
        _libraryService.featured(),
        _libraryService.categories(),
      ]);
      if (!mounted) return;
      final books = results[0] as List<Map<String, dynamic>>;
      final featured = results[1] as List<Map<String, dynamic>>;
      final categories = results[2]
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
      setState(() {
        _books = books;
        _featured = featured.isEmpty ? _books.take(4).toList() : featured;
        _categories = ['All', ...categories.where((item) => item != 'All')];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _books = const [];
        _featured = const [];
      });
    }
  }

  List<Map<String, dynamic>> get _visibleBooks {
    final query = _query.trim().toLowerCase();
    return _books.where((book) {
      final category = _bookCategory(book).toLowerCase();
      final matchesCategory =
          _activeCategory == 'All' || category == _activeCategory.toLowerCase();
      final haystack =
          '${_bookTitle(book)} ${_bookAuthor(book)} ${_bookCategory(book)}'
              .toLowerCase();
      return matchesCategory && (query.isEmpty || haystack.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleBooks;
    final recommended = visible.isEmpty ? _featured : visible.take(6).toList();

    return SmartAiScaffold(
      dense: true,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.cyan,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Digital Library',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Access 2.4M+ academic resources',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Reservations',
                          onPressed: _showReservationsInfo,
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SearchField(
                      controller: _searchController,
                      hint: 'Search books, journals, or authors...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final selected = category == _activeCategory;
                          return ChoiceChip(
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _activeCategory = category),
                            label: Text(category),
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                            selectedColor: AppColors.purple3,
                            backgroundColor: AppColors.glass.withValues(alpha: 0.80),
                            side: BorderSide(
                              color: selected
                                  ? Colors.transparent
                                  : AppColors.purpleAccent.withValues(alpha: 0.22),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    const SectionTitle(
                      title: 'Recommended for You',
                      action: 'See All',
                    ),
                    const SizedBox(height: 12),
                    if (recommended.isEmpty)
                      const GlassCard(
                        radius: 18,
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No books are available in the database.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      SizedBox(
                        height: 286,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: recommended.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final book = recommended[index];
                            return BookCard(
                              title: _bookTitle(book),
                              author: _bookAuthor(book),
                              available: _bookAvailable(book),
                              coverUrl: _bookCover(book),
                              onBookmark: () => _showBookInfo(book),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Center(child: SectionTitle(title: 'My Reservations')),
                    const SizedBox(height: 12),
                    const GlassCard(
                      radius: 20,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No active reservations are available from the current backend.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNav(
              currentIndex: 3,
              onTap: _handleNav,
              items: const [
                AppBottomNavItem(label: 'Home', icon: Icons.home_rounded),
                AppBottomNavItem(label: 'Chat', icon: Icons.smart_toy_rounded),
                AppBottomNavItem(label: 'Bus', icon: Icons.directions_bus_rounded),
                AppBottomNavItem(label: 'Library', icon: Icons.local_library_rounded),
                AppBottomNavItem(label: 'Profile', icon: Icons.person_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleNav(int index) {
    final routes = [
      '/student-dashboard',
      '/student-chat',
      '/student-bus',
      '/student-library',
      '/student-profile',
    ];
    if (index == 3) return;
    Navigator.of(context).pushReplacementNamed(
      routes[index],
      arguments: widget.user,
    );
  }

  void _showReservationsInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: const Text('Reservations'),
          content: const Text(
            'Student reservation actions are not available in the current backend. Librarians can manage reservations from the Library Console.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showBookInfo(Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: Text(_bookTitle(book)),
          content: Text(
            '${_bookAuthor(book)}\nCategory: ${_bookCategory(book)}\nStatus: ${_bookAvailable(book) ? 'Available' : 'Borrowed'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

String _bookTitle(Map<String, dynamic> book) {
  return (book['title'] ?? book['name'] ?? 'Neural Networks and Deep Learning')
      .toString();
}

String _bookAuthor(Map<String, dynamic> book) {
  return (book['author'] ?? book['authors'] ?? 'Michael Nielsen').toString();
}

String _bookCategory(Map<String, dynamic> book) {
  return (book['category'] ?? book['subject'] ?? 'AI & ML').toString();
}

String? _bookCover(Map<String, dynamic> book) {
  return (book['cover_url'] ?? book['image'] ?? book['thumbnail'])?.toString();
}

bool _bookAvailable(Map<String, dynamic> book) {
  final status = (book['status'] ?? '').toString().toLowerCase();
  if (status.contains('borrow') || status.contains('unavailable')) return false;
  return book['available'] != false && book['is_available'] != false;
}
