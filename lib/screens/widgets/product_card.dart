import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';

/// Card hiển thị thông tin sản phẩm
/// Đảm bảo hiển thị đầy đủ 4 trường: name, price, soluong, image
/// Có các nút Thao tác: Sửa, Xóa
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isGridView;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    this.isGridView = true,
  });

  /// Hàm render ảnh hỗ trợ cả URL mạng và chuỗi Base64
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
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
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
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 36),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final isLowStock = product.soluong <= 5;
    final isOutOfStock = product.soluong == 0;

    if (!isGridView) {
      // Dạng Danh sách (List / Table view)
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(width: 80, height: 80),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormatter.format(product.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? Colors.red.shade50
                                : isLowStock
                                    ? Colors.orange.shade50
                                    : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isOutOfStock
                                  ? Colors.red.shade300
                                  : isLowStock
                                      ? Colors.orange.shade300
                                      : Colors.green.shade300,
                            ),
                          ),
                          child: Text(
                            isOutOfStock
                                ? 'Hết hàng (SL: 0)'
                                : 'Số lượng: ${product.soluong}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isOutOfStock
                                  ? Colors.red.shade700
                                  : isLowStock
                                      ? Colors.orange.shade800
                                      : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    tooltip: 'Sửa sản phẩm',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Xóa sản phẩm',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Dạng Lưới (Grid view)
    return Card(
      elevation: 2.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần Hình ảnh
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(),
                // Badge tình trạng kho hàng
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? Colors.red.withValues(alpha: 0.9)
                          : isLowStock
                              ? Colors.orange.withValues(alpha: 0.9)
                              : Colors.green.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'SL: ${product.soluong}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Phần Thông tin
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(product.price),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  // Hàng nút thao tác Sửa / Xóa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, size: 14, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('Sửa', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete, size: 14, color: Colors.red),
                              SizedBox(width: 4),
                              Text('Xóa', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
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
    );
  }
}
