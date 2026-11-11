import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import 'login_screen.dart';
import 'widgets/filter_bar.dart';
import 'widgets/product_card.dart';
import 'widgets/product_dialog.dart';
import 'widgets/stats_overview.dart';

/// Màn hình Quản trị Sản phẩm Chính (Admin Dashboard)
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  SortOption _selectedSort = SortOption.defaultOrder;
  StockFilter _selectedFilter = StockFilter.all;
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Mở hộp thoại Thêm / Sửa sản phẩm
  void _openProductDialog([Product? product]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ProductDialog(
        product: product,
        onSave: (savedProduct) async {
          if (product == null) {
            // Thêm mới
            await _productService.addProduct(savedProduct);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thêm sản phẩm mới thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            // Cập nhật
            await _productService.updateProduct(savedProduct);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cập nhật sản phẩm thành công!'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          }
        },
      ),
    );
  }

  /// Xác nhận xóa sản phẩm
  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa sản phẩm "${product.name}" khỏi cơ sở dữ liệu không?\n\nThao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (product.id != null) {
                await _productService.deleteProduct(product.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa "${product.name}" thành công!'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              }
            },
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }

  /// Nạp danh sách sản phẩm mẫu vào CSDL
  Future<void> _seedSampleData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nạp dữ liệu mẫu ban đầu?'),
        content: const Text(
          'Hệ thống sẽ thêm 8 sản phẩm mẫu chuẩn (gồm đúng 4 trường name, price, soluong, image) vào CSDL Firebase để phục vụ kiểm tra và chấm thi.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nạp dữ liệu'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final count = await _productService.seedSampleData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã nạp thành công $count sản phẩm mẫu vào CSDL!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Xuất CSDL ra JSON để nộp bài
  void _exportDatabaseDialog(List<Product> products) {
    final jsonStr = _productService.exportToJson(products);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.file_download_outlined, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Xuất Cơ Sở Dữ Liệu (JSON)'),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dữ liệu JSON dưới đây CHỈ gồm 4 trường: name, price, soluong, image tuân thủ 100% yêu cầu nộp bài.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Container(
                height: 250,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Sao chép JSON'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép chuỗi JSON vào Clipboard!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Đăng xuất Admin
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi phân hệ quản trị?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  /// Lọc và sắp xếp danh sách sản phẩm
  List<Product> _filterAndSortProducts(List<Product> rawList) {
    List<Product> list = List.from(rawList);

    // 1. Tìm kiếm theo tên (name)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    // 2. Lọc theo trạng thái tồn kho
    switch (_selectedFilter) {
      case StockFilter.inStock:
        list = list.where((p) => p.soluong > 0).toList();
        break;
      case StockFilter.lowStock:
        list = list.where((p) => p.soluong > 0 && p.soluong <= 5).toList();
        break;
      case StockFilter.outOfStock:
        list = list.where((p) => p.soluong == 0).toList();
        break;
      case StockFilter.all:
        break;
    }

    // 3. Sắp xếp
    switch (_selectedSort) {
      case SortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.quantityAsc:
        list.sort((a, b) => a.soluong.compareTo(b.soluong));
        break;
      case SortOption.quantityDesc:
        list.sort((a, b) => b.soluong.compareTo(a.soluong));
        break;
      case SortOption.defaultOrder:
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final isFirebase = _productService.isFirebaseAvailable;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.deepPurple, size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phân Hệ Quản Trị Admin',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Quản lý sản phẩm (name, price, soluong, image)',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Badge trạng thái Firebase
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isFirebase ? Colors.green.shade50 : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isFirebase ? Colors.green.shade300 : Colors.amber.shade400,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFirebase ? Icons.cloud_done : Icons.cloud_queue,
                  size: 14,
                  color: isFirebase ? Colors.green.shade700 : Colors.amber.shade900,
                ),
                const SizedBox(width: 4),
                Text(
                  isFirebase ? 'Firebase Online' : 'CSDL Sẵn Sàng',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isFirebase ? Colors.green.shade700 : Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),

          // Nút Nạp dữ liệu mẫu
          IconButton(
            icon: const Icon(Icons.dataset_outlined),
            tooltip: 'Nạp dữ liệu mẫu vào CSDL',
            onPressed: _seedSampleData,
          ),

          // Nút Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Đăng xuất (${auth.userEmail})',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.streamProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProducts = snapshot.data ?? [];
          final displayedProducts = _filterAndSortProducts(allProducts);

          return CustomScrollView(
            slivers: [
              // 1. Thống kê tổng quan (Dashboard Stats)
              SliverToBoxAdapter(
                child: StatsOverview(products: allProducts),
              ),

              // 2. Thanh tìm kiếm, lọc, sắp xếp và đổi kiểu xem
              SliverToBoxAdapter(
                child: FilterBar(
                  searchController: _searchController,
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  selectedSort: _selectedSort,
                  onSortChanged: (val) => setState(() => _selectedSort = val),
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (val) => setState(() => _selectedFilter = val),
                  isGridView: _isGridView,
                  onViewChanged: (val) => setState(() => _isGridView = val),
                ),
              ),

              // 3. Thanh hiển thị số lượng & Nút Xuất file CSDL JSON
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hiển thị: ${displayedProducts.length} / ${allProducts.length} sản phẩm',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Xuất CSDL JSON nộp bài'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _exportDatabaseDialog(allProducts),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Danh sách hoặc Lưới hiển thị Sản phẩm
              if (displayedProducts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Không tìm thấy sản phẩm nào khớp với "$_searchQuery"'
                              : 'Chưa có sản phẩm nào trong cơ sở dữ liệu',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm sản phẩm đầu tiên'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _openProductDialog(),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isGridView)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _calculateGridCrossAxisCount(context),
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = displayedProducts[index];
                        return ProductCard(
                          product: product,
                          isGridView: true,
                          onEdit: () => _openProductDialog(product),
                          onDelete: () => _confirmDelete(product),
                        );
                      },
                      childCount: displayedProducts.length,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = displayedProducts[index];
                      return ProductCard(
                        product: product,
                        isGridView: false,
                        onEdit: () => _openProductDialog(product),
                        onDelete: () => _confirmDelete(product),
                      );
                    },
                    childCount: displayedProducts.length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Thêm Sản Phẩm'),
        onPressed: () => _openProductDialog(),
      ),
    );
  }

  int _calculateGridCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 850) return 3;
    if (width > 550) return 2;
    return 1;
  }
}
