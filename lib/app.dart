import 'package:flutter/material.dart';

import 'auth/auth_gate.dart';
import 'auth/auth_repository.dart';
import 'theme/app_theme.dart';

class WindgateApp extends StatelessWidget {
  const WindgateApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Windgate Staff',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: AuthGate(authRepository: authRepository),
    );
  }
}
