import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/chat_message.dart';
import '../../../providers/chat_provider.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().init();
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? override]) async {
    final text = override ?? _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    await context.read<ChatProvider>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final isMobile = AppUtils.isMobile(context);

    // Scroll when messages update
    if (chat.messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile ? _buildMobileLayout(chat) : _buildDesktopLayout(chat),
    );
  }

  Widget _buildDesktopLayout(ChatProvider chat) {
    return Row(
      children: [
        // Sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: chat.sidebarOpen ? 260 : 0,
          child: chat.sidebarOpen
              ? _ChatSidebar(chat: chat)
              : const SizedBox.shrink(),
        ),
        // Main chat
        Expanded(child: _buildChatArea(chat)),
      ],
    );
  }

  Widget _buildMobileLayout(ChatProvider chat) {
    return Stack(
      children: [
        _buildChatArea(chat),
        if (chat.sidebarOpen)
          GestureDetector(
            onTap: chat.toggleSidebar,
            child: Container(color: Colors.black54),
          ),
        if (chat.sidebarOpen)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 280,
            child: _ChatSidebar(chat: chat),
          ),
      ],
    );
  }

  Widget _buildChatArea(ChatProvider chat) {
    return Column(
      children: [
        // Top bar
        _ChatTopBar(chat: chat),
        const Divider(height: 1, color: AppColors.border),

        // Messages
        Expanded(
          child: chat.messages.isEmpty
              ? _WelcomeState(onSuggestion: _send)
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: chat.messages.length + (chat.isTyping ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (chat.isTyping && i == chat.messages.length) {
                      return const _TypingIndicator();
                    }
                    final msg = chat.messages[i];
                    return _MessageBubble(message: msg, index: i);
                  },
                ),
        ),

        // Suggestion chips (show when not typing)
        if (!chat.isTyping && chat.messages.length <= 2)
          _SuggestionChips(
            suggestions: chat.suggestions,
            onTap: _send,
          ),

        // Input bar
        _InputBar(
          controller: _inputCtrl,
          onSend: _send,
          isLoading: chat.isTyping,
          onFocusChange: (_) {},
        ),
      ],
    );
  }
}

// ── Chat Top Bar ──────────────────────────────────────────────────────────
class _ChatTopBar extends StatelessWidget {
  final ChatProvider chat;
  const _ChatTopBar({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Sidebar toggle
          IconButton(
            onPressed: chat.toggleSidebar,
            icon: Icon(
              chat.sidebarOpen ? Icons.menu_open_rounded : Icons.menu_rounded,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 8),

          // AI avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Volt AI',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  )),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.accent2,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text('Online · Ready to assist',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Actions
          IconButton(
            onPressed: () {
              context.read<ChatProvider>().newSession();
            },
            icon: const Icon(Icons.add_rounded,
                color: AppColors.textMuted, size: 22),
            tooltip: 'New conversation',
          ),
        ],
      ),
    );
  }
}

// ── Chat Sidebar ──────────────────────────────────────────────────────────
class _ChatSidebar extends StatelessWidget {
  final ChatProvider chat;
  const _ChatSidebar({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Conversations',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                GestureDetector(
                  onTap: () => context.read<ChatProvider>().newSession(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.primary, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              children: chat.sessions.map((s) {
                final isActive = chat.activeSession?.id == s.id;
                return GestureDetector(
                  onTap: () => context.read<ChatProvider>().selectSession(s.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.title,
                                  style: TextStyle(
                                    color: isActive
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis),
                              Text(
                                  '${s.messageCount} messages · ${AppUtils.timeAgo(s.lastMessageAt)}',
                                  style: const TextStyle(
                                      color: AppColors.textDisabled,
                                      fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Welcome State ─────────────────────────────────────────────────────────
class _WelcomeState extends StatelessWidget {
  final void Function(String) onSuggestion;
  const _WelcomeState({required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 32),
            ).animate().scale(begin: const Offset(0.7, 0.7)).fadeIn(),
            const SizedBox(height: 20),
            const Text('Hi, I\'m Volt ⚡',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                )).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            const Text(
              'Your AI volunteer coordinator.\nAsk me anything about your program.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 14, height: 1.6),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                '📊 Generate attendance report',
                '👥 Suggest volunteer assignments',
                '📅 Show upcoming events',
                '📈 Analyze volunteer growth',
              ]
                  .asMap()
                  .entries
                  .map((e) => GestureDetector(
                        onTap: () => onSuggestion(e.value),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(e.value,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                        ),
                      )
                          .animate(
                              delay: Duration(milliseconds: 400 + e.key * 80))
                          .fadeIn()
                          .slideY(begin: 0.2))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final int index;

  const _MessageBubble({required this.message, required this.index});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!_isUser) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        _isUser ? AppColors.primary : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_isUser ? 18 : 4),
                      topRight: Radius.circular(_isUser ? 4 : 18),
                      bottomLeft: const Radius.circular(18),
                      bottomRight: const Radius.circular(18),
                    ),
                    border:
                        _isUser ? null : Border.all(color: AppColors.border),
                  ),
                  child: _isUser
                      ? Text(
                          message.content,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, height: 1.5),
                        )
                      : _MarkdownText(content: message.content),
                ),
                const SizedBox(height: 4),
                Text(
                  AppUtils.formatTime(message.timestamp),
                  style: const TextStyle(
                      color: AppColors.textDisabled, fontSize: 10),
                ),
              ],
            ),
          ),
          if (_isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.primaryLight, size: 18),
            ),
          ],
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 30 * index))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1);
  }
}

