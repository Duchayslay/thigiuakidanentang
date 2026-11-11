import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';

/// Card sản phẩm tối ưu responsive cho môn Lập trình Đa nền tảng
/// Loại bỏ hoàn toàn khoảng trắng thừa, bố cục gọn gàng, hỗ trợ cả Grid và List view.
class ClayProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(int delta)? onAdjustStock;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;
  final bool isSelectionMode;
  final bool isListView;

  const ClayProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    this.onAdjustStock,
    this.isSelected = false,
    this.onSelectChanged,
    this.isSelectionMode = false,
    this.isListView = false,
  });

  Widget _buildImage({double? width, double? height, BoxFit fit = BoxFit.cover}) {
    final imgStr = product.image.trim();
    if (imgStr.startsWith('data:image')) {
      try {
        final commaIndex = imgStr.indexOf(',');
        final base64Data = commaIndex != -1 ? imgStr.substring(commaIndex + 1) : imgStr;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => _buildPlaceholder(width, height),
        );
      } catch (e) {
        return _buildPlaceholder(width, height);
      }
    } else if (imgStr.startsWith('http://') || imgStr.startsWith('https://')) {
      return Image.network(
        imgStr,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.surfaceWarm,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => _buildPlaceholder(width, height),
      );
    }
    return _buildPlaceholder(width, height);
  }

  Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceWarm,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final isLowStock = product.soluong > 0 && product.soluong <= 5;
    final isOutOfStock = product.soluong == 0;

    // ==========================================
    // 1. DẠNG DANH SÁCH (LIST VIEW TỐI ƯU RESPONSIVE)
    // ==========================================
    if (isListView) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            if (isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primary,
                  onChanged: onSelectChanged,
                ),
              ),

            // Ảnh thu nhỏ bo góc
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _buildImage(),
              ),
            ),
            const SizedBox(width: 12),

            // Thông tin ở giữa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        currencyFormatter.format(product.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? AppColors.softRedLight
                              : isLowStock
                                  ? AppColors.warmAmberLight
                                  : AppColors.sageGreenLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOutOfStock
                              ? 'Hết hàng'
                              : isLowStock
                                  ? 'Sắp hết (${product.soluong})'
                                  : 'Tồn: ${product.soluong}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isOutOfStock
                                ? AppColors.softRed
                                : isLowStock
                                    ? AppColors.warmAmber
                                    : AppColors.sageGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Thao tác bên phải: Tăng/giảm kho + Sửa/Xóa
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCompactStockTweak(),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Sửa',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.softRed),
                  tooltip: 'Xóa',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      );
    }

    // ==========================================
    // 2. DẠNG LƯỚI (GRID VIEW TỐI ƯU KHOẢNG TRẮNG)
    // ==========================================
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ảnh sản phẩm chiếm tỉ lệ hợp lý (flex: 12)
              Expanded(
                flex: 12,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildImage(),
                      ),
                    ),
                    // Badge số lượng tồn kho
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? AppColors.softRed
                              : isLowStock
                                  ? AppColors.warmAmber
                                  : AppColors.sageGreen,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
                          ],
                        ),
                        child: Text(
                          isOutOfStock ? 'Hết hàng' : 'SL: ${product.soluong}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Thông tin + Thao tác gọn gàng không khoảng trắng thừa (flex: 10)
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tên sản phẩm
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Giá sản phẩm
                      Text(
                        currencyFormatter.format(product.price),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),

                      // Hàng Thao tác gộp: Tăng/giảm kho + Nút Sửa, Xóa
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tăng/giảm kho nhanh
                          _buildCompactStockTweak(),

                          // Nút Sửa & Xóa
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: onEdit,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceWarm,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.edit_outlined, size: 14, color: AppColors.textPrimary),
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: onDelete,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.softRedLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.delete_outline, size: 14, color: AppColors.softRed),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Checkbox khi ở chế độ chọn nhiều
          if (isSelectionMode)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: onSelectChanged,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Khối tăng/giảm kho thu gọn [-] 12 [+]
  Widget _buildCompactStockTweak() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStockBtn(
            icon: Icons.remove,
            enabled: product.soluong > 0,
            onTap: () => onAdjustStock?.call(-1),
            tooltip: 'Giảm 1',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              '${product.soluong}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildStockBtn(
            icon: Icons.add,
            enabled: true,
            onTap: () => onAdjustStock?.call(1),
            tooltip: 'Tăng 1',
          ),
        ],
      ),
    );
  }

  Widget _buildStockBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
            boxShadow: enabled ? const [BoxShadow(color: Colors.black12, blurRadius: 1)] : null,
          ),
          child: Icon(
            icon,
            size: 12,
            color: enabled ? AppColors.textPrimary : Colors.grey,
          ),
        ),
      ),
    );
  }
}
