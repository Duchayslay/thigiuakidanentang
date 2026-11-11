import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseReady = false;
  try {
    // Khởi tạo Firebase theo cấu hình từ firebase_options.dart
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
    debugPrint('>>> Firebase đã khởi tạo thành công!');
  } catch (e) {
    debugPrint('>>> Không thể kết nối Firebase (hoặc chưa thay API Key thực): $e');
    debugPrint('>>> Ứng dụng sẽ hoạt động ở chế độ Demo CSDL với dữ liệu mẫu chuẩn.');
    firebaseReady = false;
  }

  // Cập nhật trạng thái Firebase cho các dịch vụ
  AuthService().setFirebaseAvailable(firebaseReady);
  ProductService().setFirebaseAvailable(firebaseReady);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Sản Phẩm Admin - Thi GK Đa Nền Tảng',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: ListenableBuilder(
        listenable: AuthService(),
        builder: (context, _) {
          if (AuthService().isLoggedIn) {
            return const AdminDashboardScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
