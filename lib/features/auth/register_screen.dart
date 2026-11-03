import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../core/api_config.dart';
import '../auth/auth_provider.dart';
import 'utils/password_validator.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/password_strength_checklist.dart';
import 'widgets/turnstile_widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String _password = '';
  String? _captchaToken;
  // Bumped to force TurnstileWidget to rebuild (and fetch a fresh token)
  // after a failed attempt consumes the previous single-use token.
  int _turnstileNonce = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_captchaToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Подтвердите, что вы не робот')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await ref.read(authProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            captchaToken: _captchaToken,
          );
      if (!mounted) return;
      if (response.session == null) {
        // Supabase has "Confirm email" turned on: the account was created
        // but there is no session yet, so onAuthStateChange never fires and
        // the router has nothing to redirect on. Tell the user explicitly
        // instead of leaving them staring at an unchanged form.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Мы отправили письмо для подтверждения на вашу почту'),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      setState(() {
        _captchaToken = null;
        _turnstileNonce++;
      });
    } catch (error) {
      // Anything other than AuthException (network/CORS failure, wrong
      // Supabase URL, etc.) would otherwise be silently swallowed, leaving
      // the user staring at an unresponsive form with no feedback.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось зарегистрироваться: $error')),
      );
      setState(() {
        _captchaToken = null;
        _turnstileNonce++;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canPop = Navigator.of(context).canPop();

    return AuthScaffold(
      subtitle: 'Создайте аккаунт, чтобы сохранять прогресс',
      tagline: 'Визуализация алгоритмов и структур данных шаг за шагом',
      onBack: canPop ? () => context.pop() : null,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Регистрация',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите email';
                }
                if (!value.contains('@')) {
                  return 'Некорректный email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Пароль',
              controller: _passwordController,
              obscureText: true,
              validator: validatePasswordStrength,
              onChanged: (value) => setState(() => _password = value),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: PasswordStrengthChecklist(password: _password),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Подтвердите пароль',
              controller: _confirmPasswordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Подтвердите пароль';
                }
                if (value != _passwordController.text) {
                  return 'Пароли не совпадают';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: TurnstileWidget(
                key: ValueKey(_turnstileNonce),
                siteKey: turnstileSiteKey,
                onToken: (token) => setState(() => _captchaToken = token),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Зарегистрироваться'),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _loading ? null : () => context.go('/login'),
              child: const Text('Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
