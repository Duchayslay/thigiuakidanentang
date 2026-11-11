import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Panel bên phải trên màn hình Desktop/Web (mô phỏng bảng bên phải trong ảnh mẫu)
class ClayRightPanel extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onEditProduct;
  final Function(Product, int) onAdjustStock;
  final VoidCallback onSeedData;

  const ClayRightPanel({
    super.key,
    required this.products,
    required this.onEditProduct,
    required this.onAdjustStock,
    required this.onSeedData,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.compactCurrency(locale: 'vi_VN', symbol: '₫');
    final auth = AuthService();

    // Sắp xếp sản phẩm có giá trị tồn kho cao nhất (price * soluong)
    final sortedByValue = List<Product>.from(products)
      ..sort((a, b) => (b.price * b.soluong).compareTo(a.price * a.soluong));
    final topProducts = sortedByValue.take(3).toList();

    // Các sản phẩm sắp hết hàng (soluong <= 5)
    final lowStockProducts = products.where((p) => p.soluong <= 5).take(3).toList();

    return Container(
      width: 290,
      margin: const EdgeInsets.fromLTRB(8, 16, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Khối thông tin Admin (như góc trên phải ảnh mẫu)
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Manager',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        auth.userEmail.isNotEmpty ? auth.userEmail : 'admin@store.com',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Quản trị kho',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(color: AppColors.surfaceWarm, height: 1),
            const SizedBox(height: 18),

            // 2. Danh sách "Top Giá Trị Kho" (Tương tự October Holidays trong ảnh mẫu)
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Giá Trị Kho',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(Icons.trending_up, size: 18, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 12),
            if (topProducts.isEmpty)
              const Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey, fontSize: 12))
            else
              ...topProducts.map((p) => _buildTopProductItem(p, currencyFormatter)),

            const SizedBox(height: 20),
            const Divider(color: AppColors.surfaceWarm, height: 1),
            const SizedBox(height: 18),

            // 3. Danh sách "Cảnh Báo Hết Hàng" (Party planning trong ảnh mẫu)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cần Nhập Thêm Hàng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.softRedLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${lowStockProducts.length}',
                    style: const TextStyle(color: AppColors.softRed, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lowStockProducts.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sageGreenLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.sageGreen, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kho hàng dồi dào, không có mặt hàng thiếu hụt!',
                        style: TextStyle(fontSize: 11, color: AppColors.sageGreen, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...lowStockProducts.map((p) => _buildLowStockItem(p)),

            const SizedBox(height: 24),

            // Nút Nạp dữ liệu mẫu nhanh
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.dataset_outlined, size: 16),
                label: const Text('Nạp 8 sản phẩm mẫu'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onSeedData,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductItem(Product product, NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildSmallImage(product.image, 38, 38),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Tổng: ${formatter.format(product.price * product.soluong)} (${product.soluong} SP)',
                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => onEditProduct(product),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Sửa', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.softRedLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildSmallImage(product.image, 36, 36),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.soluong == 0 ? 'Đã hết hàng (0)' : 'Chỉ còn ${product.soluong} cái',
                  style: const TextStyle(fontSize: 11, color: AppColors.softRed, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Nút tăng nhanh tồn kho
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 22),
            tooltip: 'Nhập thêm 5 cái',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => onAdjustStock(product, 5),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallImage(String image, double width, double height) {
    if (image.startsWith('data:image')) {
      try {
        final commaIndex = image.indexOf(',');
        final base64Data = commaIndex != -1 ? image.substring(commaIndex + 1) : image;
        return Image.memory(base64Decode(base64Data), width: width, height: height, fit: BoxFit.cover);
      } catch (_) {}
    } else if (image.startsWith('http')) {
      return Image.network(image, width: width, height: height, fit: BoxFit.cover, errorBuilder: (_, _, _) => _errorSmall());
    }
    return _errorSmall();
  }

  Widget _errorSmall() {
    return Container(
      width: 36,
      height: 36,
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, size: 18, color: Colors.grey),
    );
  }
}
