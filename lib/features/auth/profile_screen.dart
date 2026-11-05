import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import 'auth_provider.dart';
import 'profile_repository.dart';
import 'widgets/auth_text_field.dart';

/// Shows the signed-in user's profile: display name, avatar URL and a
/// sign-out action. The router is expected to keep unauthenticated users
/// away from this screen, but the widget still guards defensively against
/// [AuthSessionLoading]/[AuthSessionSignedOut] states.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is AuthSessionSignedIn) {
      return _ProfileBody(userId: authState.user.id, email: authState.user.email);
    }

    // Defensive fallback for AuthSessionLoading / AuthSessionSignedOut.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ProfileBody extends ConsumerStatefulWidget {
  const _ProfileBody({required this.userId, required this.email});

  final String userId;
  final String? email;

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  final ProfileRepository _repository = ProfileRepository();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await _repository.fetchProfile(widget.userId);
      _displayNameController.text = (profile?['display_name'] as String?) ?? '';
      _avatarUrlController.text = (profile?['avatar_url'] as String?) ?? '';
    } catch (e) {
      _error = 'Не удалось загрузить профиль: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await _repository.upsertProfile(
        userId: widget.userId,
        displayName: _displayNameController.text.trim(),
        avatarUrl: _avatarUrlController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль сохранён')),
        );
      }
    } catch (e) {
      _error = 'Не удалось сохранить профиль: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String get _initials {
    final name = _displayNameController.text.trim();
    if (name.isNotEmpty) return name[0].toUpperCase();
    final email = widget.email ?? '';
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayName = _displayNameController.text.trim();
    final avatarUrl = _avatarUrlController.text.trim();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: colors.primary,
                            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                            onBackgroundImageError: avatarUrl.isNotEmpty ? (_, _) {} : null,
                            child: avatarUrl.isNotEmpty
                                ? null
                                : Text(
                                    _initials,
                                    style: TextStyle(
                                      color: colors.onPrimary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            displayName.isNotEmpty ? displayName : (widget.email ?? ''),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (displayName.isNotEmpty && widget.email != null) ...[
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              widget.email!,
                              style: TextStyle(color: colors.textSecondary, fontSize: 14),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        _ContinueToAppCard(onTap: () => context.go('/')),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          _ErrorBanner(message: _error!),
                        ],
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            border: Border.all(color: colors.border),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthTextField(
                                label: 'Отображаемое имя',
                                controller: _displayNameController,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                              AuthTextField(
                                label: 'Ссылка на аватар',
                                controller: _avatarUrlController,
                                keyboardType: TextInputType.url,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: _isSaving ? null : _save,
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Сохранить'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Prominent next-step action after landing on the profile screen — reads
/// as a continuation of the auth flow (sign up/in → profile → the app)
/// rather than just another list item, since it's the single most likely
/// action a freshly-signed-in visitor wants to take.
class _ContinueToAppCard extends StatelessWidget {
  const _ContinueToAppCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.bar_chart_rounded, color: colors.onPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Перейти к алгоритмам',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Визуализация алгоритмов и структур данных',
                      style: TextStyle(
                        color: colors.onPrimary.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: colors.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: colors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
