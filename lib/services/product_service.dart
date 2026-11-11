import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'sample_data.dart';

/// Dịch vụ quản lý dữ liệu Sản phẩm kết nối Firebase Firestore.
/// Đảm bảo TUYỆT ĐỐI chỉ lưu và tương tác với 4 trường:
/// name, price, soluong, image.
class ProductService extends ChangeNotifier {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  static const String collectionName = 'products';

  bool _isFirebaseAvailable = false;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  // Dữ liệu bộ nhớ dự phòng (khi chưa cấu hình Firebase hoặc test offline)
  final List<Product> _localProducts = List.from(sampleProducts);
  final StreamController<List<Product>> _localStreamController =
      StreamController<List<Product>>.broadcast();

  void setFirebaseAvailable(bool available) {
    _isFirebaseAvailable = available;
    notifyListeners();
  }

  /// Lắng nghe luồng dữ liệu sản phẩm theo thời gian thực (Real-time Stream)
  Stream<List<Product>> streamProducts() {
    if (_isFirebaseAvailable) {
      try {
        return FirebaseFirestore.instance
            .collection(collectionName)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Product.fromMap(data, doc.id);
          }).toList();
        });
      } catch (e) {
        debugPrint('Lỗi stream Firestore, chuyển sang bộ nhớ cục bộ: $e');
      }
    }

    // Luồng dữ liệu cục bộ dự phòng
    Timer.run(() => _localStreamController.add(List.unmodifiable(_localProducts)));
    return _localStreamController.stream;
  }

  /// 1. THÊM SẢN PHẨM MỚI
  /// Lưu vào Firestore chỉ gồm 4 trường: name, price, soluong, image
  Future<void> addProduct(Product product) async {
    // Bản đồ dữ liệu chỉ gồm 4 trường theo đúng yêu cầu đề bài
    final data = product.toMap();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance.collection(collectionName).add(data);
        return;
      } catch (e) {
        debugPrint('Lỗi khi thêm vào Firestore: $e');
        // Nếu lỗi do quyền hoặc mạng, tiếp tục lưu vào bộ nhớ cục bộ
      }
    }

    // Fallback lưu cục bộ
    final newId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final newProduct = product.copyWith(id: newId);
    _localProducts.insert(0, newProduct);
    _localStreamController.add(List.unmodifiable(_localProducts));
    notifyListeners();
  }

  /// 2. CẬP NHẬT / SỬA SẢN PHẨM
  /// Cập nhật dữ liệu vào Firestore đúng 4 trường
  Future<void> updateProduct(Product product) async {
    if (product.id == null) {
      throw Exception('Không tìm thấy ID sản phẩm để sửa!');
    }

    final data = product.toMap();

    if (_isFirebaseAvailable && !product.id!.startsWith('local_')) {
      try {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(product.id)
            .update(data);
        return;
      } catch (e) {
        debugPrint('Lỗi khi sửa trên Firestore: $e');
      }
    }

    // Fallback cập nhật cục bộ
    final index = _localProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _localProducts[index] = product;
      _localStreamController.add(List.unmodifiable(_localProducts));
      notifyListeners();
    }
  }

  /// 3. XÓA SẢN PHẨM
  /// Xóa document trên Firestore theo Document ID
  Future<void> deleteProduct(String id) async {
    if (_isFirebaseAvailable && !id.startsWith('local_')) {
      try {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(id)
            .delete();
        return;
      } catch (e) {
        debugPrint('Lỗi khi xóa trên Firestore: $e');
      }
    }

    // Fallback xóa cục bộ
    _localProducts.removeWhere((p) => p.id == id);
    _localStreamController.add(List.unmodifiable(_localProducts));
    notifyListeners();
  }

  /// 4. NẠP DỮ LIỆU MẪU BAN ĐẦU VÀO FIREBASE
  /// Tiện ích hỗ trợ nạp nhanh dữ liệu vào CSDL Firebase chỉ bằng 1 nút bấm
  Future<int> seedSampleData() async {
    int count = 0;
    if (_isFirebaseAvailable) {
      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance.collection(collectionName);

      for (var product in sampleProducts) {
        final docRef = collection.doc();
        batch.set(docRef, product.toMap());
        count++;
      }
      await batch.commit();
      return count;
    } else {
      _localProducts.clear();
      _localProducts.addAll(sampleProducts);
      _localStreamController.add(List.unmodifiable(_localProducts));
      notifyListeners();
      return sampleProducts.length;
    }
  }

  /// 5. XUẤT CƠ SỞ DỮ LIỆU RA CHUỖI JSON
  /// Dữ liệu xuất ra TUYỆT ĐỐI chỉ gồm 4 trường: name, price, soluong, image
  String exportToJson(List<Product> products) {
    final list = products.map((p) => p.toMap()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  /// 6. NHẬP DỮ LIỆU TỪ CHUỖI JSON VÀO CSDL
  Future<int> importFromJson(String jsonString) async {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      throw Exception('Dữ liệu JSON phải là một danh sách danh mục các sản phẩm!');
    }

    int importedCount = 0;
    for (var item in decoded) {
      if (item is Map<String, dynamic>) {
        final product = Product.fromMap(item);
        await addProduct(product);
        importedCount++;
      }
    }
    return importedCount;
  }
}
