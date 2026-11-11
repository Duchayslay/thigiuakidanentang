import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Thanh điều hướng Sidebar phong cách Terracotta Clay (như trong ảnh mẫu)
class ClaySidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onLogout;
  final bool isFirebaseOnline;

  const ClaySidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onLogout,
    required this.isFirebaseOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Top logo/menu icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 36),

          // Danh mục icon điều hướng chính
          _buildNavIcon(0, Icons.home_rounded, 'Kho hàng'),
          const SizedBox(height: 18),
          _buildNavIcon(1, Icons.analytics_outlined, 'Thống kê'),
          const SizedBox(height: 18),
          _buildNavIcon(2, Icons.cloud_done_outlined, isFirebaseOnline ? 'Firebase Online' : 'Firebase Local'),
          const SizedBox(height: 18),
          _buildNavIcon(3, Icons.person_outline_rounded, 'Tài khoản'),

          const Spacer(),

          // Nút Đăng xuất ở dưới cùng
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 22),
            tooltip: 'Đăng xuất',
            onPressed: onLogout,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon, String tooltip) {
    final isSelected = selectedIndex == index;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))]
                : null,
          ),
          child: Icon(
            icon,
            color: isSelected ? AppColors.sidebarBg : Colors.white.withValues(alpha: 0.85),
            size: 24,
          ),
        ),
      ),
    );
  }
}
