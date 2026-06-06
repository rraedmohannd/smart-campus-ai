import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../services/chat_service.dart';

class ChatbotScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String? studentId;

  const ChatbotScreen({
    super.key,
    this.user = const <String, dynamic>{},
    this.studentId,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _chatService = const ChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  late final String _sessionId;
  bool _sending = false;

  String get _userId =>
      (widget.studentId ??
              widget.user['student_id'] ??
              widget.user['id'] ??
              '20260001')
          .toString();

  @override
  void initState() {
    super.initState();
    _sessionId = (widget.user['session_id'] ?? 'frontend-$_userId').toString();
    _messages.add(
      const _ChatMessage(
        text:
            "Hello Student! I'm your Smart Campus AI. How can I help you with rules, buses, or library books today?",
        isUser: false,
        time: '09:41 AM',
      ),
    );
    _loadHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _chatService.history(_sessionId);
      if (!mounted || history.isEmpty) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(history.map(_fromHistory));
      });
      _scrollToBottom();
    } catch (_) {
      // Frontend-only fallback: keep the local welcome message if history is unavailable.
    }
  }

  _ChatMessage _fromHistory(Map<String, dynamic> item) {
    final role = (item['role'] ?? item['sender'] ?? '').toString().toLowerCase();
    final text = (item['message'] ??
            item['content'] ??
            item['text'] ??
            item['reply'] ??
            item['response'] ??
            '')
        .toString();
    return _ChatMessage(
      text: text.isEmpty ? 'Message unavailable' : text,
      isUser: role.contains('user') || role.contains('student'),
      time: _timeLabel(item['created_at'] ?? item['time']),
    );
  }

  Future<void> _send([String? prompt]) async {
    final text = (prompt ?? _messageController.text).trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, time: _now()));
      _sending = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final data = await _chatService.send(
        sessionId: _sessionId,
        message: text,
        userId: _userId,
      );
      final reply = (data['reply'] ??
              data['response'] ??
              data['answer'] ??
              data['message'] ??
              'No response received.')
          .toString();
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false, time: _now()));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatMessage(
            text:
                'I could not reach the campus AI service right now. Please try again shortly.',
            isUser: false,
            time: 'Now',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToBottom();
      }
    }
  }

  String _timeLabel(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.isEmpty) return _now();
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;
    return _formatTime(parsed.toLocal());
  }

  String _now() => _formatTime(DateTime.now());

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 90), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartAiScaffold(
      dense: true,
      resizeToAvoidBottomInset: true,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'AI Chatbot',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.purpleAccent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: AppColors.cyan),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
                itemCount: _messages.length + (_sending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_sending && index == _messages.length) {
                    return const _TypingBubble();
                  }
                  return _MessageBubble(message: _messages[index]);
                },
              ),
            ),
            _SuggestionBar(onTap: _send),
            _InputBar(
              controller: _messageController,
              sending: _sending,
              onSend: () => _send(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) const _BotIcon(),
          if (!isUser) const SizedBox(width: 10),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 310),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? AppColors.purpleGradient
                    : LinearGradient(
                        colors: [
                          AppColors.purple1.withValues(alpha: 0.96),
                          AppColors.purple2.withValues(alpha: 0.78),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: Radius.circular(isUser ? 20 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 20),
                ),
                border: Border.all(
                  color: AppColors.purple3.withValues(alpha: 0.22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple3.withValues(alpha: 0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.time,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _BotIcon extends StatelessWidget {
  const _BotIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.purple3.withValues(alpha: 0.55),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          _BotIcon(),
          SizedBox(width: 10),
          GlassCard(
            radius: 18,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Thinking...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _SuggestionBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const chips = ['Registration rules', 'Bus 3 status', 'Library hours'];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final text = chips[index];
          return ActionChip(
            onPressed: () => onTap(text),
            avatar: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.cyan,
              size: 14,
            ),
            label: Text(text),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
            backgroundColor: AppColors.glass.withValues(alpha: 0.86),
            side: BorderSide(
              color: AppColors.purpleAccent.withValues(alpha: 0.22),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: chips.length,
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        26,
        8,
        26,
        18 + MediaQuery.of(context).viewInsets.bottom * 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.82),
        border: Border(
          top: BorderSide(color: AppColors.purpleAccent.withValues(alpha: 0.18)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: sending ? null : onSend,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple3.withValues(alpha: 0.60),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
