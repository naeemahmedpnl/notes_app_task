import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  AuthState _authState = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthProvider(this._authRepository) {
    _initializeAuthState();
  }

  AuthState get authState => _authState;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  void _initializeAuthState() {
    _authRepository.authStateChanges.listen((User? user) {
      _setLoadingState(true);
      if (user != null) {
        _currentUser = UserModel.fromFirebaseUser(user);
        _setAuthState(AuthState.authenticated);
      } else {
        _currentUser = null;
        _setAuthState(AuthState.unauthenticated);
      }
      _setLoadingState(false);
    }, onError: (e) {
      _setError(e.toString());
      _setAuthState(AuthState.error);
      _setLoadingState(false);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      _setLoadingState(true);
      _clearError();
      final user = await _authRepository.signInWithEmailAndPassword(
          email: email, password: password);
      _currentUser = user;
      _setAuthState(AuthState.authenticated);
    } catch (e) {
      _setError(e.toString());
      _setAuthState(AuthState.error);
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoadingState(true);
      _clearError();
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );
      await _authRepository.updateDisplayName(name);
      _currentUser = user.copyWith(displayName: name);
      _setAuthState(AuthState.authenticated);
    } catch (e) {
      _setError(e.toString());
      _setAuthState(AuthState.error);
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoadingState(true);
      _clearError();
      await _authRepository.signOut();
      _currentUser = null;
      _setAuthState(AuthState.unauthenticated);
    } catch (e) {
      _setError(e.toString());
      _setAuthState(AuthState.error);
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoadingState(true);
      _clearError();
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      _setError(e.toString());
      _setAuthState(AuthState.error);
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      _setLoadingState(true);
      _clearError();
      await _authRepository.updateDisplayName(displayName);
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(displayName: displayName);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      _setAuthState(AuthState.error);
    } finally {
      _setLoadingState(false);
    }
  }

  void clearError() => _clearError();

  bool checkAuthState() {
    final user = _authRepository.currentUser;
    if (user != null) {
      _currentUser = UserModel.fromFirebaseUser(user);
      _setAuthState(AuthState.authenticated);
      return true;
    }
    _setAuthState(AuthState.unauthenticated);
    return false;
  }

  void setLoading(bool loading) => _setLoadingState(loading);

  void _setAuthState(AuthState state) {
    if (_authState != state) {
      _authState = state;
      notifyListeners();
    }
  }

  void _setLoadingState(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
