import 'package:flutter_test/flutter_test.dart';
import 'package:thigkdanentang/main.dart';
import 'package:thigkdanentang/screens/login_screen.dart';

void main() {
  testWidgets('Kiểm tra tải màn hình Đăng nhập Admin thành công', (WidgetTester tester) async {
    // Khởi tạo widget chính
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Kiểm tra hiển thị màn hình đăng nhập
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('HỆ THỐNG QUẢN TRỊ ADMIN'), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP ADMIN'), findsOneWidget);
  });
}
