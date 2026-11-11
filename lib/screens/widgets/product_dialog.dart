import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product_model.dart';
import '../../services/sample_data.dart';

/// Hộp thoại Thêm / Sửa sản phẩm
/// Nhập đầy đủ 4 trường: name, price, soluong, image
class ProductDialog extends StatefulWidget {
  final Product? product; // null nếu là Thêm mới, có giá trị nếu là Sửa
  final Future<void> Function(Product product) onSave;

  const ProductDialog({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _soluongController;
  late TextEditingController _imageController;

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? widget.product!.price.toStringAsFixed(0) : '',
    );
    _soluongController = TextEditingController(
      text: widget.product != null ? widget.product!.soluong.toString() : '',
    );
    _imageController = TextEditingController(text: widget.product?.image ?? '');

    _imageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _soluongController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  /// Chọn ảnh từ thư viện thiết bị hoặc chụp ảnh (Hỗ trợ Mobile và Web)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        final String base64String = base64Encode(bytes);
        // Lưu định dạng Data URI để hiển thị độc lập không phụ thuộc host ngoài
        final String dataUri = 'data:image/jpeg;base64,$base64String';
        setState(() {
          _imageController.text = dataUri;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tải ảnh từ thiết bị thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi chọn ảnh: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Chọn ảnh nhanh từ danh mục mẫu có sẵn
  void _showPresetPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.photo_library, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text(
                    'Chọn ảnh mẫu nhanh',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: quickImagePresets.length,
                  itemBuilder: (context, index) {
                    final item = quickImagePresets[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _imageController.text = item['url']!;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['url']!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['title']!,
                            style: const TextStyle(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Widget hiển thị Preview ảnh đã nhập
  Widget _buildImagePreview() {
    final imgStr = _imageController.text.trim();
    if (imgStr.isEmpty) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
              SizedBox(height: 6),
              Text(
                'Chưa có ảnh (Chọn từ máy, chụp ảnh hoặc nhập link)',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    Widget imageWidget;
    if (imgStr.startsWith('data:image')) {
      try {
        final commaIndex = imgStr.indexOf(',');
        final base64Data = commaIndex != -1 ? imgStr.substring(commaIndex + 1) : imgStr;
        imageWidget = Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildErrorImage(),
        );
      } catch (e) {
        imageWidget = _buildErrorImage();
      }
    } else {
      imageWidget = Image.network(
        imgStr,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildErrorImage(),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade100),
            ),
            child: imageWidget,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black54,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close, color: Colors.white, size: 16),
              onPressed: () => setState(() => _imageController.clear()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image, color: Colors.redAccent, size: 36),
            SizedBox(height: 4),
            Text('Đường dẫn ảnh không hợp lệ', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn hoặc nhập hình ảnh cho sản phẩm!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text.trim().replaceAll(',', '').replaceAll('.', ''));
      final soluong = int.parse(_soluongController.text.trim());
      final image = _imageController.text.trim();

      // Chỉ tạo Product với đúng 4 trường theo đề bài
      final product = Product(
        id: widget.product?.id,
        name: name,
        price: price,
        soluong: soluong,
        image: image,
      );

      await widget.onSave(product);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu sản phẩm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 550,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tiêu đề Dialog
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Icon(
                      isEditing ? Icons.edit_note : Icons.add_box,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Sửa Thông Tin Sản Phẩm' : 'Thêm Sản Phẩm Mới',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Cơ sở dữ liệu gồm 4 trường: name, price, soluong, image',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Nội dung form cuộn được
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trường 1: name (Tên sản phẩm)
                      const Text(
                        '1. Tên sản phẩm (name) *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'VD: iPhone 15 Pro Max 256GB',
                          prefixIcon: const Icon(Icons.shopping_bag_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nhập tên sản phẩm';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Hàng chứa Giá và Số lượng
                      Row(
                        children: [
                          // Trường 2: price (Giá sản phẩm)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '2. Giá bán (price - VND) *',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'VD: 15000000',
                                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Nhập giá bán';
                                    }
                                    final p = double.tryParse(val.trim().replaceAll(',', '').replaceAll('.', ''));
                                    if (p == null || p <= 0) {
                                      return 'Giá phải > 0';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Trường 3: soluong (Số lượng tồn kho)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '3. Số lượng (soluong) *',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _soluongController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'VD: 20',
                                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Nhập số lượng';
                                    }
                                    final q = int.tryParse(val.trim());
                                    if (q == null || q < 0) {
                                      return 'Số lượng >= 0';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Trường 4: image (Hình ảnh sản phẩm)
                      const Text(
                        '4. Hình ảnh sản phẩm (image) *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      // Xem trước ảnh
                      _buildImagePreview(),
                      const SizedBox(height: 10),
                      // Nút chọn ảnh từ thiết bị / camera / ảnh mẫu
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text('Thư viện máy'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                          if (!kIsWeb)
                            OutlinedButton.icon(
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: const Text('Chụp ảnh'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.collections, size: 18),
                            label: const Text('Ảnh mẫu nhanh'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _showPresetPicker,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Ô dán link ảnh trực tiếp
                      TextFormField(
                        controller: _imageController,
                        decoration: InputDecoration(
                          hintText: 'Hoặc dán URL ảnh (https://...)',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              // Nút Thao tác Hủy / Lưu
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Hủy bỏ'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _isLoading ? 'Đang lưu...' : (isEditing ? 'Cập nhật' : 'Thêm sản phẩm'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _handleSave,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
