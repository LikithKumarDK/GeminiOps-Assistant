import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session.dart';
import '../models/chat_project.dart';
import '../theme/app_theme.dart';
import 'ai_logo.dart';

class ChatHistoryDrawer extends ConsumerStatefulWidget {
  const ChatHistoryDrawer({super.key});

  @override
  ConsumerState<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends ConsumerState<ChatHistoryDrawer> {
  final TextEditingController _projectController = TextEditingController();

  void _showCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'New Project',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _projectController,
          decoration: const InputDecoration(hintText: 'Project Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_projectController.text.trim().isNotEmpty) {
                ref
                    .read(projectsProvider.notifier)
                    .addProject(_projectController.text.trim());
                _projectController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(chatSessionsProvider);
    final projects = ref.watch(projectsProvider);
    final currentSessionId = ref.watch(currentSessionIdProvider);

    // Filter sessions into projects and uncategorized
    final uncategorizedSessions = sessions
        .where((s) => s.projectId == null)
        .toList();

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(ref),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                if (projects.isNotEmpty) ...[
                  _buildSectionHeader(
                    'PROJECTS',
                    Icons.folder_open_rounded,
                    onAdd: _showCreateProjectDialog,
                  ),
                  ...projects.map((project) {
                    final projectSessions = sessions
                        .where((s) => s.projectId == project.id)
                        .toList();
                    return _buildProjectExpansionTile(
                      project,
                      projectSessions,
                      currentSessionId,
                    );
                  }).toList(),
                  const Divider(height: 32),
                ],
                _buildSectionHeader(
                  'RECENT CHATS',
                  Icons.history_rounded,
                  onAdd: () {
                    ref.read(chatProvider.notifier).createNewChat();
                    Navigator.pop(context);
                  },
                ),
                if (uncategorizedSessions.isEmpty)
                  _buildEmptyState('No recent chats')
                else
                  ...uncategorizedSessions.map((session) {
                    return _buildSessionTile(
                      ref,
                      session,
                      session.id == currentSessionId,
                    );
                  }).toList(),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    VoidCallback? onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          if (onAdd != null)
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: AppTheme.primaryColor,
            ),
        ],
      ),
    );
  }

  Widget _buildProjectExpansionTile(
    ChatProject project,
    List<ChatSession> sessions,
    String? currentId,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey(project.id),
        leading: const Icon(
          Icons.folder_rounded,
          color: Colors.amber,
          size: 20,
        ),
        title: Text(
          project.name,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_rounded, size: 18),
              onPressed: () {
                ref
                    .read(chatProvider.notifier)
                    .createNewChat(projectId: project.id);
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Colors.grey,
              ),
              onPressed: () =>
                  ref.read(projectsProvider.notifier).deleteProject(project.id),
            ),
          ],
        ),
        children: sessions.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.only(left: 40, bottom: 8),
                  child: Text(
                    'Empty project',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ]
            : sessions
                  .map(
                    (s) => _buildSessionTile(
                      ref,
                      s,
                      s.id == currentId,
                      isSubtile: true,
                    ),
                  )
                  .toList(),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const AILogo(size: 40),
              const SizedBox(width: 12),
              Text(
                'GeminiOps',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Intelligent Assistant',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.primaryColor.withValues(alpha: 0.6),
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(chatProvider.notifier).createNewChat();
                    Navigator.pop(ref.context);
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: IconButton(
                  onPressed: _showCreateProjectDialog,
                  icon: const Icon(
                    Icons.create_new_folder_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  tooltip: 'New Project',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(
    WidgetRef ref,
    ChatSession session,
    bool isSelected, {
    bool isSubtile = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: isSubtile ? 32 : 12,
        right: 12,
        top: 2,
        bottom: 2,
      ),
      child: ListTile(
        onTap: () {
          ref.read(currentSessionIdProvider.notifier).set(session.id);
          Navigator.pop(ref.context);
        },
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        leading: Icon(
          Icons.chat_bubble_outline_rounded,
          size: 16,
          color: isSelected ? AppTheme.primaryColor : const Color(0xFF64748B),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryColor : const Color(0xFF1E293B),
          ),
        ),
        trailing: isSelected
            ? IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 14,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  ref
                      .read(chatSessionsProvider.notifier)
                      .deleteSession(session.id);
                  if (ref.read(currentSessionIdProvider) == session.id) {
                    ref.read(currentSessionIdProvider.notifier).set(null);
                  }
                },
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          msg,
          style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            radius: 16,
            child: const Icon(
              Icons.person_outline,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Premium User',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: const Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          const Icon(Icons.settings_outlined, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
