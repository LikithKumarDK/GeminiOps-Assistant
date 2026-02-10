import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_history_drawer.dart';
import '../models/chat_message.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_logo.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> availableModels = [
    'gemini-2.5-flash',
    'gemini-2.5-pro',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionId = ref.watch(currentSessionIdProvider);
    final messages = ref.watch(currentMessagesProvider);
    final isTyping = ref.watch(isTypingProvider);
    final selectedModel = ref.watch(selectedModelProvider);

    ref.listen(currentMessagesProvider, (prev, next) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: const ChatHistoryDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(selectedModel),
            Expanded(
              child: sessionId == null
                  ? _buildWelcomeState()
                  : _buildChatArea(messages, isTyping),
            ),
            if (sessionId != null) _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(List<ChatMessage> messages, bool isTyping) {
    return Stack(
      children: [
        messages.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 80),
                itemBuilder: (context, index) {
                  return MessageBubble(message: messages[index]);
                },
              ),
        if (isTyping)
          Positioned(
            bottom: 20,
            left: 16,
            child: FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.aiBubbleColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const TypingIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAppBar(String selectedModel) {
    final sessionId = ref.watch(currentSessionIdProvider);
    final sessions = ref.watch(chatSessionsProvider);
    final projects = ref.watch(projectsProvider);

    String? projectName;
    if (sessionId != null) {
      final session = sessions.firstWhere((s) => s.id == sessionId);
      if (session.projectId != null) {
        projectName = projects
            .firstWhere((p) => p.id == session.projectId)
            .name;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF64748B)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const AILogo(size: 32),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'NICHI AI',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (projectName != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        projectName,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              _buildModelSelector(selectedModel),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.add_box_outlined,
              color: AppTheme.primaryColor,
            ),
            onPressed: () => ref.read(chatProvider.notifier).createNewChat(),
            tooltip: 'New Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector(String currentModel) {
    return PopupMenuButton<String>(
      onSelected: (model) {
        ref.read(selectedModelProvider.notifier).set(model);
      },
      itemBuilder: (context) => availableModels.map((model) {
        return PopupMenuItem(
          value: model,
          child: Text(
            model,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: model == currentModel
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
      child: Row(
        children: [
          Text(
            currentModel,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 14,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeInDown(child: const AILogo(size: 100)),
            const SizedBox(height: 24),
            FadeInUp(
              child: Text(
                'Welcome to GeminiOps',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Search for answers, explore ideas, or just start a conversation.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: ElevatedButton.icon(
                onPressed: () =>
                    ref.read(chatProvider.notifier).createNewChat(),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Start New Chat'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeIn(
              delay: const Duration(seconds: 1),
              child: Text(
                'Your history and projects are in the menu.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeInDown(
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.indigo.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            child: Text(
              'How can I help you in this project?',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.inter(color: const Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
  }
}
