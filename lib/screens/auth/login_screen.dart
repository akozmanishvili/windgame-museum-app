import 'package:flutter/material.dart';

import '../../auth/auth_config.dart';
import '../../auth/auth_repository.dart';
import '../../auth/validators.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/message_banner.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/windgate_logo.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  static const emailFieldKey = Key('login_email');
  static const passwordFieldKey = Key('login_password');
  static const loginButtonKey = Key('login_button');
  static const signUpButtonKey = Key('login_go_to_sign_up');

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await widget.authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openSignUp() {
    setState(() => _errorMessage = null);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SignUpScreen(authRepository: widget.authRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AuthLayout(
        children: [
          const SizedBox(height: 8),
          const Center(child: WindgateLogo(width: 260)),
          const SizedBox(height: 48),
          Text('Staff log in', style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Use your museum staff email '
            '(${AuthConfig.allowedDomainsLabel}).',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: LoginScreen.emailFieldKey,
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    validator: Validators.staffEmail,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    key: LoginScreen.passwordFieldKey,
                    controller: _passwordController,
                    enabled: !_isLoading,
                    validator: Validators.password,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            MessageBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],
          PrimaryButton(
            key: LoginScreen.loginButtonKey,
            label: 'LOG IN',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 32),
          Text(
            'New staff member?',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            key: LoginScreen.signUpButtonKey,
            label: 'SIGN UP',
            onPressed: _isLoading ? null : _openSignUp,
          ),
        ],
      ),
    );
  }
}
