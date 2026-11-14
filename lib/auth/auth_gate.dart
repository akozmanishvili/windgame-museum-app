import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../reports/report_repository.dart';
import '../screens/reports/reports_screen.dart';
import '../widgets/windgate_logo.dart';
import 'app_user.dart';
import 'auth_repository.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.authRepository,
    required this.reportRepository,
  });

  final AuthRepository authRepository;
  final ReportRepository reportRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<AppUser?> _authChanges = widget.authRepository
      .authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _authChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: WindgateLogo(width: 220)));
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginScreen(authRepository: widget.authRepository);
        }
        return ReportsScreen(
          authRepository: widget.authRepository,
          reportRepository: widget.reportRepository,
          user: user,
        );
      },
    );
  }
}
