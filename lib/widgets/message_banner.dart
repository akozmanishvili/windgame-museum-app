import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum MessageType { error, info, success }

class MessageBanner extends StatelessWidget {
  const MessageBanner({
    super.key,
    required this.message,
    this.type = MessageType.error,
  });

  final String message;
  final MessageType type;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (type) {
      MessageType.error => (AppColors.error, Icons.error_outline),
      MessageType.info => (AppColors.orange, Icons.info_outline),
      MessageType.success => (AppColors.orange, Icons.check_circle_outline),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.6)),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.white, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
