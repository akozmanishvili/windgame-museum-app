import 'package:flutter/material.dart';

import '../../auth/app_user.dart';
import '../../auth/auth_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/windgate_logo.dart';

/// Page 2: Search.
class SearchScreen extends StatelessWidget {
  const SearchScreen({
    super.key,
    required this.authRepository,
    required this.user,
  });

  final AuthRepository authRepository;
  final AppUser user;

  static const logoutButtonKey = Key('search_logout');

  Future<void> _logOut(BuildContext context) async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    try {
      await authRepository.signOut();
    } on AuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: const WindgateLogo(
          variant: WindgateLogoVariant.horizontal,
          height: 22,
        ),
        actions: [
          TextButton.icon(
            key: logoutButtonKey,
            onPressed: () => _logOut(context),
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('Log out'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome, ${user.greetingName}',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Search is coming next.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
