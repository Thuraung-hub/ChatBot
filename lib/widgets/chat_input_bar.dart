import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../config/app_validators.dart';

class ChatInputBar extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final List<dynamic> quickReplies;
  final ValueChanged<String> onQuickReplySelected;

  const ChatInputBar({
    super.key,
    required this.formKey,
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.quickReplies,
    required this.onQuickReplySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF10182A),
        border: Border(top: BorderSide(color: Color(0xFF1D2A44))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final reply = quickReplies[index];
                  return ActionChip(
                    label: Text(
                      reply.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    avatar: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.16),
                    side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.25)),
                    onPressed: sending ? null : () => onQuickReplySelected(reply.message),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      validator: AppValidators.comment,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Ask about products...',
                        hintStyle: TextStyle(color: Color(0xFF9AA4B2)),
                        filled: true,
                        fillColor: Color(0xFF16233A),
                        prefixIcon: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Color(0xFF9AA4B2),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          borderSide:
                              BorderSide(color: AppTheme.primaryLight, width: 1.2),
                        ),
                      ),
                      onFieldSubmitted: (_) => onSend(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: sending ? null : onSend,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      minimumSize: const Size(0, 0),
                    ),
                    child: sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
