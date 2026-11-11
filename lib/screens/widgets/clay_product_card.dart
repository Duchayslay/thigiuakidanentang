import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';

/// Card sản phẩm thiết kế theo phong cách Terracotta / Clay Squircle
/// Hỗ trợ đầy đủ 4 trường: name, price, soluong, image
/// Tích hợp tính năng nâng cao: Nút +/- điều chỉnh tồn kho nhanh 1-chạm
class ClayProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(int delta)? onAdjustStock;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;
  final bool isSelectionMode;

  const ClayProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    this.onAdjustStock,
    this.isSelected = false,
    this.onSelectChanged,
    this.isSelectionMode = false,
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
                width: 20,
                height: 20,
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
        child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final isLowStock = product.soluong > 0 && product.soluong <= 5;
    final isOutOfStock = product.soluong == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ảnh sản phẩm bo góc lớn
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _buildImage(),
                      ),
                    ),
                    // Badge số lượng tồn kho
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? AppColors.softRed
                              : isLowStock
                                  ? AppColors.warmAmber
                                  : AppColors.sageGreen,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Text(
                          isOutOfStock ? 'Hết hàng' : 'SL: ${product.soluong}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Thông tin: Tên, Giá, Nút điều chỉnh kho nhanh
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(product.price),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      // Tính năng nâng cao: Bộ nút tăng / giảm kho nhanh 1 chạm (+ / -)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWarm.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Kho nhanh:',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildStockBtn(
                                  icon: Icons.remove,
                                  enabled: product.soluong > 0,
                                  onTap: () => onAdjustStock?.call(-1),
                                  tooltip: 'Giảm 1 số lượng',
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '${product.soluong}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                _buildStockBtn(
                                  icon: Icons.add,
                                  enabled: true,
                                  onTap: () => onAdjustStock?.call(1),
                                  tooltip: 'Tăng 1 số lượng',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Hàng nút Sửa / Xóa
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWarm,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined, size: 14, color: AppColors.textPrimary),
                                  SizedBox(width: 4),
                                  Text(
                                    'Sửa',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.softRedLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete_outline, size: 14, color: AppColors.softRed),
                                  SizedBox(width: 4),
                                  Text(
                                    'Xóa',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.softRed),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Checkbox chọn sản phẩm khi ở chế độ chọn hàng loạt
          if (isSelectionMode)
            Positioned(
              top: 14,
              left: 14,
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            boxShadow: enabled ? const [BoxShadow(color: Colors.black12, blurRadius: 2)] : null,
          ),
          child: Icon(
            icon,
            size: 14,
            color: enabled ? AppColors.textPrimary : Colors.grey,
          ),
        ),
      ),
    );
  }
}
