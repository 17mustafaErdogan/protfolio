import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication servisi.
/// 
/// Supabase Auth ile kullanici giris/cikis islemlerini yonetir.
/// ChangeNotifier ile state degisikliklerini dinleyicilere bildirir.
/// 
/// Kullanim:
/// ```dart
/// final authService = context.read<AuthService>();
/// await authService.signIn(email, password);
/// if (authService.isLoggedIn) { ... }
/// ```
class AuthService extends ChangeNotifier {
  /// Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Mevcut kullanici
  User? _user;
  
  /// Auth state degisiklik subscription
  StreamSubscription<AuthState>? _authSubscription;
  
  /// Yukleniyor durumu
  bool _isLoading = false;
  
  /// Hata mesaji
  String? _errorMessage;

  /// Constructor - Auth state listener'i baslatir
  AuthService() {
    _init();
  }

  /// Servisi baslatir ve auth state'i dinlemeye baslar
  void _init() {
    // Mevcut oturumu kontrol et
    _user = _supabase.auth.currentUser;
    
    // Auth state degisikliklerini dinle
    _authSubscription = _supabase.auth.onAuthStateChange.listen(
      _onAuthStateChange,
      onError: (error) {
        debugPrint('Auth state error: $error');
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Auth state degistiginde cagirilir
  void _onAuthStateChange(AuthState state) {
    final event = state.event;
    final session = state.session;
    
    debugPrint('Auth event: $event');
    
    switch (event) {
      case AuthChangeEvent.signedIn:
        _user = session?.user;
        _errorMessage = null;
        break;
      case AuthChangeEvent.signedOut:
        _user = null;
        _errorMessage = null;
        break;
      case AuthChangeEvent.userUpdated:
        _user = session?.user;
        break;
      case AuthChangeEvent.tokenRefreshed:
        _user = session?.user;
        break;
      default:
        break;
    }
    
    notifyListeners();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  /// Kullanici giris yapmis mi?
  bool get isLoggedIn => _user != null;
  
  /// Mevcut kullanici
  User? get user => _user;
  
  /// Kullanici email'i
  String? get userEmail => _user?.email;
  
  /// Yukleniyor durumu
  bool get isLoading => _isLoading;
  
  /// Hata mesaji
  String? get errorMessage => _errorMessage;

  // ============================================================
  // AUTHENTICATION METHODS
  // ============================================================

  /// Email ve sifre ile giris yap.
  /// 
  /// Basarili olursa kullanici state'i guncellenir.
  /// Hata durumunda [errorMessage] set edilir.
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user != null) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = _translateAuthError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Beklenmeyen bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cikis yap.
  /// 
  /// Oturumu sonlandirir ve kullanici state'ini temizler.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.signOut();
      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Çıkış yapılırken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sifre sifirlama emaili gonder.
  /// 
  /// [email] adresine sifre sifirlama linki gonderir.
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _translateAuthError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Şifre sıfırlama hatası: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hata mesajini temizle.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Supabase auth hatalarini Turkce'ye cevirir.
  String _translateAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Geçersiz email veya şifre.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Email adresi doğrulanmamış.';
    }
    if (message.contains('User not found')) {
      return 'Kullanıcı bulunamadı.';
    }
    if (message.contains('Too many requests')) {
      return 'Çok fazla deneme. Lütfen biraz bekleyin.';
    }
    if (message.contains('Network')) {
      return 'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.';
    }
    return message;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
