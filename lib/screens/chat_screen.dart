import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coach_message.dart';
import '../services/ai_coach_service.dart';
import '../services/tr.dart';
import '../services/points_service.dart';
import '../services/avatar_service.dart';
import '../widgets/avatar_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final AiCoachService _aiService;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<CoachMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _aiService = context.read<AiCoachService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<PointsService>().profile;
      setState(() {
        _messages.add(CoachMessage(
          text: _aiService.greeting(profile),
          sender: MessageSender.coach,
        ));
      });
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final pointsService = context.read<PointsService>();

    setState(() {
      _messages.add(CoachMessage(text: text, sender: MessageSender.user));
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    final reply = await _aiService.respond(
      text,
      pointsService.profile,
      history: _messages.sublist(0, _messages.length - 1),
    );

    await pointsService.addPoints(2);

    if (!mounted) return;
    setState(() {
      _messages.add(CoachMessage(text: reply, sender: MessageSender.coach));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarConfig = context.watch<AvatarService>().config;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.45),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              AvatarWidget(config: avatarConfig, mood: AvatarMood.happy, size: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('yourCoach'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      context.tr('coachSubtitle'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return const _TypingBubble();
              }
              final message = _messages[index];
              return _MessageBubble(message: message);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: context.tr('typeMessage'),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _send,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final CoachMessage message;

  const _MessageBubble({required this.message});

  Widget _parseBoldText(String text, bool isUser) {
    final baseStyle = TextStyle(color: isUser ? Colors.white : Colors.black87);
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.w900);

    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: boldStyle,
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurpleAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: _parseBoldText(message.text, isUser),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const SizedBox(
          width: 24,
          height: 12,
          child: Center(
            child: Text('...', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
