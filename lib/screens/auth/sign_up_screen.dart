import 'package:flutter/material.dart';

import '../../auth/auth_config.dart';
import '../../auth/auth_repository.dart';
import '../../auth/validators.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/message_banner.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';

/// Page 1 (sign up): new staff member creates an account.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  static const nameFieldKey = Key('sign_up_name');
  static const emailFieldKey = Key('sign_up_email');
  static const passwordFieldKey = Key('sign_up_password');
  static const confirmPasswordFieldKey = Key('sign_up_confirm_password');
  static const submitButtonKey = Key('sign_up_submit');

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await widget.authRepository.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: AuthLayout(
        children: [
          Text('Join the staff app', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Only museum staff can sign up.',
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
                    key: SignUpScreen.nameFieldKey,
                    controller: _nameController,
                    enabled: !_isLoading,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: Validators.name,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: SignUpScreen.emailFieldKey,
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    validator: Validators.staffEmail,
                    decoration: InputDecoration(
                      labelText: 'Staff email',
                      helperText:
                          'Must end in ${AuthConfig.allowedDomainsLabel}',
                      prefixIcon: const Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    key: SignUpScreen.passwordFieldKey,
                    controller: _passwordController,
                    enabled: !_isLoading,
                    helperText:
                        'At least ${AuthConfig.minPasswordLength} characters',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    key: SignUpScreen.confirmPasswordFieldKey,
                    controller: _confirmController,
                    enabled: !_isLoading,
                    label: 'Confirm password',
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
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
            key: SignUpScreen.submitButtonKey,
            label: 'CREATE ACCOUNT',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
