import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for Firebase Auth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider for auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Provider for auth service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

/// Auth state for UI
enum AuthStatus {
  initial,
  loading,
  codeSent,
  verifying,
  authenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? verificationId;
  final String? phoneNumber;
  final String? errorMessage;
  final int? resendToken;

  const AuthState({
    this.status = AuthStatus.initial,
    this.verificationId,
    this.phoneNumber,
    this.errorMessage,
    this.resendToken,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? verificationId,
    String? phoneNumber,
    String? errorMessage,
    int? resendToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage,
      resendToken: resendToken ?? this.resendToken,
    );
  }
}

/// Auth state notifier for managing phone auth flow
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  /// Send OTP to phone number
  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      phoneNumber: phoneNumber,
      errorMessage: null,
    );

    try {
      await _authService.sendOtp(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          state = state.copyWith(
            status: AuthStatus.codeSent,
            verificationId: verificationId,
            resendToken: resendToken,
          );
        },
        onError: (error) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: _getErrorMessage(error),
          );
        },
        onAutoVerified: () {
          state = state.copyWith(status: AuthStatus.authenticated);
        },
        resendToken: state.resendToken,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Verify OTP code
  Future<bool> verifyOtp(String code) async {
    if (state.verificationId == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No verification ID found',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.verifying,
      errorMessage: null,
    );

    try {
      final success = await _authService.verifyOtp(
        verificationId: state.verificationId!,
        code: code,
      );

      if (success) {
        state = state.copyWith(status: AuthStatus.authenticated);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.codeSent,
          errorMessage: 'Invalid code',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.codeSent,
        errorMessage: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (state.phoneNumber == null) return;
    await sendOtp(state.phoneNumber!);
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState();
  }

  /// Reset state
  void reset() {
    state = const AuthState();
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'error_invalid_phone';
        case 'invalid-verification-code':
          return 'error_otp_invalid';
        case 'session-expired':
          return 'error_otp_expired';
        case 'too-many-requests':
          return 'Too many requests. Try again later.';
        case 'network-request-failed':
          return 'error_network';
        default:
          return error.message ?? 'error_unknown';
      }
    }
    return error.toString();
  }
}

/// Auth service for Firebase Phone Auth
class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send OTP to phone number
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(dynamic error) onError,
    required Function() onAutoVerified,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verify on Android
        try {
          await _auth.signInWithCredential(credential);
          onAutoVerified();
        } catch (e) {
          onError(e);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e);
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        onCodeSent(verificationId, forceResendingToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Timeout, user needs to enter code manually
      },
    );
  }

  /// Verify OTP code
  Future<bool> verifyOtp({
    required String verificationId,
    required String code,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user != null;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get ID token for API calls
  Future<String?> getIdToken() async {
    return await currentUser?.getIdToken();
  }
}
