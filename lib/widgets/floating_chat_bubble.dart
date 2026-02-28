// lib/widgets/floating_chat_bubble.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/typing_indicator.dart';
class FloatingChatBubble extends StatefulWidget {
  const FloatingChatBubble({super.key});
  @override
  State<FloatingChatBubble> createState() => _FloatingChatBubbleState();
}

class _FloatingChatBubbleState extends State<FloatingChatBubble>
    with SingleTickerProviderStateMixin {
  bool   _isOpen = false;
  final  _ctrl   = TextEditingController();
  late final AnimationController _animCtrl;
  late final Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _animCtrl.forward() : _animCtrl.reverse();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    context.read<ChatProvider>().send(text);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Popup mini chat
        if (_isOpen)
          Positioned(
            right: 72, bottom: 0,
            child: ScaleTransition(
              scale: _scaleAnim,
              alignment: Alignment.bottomRight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    width: 280, height: 380,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color:      Colors.black.withOpacity(0.4),
                          blurRadius: 30,
                          offset:     const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Mini header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: AppColors.border)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDk
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.auto_awesome_rounded,
                                    color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('AI Assistant',
                                        style: GoogleFonts.inter(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        )),
                                    Row(
                                      children: [
                                        Container(
                                          width: 5, height: 5,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text('Online',
                                            style: GoogleFonts.inter(
                                              color: AppColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _toggle,
                                child: const Icon(Icons.close_rounded,
                                    color: AppColors.textMuted, size: 18),
                              ),
                            ],
                          ),
                        ),

                        // Messages
                        Expanded(
                          child: Consumer<ChatProvider>(
                            builder: (_, chat, __) {
                              final msgs = chat.messages.reversed.take(8).toList().reversed.toList();
                              return ListView.builder(
                                padding: const EdgeInsets.all(10),
                                itemCount: msgs.length + (chat.isTyping ? 1 : 0),
                                itemBuilder: (_, i) {
                                  if (i == msgs.length && chat.isTyping) {
                                    return  Padding(
                                      padding: EdgeInsets.only(bottom: 6),
                                      child: Row(children: [TypingIndicator()]),
                                    );
                                  }
                                  final m = msgs[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      mainAxisAlignment: m.isUser
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              gradient: m.isUser
                                                  ? const LinearGradient(
                                                      colors: [
                                                        AppColors.primary,
                                                        AppColors.primaryDk
                                                      ],
                                                    )
                                                  : null,
                                              color: m.isUser
                                                  ? null
                                                  : AppColors.bg,
                                              borderRadius: BorderRadius.circular(12),
                                              border: m.isUser
                                                  ? null
                                                  : Border.all(
                                                      color: AppColors.border),
                                            ),
                                            child: Text(m.text,
                                                style: GoogleFonts.inter(
                                                  color: AppColors.text,
                                                  fontSize: 12,
                                                  height: 1.4,
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        // Input
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(color: AppColors.border)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _ctrl,
                                  onSubmitted: (_) => _send(),
                                  style: GoogleFonts.inter(
                                      color: AppColors.text, fontSize: 12),
                                  decoration: const InputDecoration(
                                    hintText: 'Ask something…',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                  ),
                                  textInputAction: TextInputAction.send,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _send,
                                child: Container(
                                  width: 34, height: 34,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDk
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.send_rounded,
                                      color: Colors.white, size: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 200.ms),
          ),

        // FAB bubble
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDk],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:      AppColors.primary.withOpacity(0.45),
                  blurRadius: _isOpen ? 20 : 14,
                  offset:     const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              _isOpen
                  ? Icons.close_rounded
                  : Icons.auto_awesome_rounded,
              color: Colors.white,
              size:  24,
            ),
          ),
        ),
      ],
    );
  }
}
