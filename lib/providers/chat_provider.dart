import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/chat_project.dart';
import '../services/gemini_service.dart';

const String _defaultApiKey = 'AIzaSyDO-dBI-bQxHiy7FO2omEWPPHikwZ_jWaE';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(apiKey: _defaultApiKey);
});

class SelectedModel extends Notifier<String> {
  @override
  String build() => 'gemini-2.5-flash';
  void set(String model) => state = model;
}

final selectedModelProvider = NotifierProvider<SelectedModel, String>(
  SelectedModel.new,
);

class TypingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool isTyping) => state = isTyping;
}

final isTypingProvider = NotifierProvider<TypingNotifier, bool>(
  TypingNotifier.new,
);

// Projects Management
class ProjectsNotifier extends Notifier<List<ChatProject>> {
  @override
  List<ChatProject> build() => [];

  void addProject(String name) {
    final project = ChatProject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    state = [...state, project];
  }

  void deleteProject(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

final projectsProvider = NotifierProvider<ProjectsNotifier, List<ChatProject>>(
  ProjectsNotifier.new,
);

// Sessions Management
class ChatSessionsNotifier extends Notifier<List<ChatSession>> {
  @override
  List<ChatSession> build() => [];

  void addSession(ChatSession session) {
    state = [session, ...state];
  }

  void updateSessionMessages(String sessionId, List<ChatMessage> messages) {
    state = [
      for (final session in state)
        if (session.id == sessionId)
          session.copyWith(
            messages: messages,
            updatedAt: DateTime.now(),
            title: session.title == 'New Chat' && messages.isNotEmpty
                ? _generateTitle(messages.first.text)
                : session.title,
          )
        else
          session,
    ];
  }

  void moveToProject(String sessionId, String? projectId) {
    state = [
      for (final session in state)
        if (session.id == sessionId)
          session.copyWith(projectId: projectId)
        else
          session,
    ];
  }

  String _generateTitle(String text) {
    if (text.length > 25) return '${text.substring(0, 22)}...';
    return text;
  }

  void deleteSession(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final chatSessionsProvider =
    NotifierProvider<ChatSessionsNotifier, List<ChatSession>>(
      ChatSessionsNotifier.new,
    );

class CurrentSessionIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
}

final currentSessionIdProvider =
    NotifierProvider<CurrentSessionIdNotifier, String?>(
      CurrentSessionIdNotifier.new,
    );

final currentMessagesProvider = Provider<List<ChatMessage>>((ref) {
  final sessionId = ref.watch(currentSessionIdProvider);
  if (sessionId == null) return [];
  final sessions = ref.watch(chatSessionsProvider);
  return sessions
      .firstWhere(
        (s) => s.id == sessionId,
        orElse: () => ChatSession(
          id: '',
          title: '',
          messages: [],
          updatedAt: DateTime.now(),
        ),
      )
      .messages;
});

class ChatNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> sendMessage(String text) async {
    final sessionId = ref.read(currentSessionIdProvider);
    if (sessionId == null) return;

    final geminiService = ref.read(geminiServiceProvider);
    geminiService.updateModel(ref.read(selectedModelProvider));

    final sessionsNotifier = ref.read(chatSessionsProvider.notifier);
    final currentMessages = ref.read(currentMessagesProvider);

    final userMessage = ChatMessage(text: text, role: MessageRole.user);
    final updatedMessages = [...currentMessages, userMessage];
    sessionsNotifier.updateSessionMessages(sessionId, updatedMessages);

    ref.read(isTypingProvider.notifier).set(true);

    String assistantResponse = '';
    final assistantMessage = ChatMessage(
      text: '',
      role: MessageRole.model,
      timestamp: DateTime.now(),
    );

    sessionsNotifier.updateSessionMessages(sessionId, [
      ...updatedMessages,
      assistantMessage,
    ]);

    try {
      final stream = geminiService.sendMessageStream(text);
      await for (final chunk in stream) {
        assistantResponse += chunk;
        sessionsNotifier.updateSessionMessages(sessionId, [
          ...updatedMessages,
          ChatMessage(
            text: assistantResponse,
            role: MessageRole.model,
            timestamp: assistantMessage.timestamp,
          ),
        ]);
      }
    } catch (e) {
      sessionsNotifier.updateSessionMessages(sessionId, [
        ...updatedMessages,
        ChatMessage(
          text: 'Error: ${e.toString()}',
          role: MessageRole.model,
          timestamp: assistantMessage.timestamp,
        ),
      ]);
    } finally {
      ref.read(isTypingProvider.notifier).set(false);
    }
  }

  void createNewChat({String? projectId}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newSession = ChatSession(
      id: id,
      title: 'New Chat',
      messages: [],
      updatedAt: DateTime.now(),
      projectId: projectId,
    );
    ref.read(chatSessionsProvider.notifier).addSession(newSession);
    ref.read(currentSessionIdProvider.notifier).set(id);
    ref.read(geminiServiceProvider).clearHistory();
  }
}

final chatProvider = NotifierProvider<ChatNotifier, void>(ChatNotifier.new);
