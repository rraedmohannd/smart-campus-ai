import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class ChatbotScreen extends StatefulWidget {
  final String studentId;

  const ChatbotScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];

  bool _isSending = false;

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

  String get _screenTitle => _isArabic ? 'المساعد الذكي' : 'AI Chatbot';

  String get _welcomeMessage => _isArabic
      ? 'مرحبًا بك في Smart Campus AI. اسألني عن خدمات المكتبة، أو الباصات، أو القوانين الجامعية، أو معلومات الحرم الجامعي.'
      : 'Welcome to Smart Campus AI. Ask me about library services, buses, university rules, or campus information.';

  String get _assistantTitle =>
      _isArabic ? 'مساعد Smart Campus' : 'Smart Campus Assistant';

  String get _assistantSubtitle => _isArabic
      ? 'اسأل عن الباصات، والكتب، والقوانين الجامعية، والخدمات العامة داخل الحرم.'
      : 'Ask about buses, library books, university rules, and general campus services.';

  String get _youLabel => _isArabic ? 'أنت' : 'You';

  String get _botLabel => 'Smart Campus AI';

  String get _inputHint => _isArabic
      ? 'اسأل Smart Campus AI أي شيء...'
      : 'Ask Smart Campus AI anything...';

  String get _noResponseText =>
      _isArabic ? 'لم يتم استلام رد.' : 'No response received.';

  String _serverErrorText(int statusCode) {
    return _isArabic
        ? 'أعاد الخادم خطأ ($statusCode). يرجى المحاولة مرة أخرى.'
        : 'The server returned an error ($statusCode). Please try again.';
  }

  String get _connectionErrorText => _isArabic
      ? 'خطأ في الاتصال. تأكد من تشغيل الـ backend ثم حاول مرة أخرى.'
      : 'Connection error. Please make sure the backend is running and try again.';

  String get _quickLibraryHours =>
      _isArabic ? 'مواعيد المكتبة' : 'Library working hours';

  String get _quickBusRoutes =>
      _isArabic ? 'مسارات الباصات' : 'Bus routes';

  String get _quickRules =>
      _isArabic ? 'القوانين الجامعية' : 'University rules';

  String get _quickAdmission =>
      _isArabic ? 'معلومات القبول' : 'Admission information';

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'bot',
      'text': _welcomeMessage,
    });
  }

  Future<void> _sendMessage() async {
    final message = _msgController.text.trim();

    if (message.isEmpty || _isSending) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': message,
      });
      _isSending = true;
    });

    _msgController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/chat/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'student_id': widget.studentId,
          'session_id': widget.studentId,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botReply = data['reply']?.toString() ?? _noResponseText;

        setState(() {
          _messages.add({
            'role': 'bot',
            'text': botReply,
          });
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'bot',
            'text': _serverErrorText(response.statusCode),
          });
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'bot',
          'text': _connectionErrorText,
        });
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    final isUser = message['role'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
                  colors: [
                    neonCyan.withOpacity(0.92),
                    electricBlue.withOpacity(0.92),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 8),
            bottomRight: Radius.circular(isUser ? 8 : 22),
          ),
          border: Border.all(
            color: isUser
                ? neonCyan.withOpacity(0.22)
                : neonCyan.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? neonCyan.withOpacity(0.18)
                  : Colors.black.withOpacity(0.10),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? _youLabel : _botLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isUser ? Colors.black87 : neonCyan,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message['text'] ?? '',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: isUser ? Colors.black : textPrimary,
              ),
              textAlign: _isArabic && !isUser ? TextAlign.right : TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(22),
          ),
          border: Border.all(
            color: neonCyan.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: neonCyan,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: neonCyan.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: neonCyan.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPrompt(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _msgController.text = text;
        _sendMessage();
      },
      backgroundColor: Colors.white.withOpacity(0.06),
      side: BorderSide(color: neonCyan.withOpacity(0.10)),
      labelStyle: const TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: neonCyan.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: neonCyan.withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
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
                  _assistantTitle,
                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _assistantSubtitle,
                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
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
          border: Border.all(
            color: neonCyan.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: neonCyan.withOpacity(0.03),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _messages.length + (_isSending ? 1 : 0),
          itemBuilder: (context, index) {
            if (_isSending && index == _messages.length) {
              return _buildTypingBubble();
            }
            return _buildMessageBubble(_messages[index]);
          },
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: neonCyan.withOpacity(0.10),
                ),
              ),
              child: TextField(
                controller: _msgController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                style: const TextStyle(color: textPrimary),
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: _inputHint,
                  hintStyle: const TextStyle(color: mutedText),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 58,
            height: 58,
            child: ElevatedButton(
              onPressed: _isSending ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: neonCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quickPrompts = [
      _quickLibraryHours,
      _quickBusRoutes,
      _quickRules,
      _quickAdmission,
    ];

    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: AppBar(
        title: Text(
          _screenTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
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
              top: -110,
              left: -80,
              child: _GlowCircle(color: neonCyan),
            ),
            Positioned(
              bottom: -130,
              right: -80,
              child: _GlowCircle(color: electricBlue),
            ),
            Column(
              children: [
                _buildHeaderCard(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment:
                        _isArabic ? Alignment.centerRight : Alignment.centerLeft,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: quickPrompts.map(_buildQuickPrompt).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildChatArea(),
                _buildInputArea(),
              ],
            ),
          ],
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