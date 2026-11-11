import 'dart:convert';

/// Model sản phẩm tuân thủ nghiêm ngặt yêu cầu đề bài:
/// Cơ sở dữ liệu CHỈ gồm 4 trường: name, price, soluong, image
/// Không thêm bất kỳ trường nào khác vào CSDL!
class Product {
  /// id là Document ID trên Firestore (chỉ dùng ở phía Client để định danh,
  /// tuyệt đối không ghi id vào data của Document Firestore)
  final String? id;

  /// Tên sản phẩm
  final String name;

  /// Giá sản phẩm (VND)
  final double price;

  /// Số lượng sản phẩm
  final int soluong;

  /// Link hình ảnh (URL hoặc Base64 data URI)
  final String image;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
  });

  /// Chuyển thành Map để lưu vào Firestore hoặc File JSON CSDL
  /// CHỈ CHỨA ĐÚNG 4 TRƯỜNG theo yêu cầu đề bài!
  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'price': price,
      'soluong': soluong,
      'image': image.trim(),
    };
  }

  /// Khởi tạo đối tượng từ Map (Firestore Document Snapshot hoặc JSON)
  factory Product.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Product(
      id: docId,
      name: map['name']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      soluong: (map['soluong'] as num?)?.toInt() ?? 0,
      image: map['image']?.toString() ?? '',
    );
  }

  /// Tạo bản sao với các thuộc tính cập nhật
  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? soluong,
    String? image,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      soluong: soluong ?? this.soluong,
      image: image ?? this.image,
    );
  }

  /// Chuyển thành chuỗi JSON
  String toJson() => jsonEncode(toMap());

  /// Khởi tạo từ chuỗi JSON
  factory Product.fromJson(String source, [String? docId]) =>
      Product.fromMap(jsonDecode(source) as Map<String, dynamic>, docId);

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, soluong: $soluong, image: ${image.length > 30 ? "${image.substring(0, 30)}..." : image})';
  }
}
