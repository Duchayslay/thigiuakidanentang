import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';

/// Màn hình / Tab Thống kê & Phân tích chuyên sâu (Chức năng nâng cao)
class AnalyticsView extends StatelessWidget {
  final List<Product> products;

  const AnalyticsView({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    int totalItems = products.length;
    int totalStock = products.fold<int>(0, (sum, p) => sum + p.soluong);
    double totalInventoryValue = products.fold<double>(0.0, (sum, p) => sum + (p.price * p.soluong));

    // Phân loại theo tầm giá
    int tierBudget = products.where((p) => p.price < 5000000).length;
    int tierMid = products.where((p) => p.price >= 5000000 && p.price <= 20000000).length;
    int tierHigh = products.where((p) => p.price > 20000000).length;

    // Tình trạng kho
    int inStock = products.where((p) => p.soluong > 5).length;
    int lowStock = products.where((p) => p.soluong > 0 && p.soluong <= 5).length;
    int outOfStock = products.where((p) => p.soluong == 0).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          const Text(
            'Báo Cáo & Thống Kê Phân Hệ Kho',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Phân tích tự động dựa trên 4 trường dữ liệu: name, price, soluong, image',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // 1. Thẻ 3 chỉ số chính
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Tổng mặt hàng',
                  '$totalItems loại',
                  Icons.category_rounded,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  'Tổng tồn kho',
                  '$totalStock SP',
                  Icons.inventory_rounded,
                  AppColors.sageGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  'Giá trị kho hàng',
                  currencyFormatter.format(totalInventoryValue),
                  Icons.account_balance_wallet_rounded,
                  AppColors.sidebarBg,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Biểu đồ thanh: Tình trạng kho hàng
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tỷ Lệ Tình Trạng Kho Hàng',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBarProgress(
                  label: 'Còn dồi dào (> 5 cái)',
                  count: inStock,
                  total: totalItems,
                  color: AppColors.sageGreen,
                ),
                const SizedBox(height: 12),
                _buildBarProgress(
                  label: 'Sắp hết hàng (1 - 5 cái)',
                  count: lowStock,
                  total: totalItems,
                  color: AppColors.warmAmber,
                ),
                const SizedBox(height: 12),
                _buildBarProgress(
                  label: 'Đã hết hàng (0 cái)',
                  count: outOfStock,
                  total: totalItems,
                  color: AppColors.softRed,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Biểu đồ phân bổ theo phân khúc giá
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Phân Khúc Giá Sản Phẩm',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBarProgress(
                  label: 'Phổ thông (< 5.000.000 ₫)',
                  count: tierBudget,
                  total: totalItems,
                  color: AppColors.badgeTeal,
                ),
                const SizedBox(height: 12),
                _buildBarProgress(
                  label: 'Trung cấp (5 - 20 triệu ₫)',
                  count: tierMid,
                  total: totalItems,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _buildBarProgress(
                  label: 'Cao cấp (> 20 triệu ₫)',
                  count: tierHigh,
                  total: totalItems,
                  color: AppColors.primaryDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBarProgress({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final double percent = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('$count SP (${(percent * 100).toStringAsFixed(0)}%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: AppColors.surfaceWarm,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
