import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

sealed class AuthSessionState {
  const AuthSessionState();
}

class AuthSessionLoading extends AuthSessionState {
  const AuthSessionLoading();
}

class AuthSessionSignedOut extends AuthSessionState {
  const AuthSessionSignedOut();
}

class AuthSessionSignedIn extends AuthSessionState {
  const AuthSessionSignedIn(this.user);
  final User user;
}

class AuthNotifier extends Notifier<AuthSessionState> {
  StreamSubscription<AuthState>? _subscription;

  @override
  AuthSessionState build() {
    final auth = Supabase.instance.client.auth;

    _subscription = auth.onAuthStateChange.listen((authState) {
      final session = authState.session;
      state = session != null
          ? AuthSessionSignedIn(session.user)
          : const AuthSessionSignedOut();
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    final currentSession = auth.currentSession;
    return currentSession != null
        ? AuthSessionSignedIn(currentSession.user)
        : const AuthSessionSignedOut();
  }

  Future<void> signIn({
    required String email,
    required String password,
    String? captchaToken,
  }) async {
    // Let AuthException propagate to the caller (UI catches it).
    // Do NOT manually set `state` here; the onAuthStateChange listener updates it.
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
      captchaToken: captchaToken,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? captchaToken,
  }) async {
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      captchaToken: captchaToken,
    );
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthSessionState>(AuthNotifier.new);
