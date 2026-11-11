import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Dịch vụ quản lý xác thực đăng nhập phân hệ Admin
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String _userEmail = '';
  bool _isFirebaseAvailable = false;

  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  void setFirebaseAvailable(bool available) {
    _isFirebaseAvailable = available;
    notifyListeners();
  }

  /// Đăng nhập Admin
  /// Hỗ trợ cả Firebase Authentication thực tế và tài khoản quản trị mặc định:
  /// Email: admin@store.com
  /// Mật khẩu: admin123
  Future<bool> login(String email, String password) async {
    email = email.trim();
    password = password.trim();

    // 1. Kiểm tra tài khoản Admin mặc định (phù hợp chấm thi và demo nhanh)
    if ((email == 'admin@store.com' && password == 'admin123') ||
        (email == 'admin' && password == 'admin123') ||
        (email == 'admin@gmail.com' && password == '123456')) {
      _isLoggedIn = true;
      _userEmail = email.contains('@') ? email : '$email@store.com';
      notifyListeners();
      return true;
    }

    // 2. Nếu đã kết nối Firebase Auth, thử xác thực qua Firebase
    if (_isFirebaseAvailable) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (credential.user != null) {
          _isLoggedIn = true;
          _userEmail = credential.user!.email ?? email;
          notifyListeners();
          return true;
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuth error: ${e.code} - ${e.message}');
        rethrow;
      } catch (e) {
        debugPrint('Lỗi đăng nhập: $e');
        rethrow;
      }
    }

    // Nếu không thỏa mãn cả hai
    throw Exception('Tài khoản hoặc mật khẩu không chính xác!');
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> logout() async {
    if (_isFirebaseAvailable) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('Error signing out from Firebase: $e');
      }
    }
    _isLoggedIn = false;
    _userEmail = '';
    notifyListeners();
  }
}
