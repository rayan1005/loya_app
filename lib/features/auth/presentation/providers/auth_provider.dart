import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  initial,
  loading,
  codeSent,
  verifying,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? phoneNumber;
  final String? verificationId;
  final String? errorMessage;
  final int? resendToken;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.phoneNumber,
    this.verificationId,
    this.errorMessage,
    this.resendToken,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? phoneNumber,
    String? verificationId,
    String? errorMessage,
    int? resendToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: errorMessage ?? this.errorMessage,
      resendToken: resendToken ?? this.resendToken,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;

  AuthNotifier(this._auth) : super(const AuthState()) {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      phoneNumber: phoneNumber,
      errorMessage: null,
    );

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on Android
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: _getErrorMessage(e.code),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(
            status: AuthStatus.codeSent,
            verificationId: verificationId,
            resendToken: resendToken,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout
        },
        forceResendingToken: state.resendToken,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'error_sending_otp',
      );
    }
  }

  Future<void> verifyOtp(String code) async {
    if (state.verificationId == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'error_no_verification',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.verifying);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: code,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'error_invalid_otp',
      );
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userCredential.user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'error_sign_in',
      );
    }
  }

  Future<void> resendOtp() async {
    if (state.phoneNumber != null) {
      await sendOtp(state.phoneNumber!);
    }
  }

  void reset() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'error_invalid_phone';
      case 'too-many-requests':
        return 'error_too_many_requests';
      case 'quota-exceeded':
        return 'error_quota_exceeded';
      default:
        return 'error_unknown';
    }
  }
}

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthNotifier(auth);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
