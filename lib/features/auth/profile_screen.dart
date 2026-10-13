import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import 'auth_provider.dart';
import 'profile_repository.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: colors.primary,
                        child: Text(
                          _initials,
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (widget.email != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          widget.email!,
                          style: TextStyle(color: colors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(_error!, style: TextStyle(color: colors.error)),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Отображаемое имя',
                        style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _displayNameController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(hintText: 'Введите имя'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Ссылка на аватар',
                        style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _avatarUrlController,
                        decoration: const InputDecoration(hintText: 'https://...'),
                      ),
                    ],
                  ),
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
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.read(authProvider.notifier).signOut(),
                  child: const Text('Выйти'),
                ),
              ],
            ),
    );
  }
}
