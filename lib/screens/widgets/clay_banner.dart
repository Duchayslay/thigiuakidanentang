import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Banner chào mừng và lọc nhanh danh mục theo phong cách ấm áp như ảnh mẫu
class ClayBanner extends StatelessWidget {
  final int totalProducts;
  final int totalStock;
  final String activeTag;
  final ValueChanged<String> onTagSelected;

  const ClayBanner({
    super.key,
    required this.totalProducts,
    required this.totalStock,
    required this.activeTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 650;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ Banner chính
            Expanded(
              child: Container(
                padding: EdgeInsets.all(isCompact ? 16 : 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryGradientStart,
                      AppColors.primaryGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Phân hệ Quản trị Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Quản Lý Kho Hàng',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 20 : 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Xin chào Admin! Hiện có $totalProducts mặt hàng ($totalStock sản phẩm trong kho)',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: isCompact ? 12 : 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Icon minh họa phong cách Squircle
                    Container(
                      width: isCompact ? 60 : 80,
                      height: isCompact ? 60 : 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: isCompact ? 32 : 44,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Dãy icon tag dọc trên màn hình lớn (như trong ảnh mẫu)
            if (!isCompact) ...[
              const SizedBox(width: 14),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTagPill('Tất cả', Icons.apps_rounded),
                  const SizedBox(height: 8),
                  _buildTagPill('Điện thoại', Icons.smartphone_rounded),
                  const SizedBox(height: 8),
                  _buildTagPill('Laptop', Icons.laptop_mac_rounded),
                  const SizedBox(height: 8),
                  _buildTagPill('Âm thanh', Icons.headphones_rounded),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTagPill(String tag, IconData icon) {
    final isSelected = activeTag == tag;

    return Tooltip(
      message: tag,
      child: InkWell(
        onTap: () => onTagSelected(tag),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceWarm,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