// ── Simple Markdown-style Text Renderer ──────────────────────────────────
class _MarkdownText extends StatelessWidget {
  final String content;
  const _MarkdownText({required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines.map((line) {
        // Heading ##
        if (line.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 4),
            child: Text(
              line.substring(3),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }
        // Bold **text**
        if (line.contains('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: _RichLine(line: line),
          );
        }
        // Table row |
        if (line.startsWith('|') && line.endsWith('|')) {
          if (line.contains('---')) return const SizedBox(height: 1);
          final cells =
              line.split('|').where((c) => c.trim().isNotEmpty).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: cells
                  .map((c) => Expanded(
                        child: Text(
                          c.trim(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
        }
        // Bullet -
        if (line.trimLeft().startsWith('- ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: _RichLine(line: line.trimLeft().substring(2)),
                ),
              ],
            ),
          );
        }
        // Numbered 1.
        final numMatch = RegExp(r'^(\d+)\.\s(.+)').firstMatch(line);
        if (numMatch != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(numMatch.group(1)!,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                Expanded(child: _RichLine(line: numMatch.group(2)!)),
              ],
            ),
          );
        }
        // Empty line
        if (line.trim().isEmpty) return const SizedBox(height: 6);
        // Default
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: _RichLine(line: line),
        );
      }).toList(),
    );
  }
}

class _RichLine extends StatelessWidget {
  final String line;
  const _RichLine({required this.line});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: line.substring(lastEnd, match.start),
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.5),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < line.length) {
      spans.add(TextSpan(
        text: line.substring(lastEnd),
        style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 13, height: 1.5),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.3;
                  final t = ((_ctrl.value - delay).clamp(0.0, 1.0));
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3 + t * 0.7),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

// ── Suggestion Chips ──────────────────────────────────────────────────────
class _SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onTap;

  const _SuggestionChips({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              suggestions[i],
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────
class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final Future<void> Function([String?]) onSend;
  final bool isLoading;
  final ValueChanged<bool> onFocusChange;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.isLoading,
    required this.onFocusChange,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  final _focus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(
        () => setState(() => _hasText = widget.controller.text.isNotEmpty));
    _focus.addListener(() => widget.onFocusChange(_focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Attach / Voice
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.attach_file_rounded,
                color: AppColors.textMuted, size: 22),
            tooltip: 'Attach file',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic_rounded,
                color: AppColors.textMuted, size: 22),
            tooltip: 'Voice input',
          ),

          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _focus.hasFocus
                      ? AppColors.primary.withOpacity(0.5)
                      : AppColors.border,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => widget.onSend(),
                decoration: const InputDecoration(
                  hintText: 'Ask Volt anything...',
                  hintStyle:
                      TextStyle(color: AppColors.textDisabled, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: _hasText && !widget.isLoading
                  ? AppColors.primaryGradient
                  : const LinearGradient(
                      colors: [Color(0xFF334155), Color(0xFF334155)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _hasText && !widget.isLoading
                    ? () => widget.onSend()
                    : null,
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
