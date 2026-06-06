import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../core/widgets/smart_cards.dart';
import '../../core/widgets/status_badge.dart';
import '../../services/librarian_service.dart';

class LibrarianDashboard extends StatefulWidget {
  final Map<String, dynamic> user;

  const LibrarianDashboard({
    super.key,
    this.user = const <String, dynamic>{},
  });

  @override
  State<LibrarianDashboard> createState() => _LibrarianDashboardState();
}

class _LibrarianDashboardState extends State<LibrarianDashboard> {
  final _service = const LibrarianService();
  final _search = TextEditingController();

  Map<String, dynamic> _dashboard = const {};
  List<Map<String, dynamic>> _books = const [];
  List<Map<String, dynamic>> _reservations = const [];
  List<Map<String, dynamic>> _borrowings = const [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _service.dashboard(),
        _service.books(),
        _service.reservations(),
        _service.borrowings(),
      ]);
      if (!mounted) return;
      setState(() {
        _dashboard = results[0] as Map<String, dynamic>;
        _books = results[1] as List<Map<String, dynamic>>;
        _reservations = results[2] as List<Map<String, dynamic>>;
        _borrowings = results[3] as List<Map<String, dynamic>>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dashboard = const {};
        _books = const [];
        _reservations = const [];
        _borrowings = const [];
      });
    }
  }

  List<Map<String, dynamic>> get _visibleBooks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _books;
    return _books.where((book) {
      return '${_title(book)} ${_author(book)} ${_category(book)}'
          .toLowerCase()
          .contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = _dashboard['total_books'] ?? _books.length;
    final available = _dashboard['available_books'] ??
        _books.where((book) => _available(book)).length;
    final borrowed = _dashboard['borrowed_books'] ??
        (_borrowings.isNotEmpty
            ? _borrowings.length
            : _books.where((book) => !_available(book)).length);
    final pending = _dashboard['pending_reservations'] ?? _reservations.length;
    final overdue = _dashboard['overdue_books'] ?? 0;

    return SmartAiScaffold(
      dense: true,
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColors.cyan,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.purpleAccent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.local_library_rounded,
                      color: AppColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Library Console',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Resource Management',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    backgroundColor: AppColors.purple3,
                    child: Icon(Icons.person_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  DashboardStat(label: 'Total Books', value: '$total'),
                  DashboardStat(
                    label: 'Available Books',
                    value: '$available',
                    accent: AppColors.success,
                  ),
                  DashboardStat(
                    label: 'Borrowed Books',
                    value: '$borrowed',
                    accent: AppColors.warning,
                  ),
                  DashboardStat(
                    label: 'Reservations',
                    value: '$pending',
                    accent: AppColors.purple3,
                  ),
                  DashboardStat(
                    label: 'Overdue Books',
                    value: '$overdue',
                    accent: AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const AiInsightCard(
                title: 'AI Insight',
                message: 'AI & ML books have high demand this week.',
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: 'Reservations'),
              const SizedBox(height: 12),
              if (_reservations.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    radius: 18,
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No reservations in the database.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ..._reservations.take(4).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReservationCard(
                        reservation: item,
                        onAction: (status) => _updateReservation(item, status),
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              const SectionTitle(title: 'Borrowings'),
              const SizedBox(height: 12),
              if (_borrowings.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    radius: 18,
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No active borrowings in the database.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ..._borrowings.take(4).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BorrowingCard(
                        borrowing: item,
                        onReturn: () => _returnBorrowing(item),
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              SectionTitle(
                title: 'Books Management',
                action: 'Add Book',
                onAction: () => _openBookEditor(),
              ),
              const SizedBox(height: 12),
              SearchField(
                controller: _search,
                hint: 'Search books',
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 14),
              if (_visibleBooks.isEmpty)
                const GlassCard(
                  radius: 18,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No books match the current search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ..._visibleBooks.map(
                (book) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BookRow(
                    book: book,
                    onEdit: () => _openBookEditor(book: book),
                    onDelete: () => _deleteBook(book),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateReservation(Map<String, dynamic> item, String status) async {
    final id = item['id'] ?? item['reservation_id'];
    setState(() => item['status'] = status);
    if (id == null) return;
    try {
      await _service.updateReservation(id, {'status': status});
    } catch (_) {}
  }

  Future<void> _deleteBook(Map<String, dynamic> book) async {
    final id = book['id'] ?? book['book_id'];
    setState(() => _books.remove(book));
    if (id == null) return;
    try {
      await _service.deleteBook(id);
    } catch (_) {}
  }

  Future<void> _returnBorrowing(Map<String, dynamic> borrowing) async {
    final id = borrowing['id'] ?? borrowing['borrowing_id'];
    setState(() {
      borrowing['status'] = 'returned';
      _borrowings.remove(borrowing);
    });
    if (id == null) return;
    try {
      await _service.returnBorrowing(id);
    } catch (_) {}
  }

  void _openBookEditor({Map<String, dynamic>? book}) {
    final title = TextEditingController(text: book == null ? '' : _title(book));
    final author = TextEditingController(text: book == null ? '' : _author(book));
    final category = TextEditingController(text: book == null ? '' : _category(book));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            18 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GlassCard(
            radius: 26,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  book == null ? 'Add Book' : 'Edit Book',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _FormField(controller: title, hint: 'Title'),
                const SizedBox(height: 10),
                _FormField(controller: author, hint: 'Author'),
                const SizedBox(height: 10),
                _FormField(controller: category, hint: 'Category'),
                const SizedBox(height: 18),
                GradientButton(
                  label: book == null ? 'Create Book' : 'Save Book',
                  onPressed: () async {
                    final body = {
                      'title': title.text.trim(),
                      'author': author.text.trim(),
                      'category': category.text.trim(),
                      'available': true,
                    };
                    if (book == null) {
                      final created = await _service.createBook(body);
                      setState(() => _books.insert(0, {...body, ...created}));
                    } else {
                      final id = book['id'] ?? book['book_id'];
                      if (id != null) await _service.updateBook(id, body);
                      setState(() => book.addAll(body));
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final ValueChanged<String> onAction;

  const _ReservationCard({
    required this.reservation,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final status = (reservation['status'] ?? 'pending').toString();

    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark_rounded, color: AppColors.purple3),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  (reservation['book_title'] ?? reservation['book'] ?? 'Reserved Book')
                      .toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              StatusBadge(
                label: status,
                tone: status == 'approved'
                    ? StatusBadgeTone.success
                    : StatusBadgeTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${reservation['student_name'] ?? 'Student'} - ${reservation['pickup_time'] ?? 'Pickup today'}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onAction('rejected'),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onAction('approved'),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookRow({
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.cyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(book),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_author(book)} - ${_category(book)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: _available(book) ? 'available' : 'borrowed',
            tone: _available(book) ? StatusBadgeTone.success : StatusBadgeTone.danger,
            dot: false,
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _BorrowingCard extends StatelessWidget {
  final Map<String, dynamic> borrowing;
  final VoidCallback onReturn;

  const _BorrowingCard({
    required this.borrowing,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.assignment_return_rounded, color: AppColors.cyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (borrowing['book_title'] ?? 'Borrowed Book').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (borrowing['student_name'] ?? borrowing['status'] ?? 'Student')
                      .toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onReturn,
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _FormField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.bgDark2.withValues(alpha: 0.76),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

String _title(Map<String, dynamic> book) {
  return (book['title'] ?? book['name'] ?? 'Book').toString();
}

String _author(Map<String, dynamic> book) {
  return (book['author'] ?? 'Unknown Author').toString();
}

String _category(Map<String, dynamic> book) {
  return (book['category'] ?? 'General').toString();
}

bool _available(Map<String, dynamic> book) {
  return book['available'] != false && book['status'] != 'borrowed';
}
