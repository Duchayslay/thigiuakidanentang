import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';

/// Khối thống kê tổng quan (Dashboard Stats)
class StatsOverview extends StatelessWidget {
  final List<Product> products;

  const StatsOverview({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.compactCurrency(locale: 'vi_VN', symbol: '₫');

    int totalItems = products.length;
    int totalQuantity = products.fold<int>(0, (sum, p) => sum + p.soluong);
    double totalInventoryValue = products.fold<double>(0.0, (sum, p) => sum + (p.price * p.soluong));
    int lowStockCount = products.where((p) => p.soluong <= 5).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: isSmall
              ? Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Tổng loại SP', '$totalItems', Icons.category, Colors.indigo)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('Tổng tồn kho', '$totalQuantity', Icons.inventory, Colors.teal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Giá trị kho', currencyFormatter.format(totalInventoryValue), Icons.payments, Colors.deepPurple)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('Sắp hết hàng', '$lowStockCount', Icons.warning_amber, Colors.orange)),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildStatCard('Tổng loại SP', '$totalItems', Icons.category, Colors.indigo)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Tổng tồn kho', '$totalQuantity', Icons.inventory, Colors.teal)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Giá trị kho', currencyFormatter.format(totalInventoryValue), Icons.payments, Colors.deepPurple)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Sắp hết hàng (SL <= 5)', '$lowStockCount', Icons.warning_amber, Colors.orange)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
