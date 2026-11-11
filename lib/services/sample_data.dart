import '../models/product_model.dart';

/// Danh sách sản phẩm mẫu chuẩn phục vụ test và nạp CSDL ban đầu.
/// Mỗi sản phẩm CHỈ gồm đúng 4 trường: name, price, soluong, image.
final List<Product> sampleProducts = [
  Product(
    id: 'sample_1',
    name: 'iPhone 15 Pro Max 256GB Titan Tự Nhiên',
    price: 29990000.0,
    soluong: 12,
    image: 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600&auto=format&fit=crop&q=80',
  ),
  Product(
    id: 'sample_2',
    name: 'MacBook Pro 14 M3 Pro 18GB/512GB Space Black',
    price: 49990000.0,
    soluong: 8,
    image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&auto=format&fit=crop&q=80',
  ),
  Product(
    id: 'sample_3',
    name: 'Tai nghe Chống ồn Sony WH-1000XM5',
    price: 7990000.0,
    soluong: 25,
    image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
  ),
  Product(
    id: 'sample_4',
    name: 'Đồng hồ thông minh Apple Watch Series 9 GPS',
    price: 9890000.0,
    soluong: 18,
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80',
  ),
  Product(
    id: 'sample_5',
    name: 'Bàn phím cơ không dây Keychron K2 Pro QMK/VIA',
    price: 2450000.0,
    soluong: 30,
    image: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&auto=format&fit=crop&q=80',
  ),
  Product(
    id: 'sample_6',
    name: 'Chuột công thái học Logitech MX Master 3S',
    price: 2190000.0,
    soluong: 4,
    image: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=600&auto=format&fit=crop&q=80',
  ),
  Product(
    id: 'sample_7',
    name: 'Màn hình Dell UltraSharp 27 4K U2723QE IPS Black',
    price: 13990000.0,
    soluong: 6,
    image: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=600&auto=format&fit=crop&q=80',
  ),
  Product(
    id: 'sample_8',
    name: 'Loa Bluetooth Marshall Acton III',
    price: 6490000.0,
    soluong: 10,
    image: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=600&auto=format&fit=crop&q=80',
  ),
];

/// Danh sách URL ảnh mẫu nhanh để người dùng chọn nhanh khi thêm/sửa sản phẩm
final List<Map<String, String>> quickImagePresets = [
  {
    'title': 'Điện thoại Smartphone',
    'url': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&auto=format&fit=crop&q=80',
  },
  {
    'title': 'Laptop máy tính xách tay',
    'url': 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&auto=format&fit=crop&q=80',
  },
  {
    'title': 'Tai nghe chụp tai',
    'url': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
  },
  {
    'title': 'Đồng hồ thời trang',
    'url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80',
  },
  {
    'title': 'Giày thể thao Sneaker',
    'url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80',
  },
  {
    'title': 'Bàn phím Gaming',
    'url': 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&auto=format&fit=crop&q=80',
  },
  {
    'title': 'Máy ảnh kỹ thuật số',
    'url': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600&auto=format&fit=crop&q=80',
  },
  {
    'title': 'Balo laptop cao cấp',
    'url': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&auto=format&fit=crop&q=80',
  },
];
