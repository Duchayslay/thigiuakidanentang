import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'widgets/analytics_view.dart';
import 'widgets/clay_banner.dart';
import 'widgets/clay_product_card.dart';
import 'widgets/clay_right_panel.dart';
import 'widgets/clay_sidebar.dart';
import 'widgets/filter_bar.dart';
import 'widgets/product_dialog.dart';

/// Màn hình Quản trị Sản phẩm Chính (Admin Dashboard)
/// Thiết kế giao diện phong cách Terracotta Clay cao cấp theo mẫu
/// Hỗ trợ hoàn hảo cả Web (Desktop) và Android (Mobile)
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  int _currentNavIndex = 0; // 0: Kho hàng, 1: Thống kê, 2: Trạng thái, 3: Tài khoản
  String _searchQuery = '';
  String _activeCategoryTag = 'Tất cả';
  SortOption _selectedSort = SortOption.defaultOrder;
  StockFilter _selectedFilter = StockFilter.all;

  // Tính năng nâng cao: Chế độ chọn nhiều sản phẩm xóa hàng loạt
  bool _isSelectionMode = false;
  final Set<String> _selectedProductIds = {};

  // Chế độ xem: Lưới (Grid) hoặc Danh sách (List) tối ưu responsive
  bool _isListView = false;

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
            await _productService.addProduct(savedProduct);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thêm sản phẩm mới vào Firebase thành công!'),
                  backgroundColor: AppColors.sageGreen,
                ),
              );
            }
          } else {
            await _productService.updateProduct(savedProduct);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cập nhật sản phẩm thành công!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          }
        },
      ),
    );
  }

  /// Điều chỉnh số lượng kho nhanh 1-chạm (+ / -)
  Future<void> _handleAdjustStock(Product product, int delta) async {
    await _productService.adjustStock(product, delta);
    if (mounted) {
      final isAdd = delta > 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${isAdd ? "Nhập thêm" : "Xuất bớt"} $delta cái cho "${product.name}". Tồn kho mới: ${(product.soluong + delta).clamp(0, 999999)}',
          ),
          backgroundColor: isAdd ? AppColors.sageGreen : AppColors.warmAmber,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  /// Xác nhận xóa 1 sản phẩm
  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.softRed),
            SizedBox(width: 8),
            Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa sản phẩm "${product.name}" khỏi cơ sở dữ liệu Firebase không?\n\nThao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.softRed,
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
                      backgroundColor: AppColors.softRed,
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

  /// Xóa hàng loạt sản phẩm đã chọn (Chức năng nâng cao)
  Future<void> _confirmDeleteSelected() async {
    if (_selectedProductIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Xóa hàng loạt sản phẩm?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có chắc chắn muốn xóa ${_selectedProductIds.length} sản phẩm đã chọn khỏi CSDL Firebase?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.softRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Xóa ${_selectedProductIds.length} sản phẩm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final count = await _productService.deleteBatch(_selectedProductIds.toList());
      setState(() {
        _selectedProductIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa thành công $count sản phẩm đã chọn!'),
            backgroundColor: AppColors.softRed,
          ),
        );
      }
    }
  }

  /// Nạp danh sách sản phẩm mẫu vào CSDL
  Future<void> _seedSampleData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Nạp 8 sản phẩm mẫu vào CSDL?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Hệ thống sẽ thêm 8 sản phẩm mẫu chuẩn (gồm đúng 4 trường name, price, soluong, image) vào CSDL Firebase để phục vụ kiểm tra và chấm thi.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
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
            backgroundColor: AppColors.sageGreen,
          ),
        );
      }
    }
  }

  /// Đăng xuất Admin
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi phân hệ quản trị?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.softRed, foregroundColor: Colors.white),
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

    // 2. Lọc theo danh mục tag trên banner
    if (_activeCategoryTag != 'Tất cả') {
      final tag = _activeCategoryTag.toLowerCase();
      list = list.where((p) {
        final n = p.name.toLowerCase();
        if (tag == 'điện thoại') return n.contains('iphone') || n.contains('samsung') || n.contains('phone');
        if (tag == 'laptop') return n.contains('macbook') || n.contains('laptop') || n.contains('dell');
        if (tag == 'âm thanh') return n.contains('tai nghe') || n.contains('loa') || n.contains('sony');
        return true;
      }).toList();
    }

    // 3. Lọc theo trạng thái tồn kho
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

    // 4. Sắp xếp
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
    final isFirebase = _productService.isFirebaseAvailable;

    return StreamBuilder<List<Product>>(
      stream: _productService.streamProducts(),
      builder: (context, snapshot) {
        final allProducts = snapshot.data ?? [];
        final displayedProducts = _filterAndSortProducts(allProducts);
        final totalStock = allProducts.fold<int>(0, (sum, p) => sum + p.soluong);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            if (isDesktop) {
              return _buildDesktopLayout(allProducts, displayedProducts, totalStock, isFirebase, constraints.maxWidth);
            } else {
              return _buildMobileAndroidLayout(allProducts, displayedProducts, totalStock, isFirebase);
            }
          },
        );
      },
    );
  }

  // ==========================================
  // 1. GIAO DIỆN DESKTOP / WEB (Như ảnh mẫu)
  // ==========================================
  Widget _buildDesktopLayout(
    List<Product> allProducts,
    List<Product> displayedProducts,
    int totalStock,
    bool isFirebase,
    double screenWidth,
  ) {
    final showRightPanel = screenWidth >= 1180;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // 1. Sidebar Terracotta phong cách Clay
          ClaySidebar(
            selectedIndex: _currentNavIndex,
            onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
            onLogout: _handleLogout,
            isFirebaseOnline: isFirebase,
          ),

          // 2. Nội dung Trung tâm
          Expanded(
            child: _currentNavIndex == 1
                ? AnalyticsView(products: allProducts)
                : _buildCenterContent(allProducts, displayedProducts, totalStock, isFirebase),
          ),

          // 3. Panel bên phải (Tự động thích ứng: chỉ hiện khi màn hình >= 1180px để không làm hẹp thẻ sản phẩm)
          if (showRightPanel)
            ClayRightPanel(
              products: allProducts,
              onEditProduct: _openProductDialog,
              onAdjustStock: _handleAdjustStock,
              onSeedData: _seedSampleData,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Thêm Sản Phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _openProductDialog(),
      ),
    );
  }

  Widget _buildCenterContent(
    List<Product> allProducts,
    List<Product> displayedProducts,
    int totalStock,
    bool isFirebase,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh trên cùng: Nút Thông báo + Ô tìm kiếm bo tròn
          Row(
            children: [
              // Nút Chuông thông báo (như góc trên trái trong ảnh mẫu)
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 22),
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.softRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Ô Tìm kiếm bo tròn hiện đại
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm theo tên (name)...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Banner chính "Quản lý kho hàng" (như Autumn day trong ảnh)
          ClayBanner(
            totalProducts: allProducts.length,
            totalStock: totalStock,
            activeTag: _activeCategoryTag,
            onTagSelected: (tag) => setState(() => _activeCategoryTag = tag),
          ),

          const SizedBox(height: 16),

          // Bộ lọc tồn kho nhanh & Sắp xếp
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', StockFilter.all),
                const SizedBox(width: 8),
                _buildFilterChip('Còn hàng (> 0)', StockFilter.inStock),
                const SizedBox(width: 8),
                _buildFilterChip('Sắp hết (<= 5)', StockFilter.lowStock),
                const SizedBox(width: 8),
                _buildFilterChip('Hết hàng (= 0)', StockFilter.outOfStock),
                const SizedBox(width: 14),
                _buildSortDropdown(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Hàng Tiêu đề mục "Sản Phẩm Trong Kho" (Day Schedule trong ảnh mẫu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Sản Phẩm Trong Kho',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${displayedProducts.length} SP',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              // Nút thao tác: Xóa đã chọn, Chọn nhiều & Đổi chế độ xem Lưới / Danh sách
              Row(
                children: [
                  if (_isSelectionMode && _selectedProductIds.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.delete_sweep, color: AppColors.softRed, size: 18),
                      label: Text(
                        'Xóa ${_selectedProductIds.length}',
                        style: const TextStyle(color: AppColors.softRed, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _confirmDeleteSelected,
                    ),
                  TextButton.icon(
                    icon: Icon(_isSelectionMode ? Icons.check_box : Icons.check_box_outline_blank, size: 16),
                    label: Text(_isSelectionMode ? 'Hủy chọn' : 'Chọn nhiều'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                    onPressed: () {
                      setState(() {
                        _isSelectionMode = !_isSelectionMode;
                        if (!_isSelectionMode) _selectedProductIds.clear();
                      });
                    },
                  ),
                  const SizedBox(width: 8),

                  // Nút chuyển đổi chế độ xem Lưới / Danh sách (Responsive tối ưu)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'Xem dạng lưới',
                          child: InkWell(
                            onTap: () => setState(() => _isListView = false),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: !_isListView ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.grid_view_rounded, size: 16, color: !_isListView ? Colors.white : AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Xem dạng danh sách hàng ngang',
                          child: InkWell(
                            onTap: () => setState(() => _isListView = true),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _isListView ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.view_list_rounded, size: 16, color: _isListView ? Colors.white : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hiển thị sản phẩm theo Lưới (Grid) hoặc Danh sách (List) tối ưu khoảng trắng
          Expanded(
            child: displayedProducts.isEmpty
                ? _buildEmptyState()
                : _isListView
                    ? ListView.builder(
                        itemCount: displayedProducts.length,
                        itemBuilder: (context, index) {
                          final product = displayedProducts[index];
                          final isSelected = _selectedProductIds.contains(product.id);

                          return ClayProductCard(
                            product: product,
                            isListView: true,
                            isSelectionMode: _isSelectionMode,
                            isSelected: isSelected,
                            onSelectChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  if (product.id != null) _selectedProductIds.add(product.id!);
                                } else {
                                  _selectedProductIds.remove(product.id);
                                }
                              });
                            },
                            onEdit: () => _openProductDialog(product),
                            onDelete: () => _confirmDelete(product),
                            onAdjustStock: (delta) => _handleAdjustStock(product, delta),
                          );
                        },
                      )
                    : LayoutBuilder(
                        builder: (context, gridConstraints) {
                          final availableWidth = gridConstraints.maxWidth;
                          final crossAxisCount = (availableWidth / 210).floor().clamp(2, 4);

                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.90, // Tỉ lệ chuẩn 0.90 loại bỏ hoàn toàn khoảng trắng thừa
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: displayedProducts.length,
                            itemBuilder: (context, index) {
                              final product = displayedProducts[index];
                              final isSelected = _selectedProductIds.contains(product.id);

                              return ClayProductCard(
                                product: product,
                                isListView: false,
                                isSelectionMode: _isSelectionMode,
                                isSelected: isSelected,
                                onSelectChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      if (product.id != null) _selectedProductIds.add(product.id!);
                                    } else {
                                      _selectedProductIds.remove(product.id);
                                    }
                                  });
                                },
                                onEdit: () => _openProductDialog(product),
                                onDelete: () => _confirmDelete(product),
                                onAdjustStock: (delta) => _handleAdjustStock(product, delta),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. GIAO DIỆN DI ĐỘNG / ANDROID
  // ==========================================
  Widget _buildMobileAndroidLayout(
    List<Product> allProducts,
    List<Product> displayedProducts,
    int totalStock,
    bool isFirebase,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'Admin Kho Hàng',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          // Badge trạng thái kết nối Firebase
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isFirebase ? AppColors.sageGreenLight : AppColors.warmAmberLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFirebase ? Icons.cloud_done : Icons.cloud_off,
                  size: 13,
                  color: isFirebase ? AppColors.sageGreen : AppColors.warmAmber,
                ),
                const SizedBox(width: 4),
                Text(
                  isFirebase ? 'Online' : 'Local',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isFirebase ? AppColors.sageGreen : AppColors.warmAmber,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.dataset_outlined, color: AppColors.textPrimary),
            tooltip: 'Nạp dữ liệu mẫu',
            onPressed: _seedSampleData,
          ),
        ],
      ),

      // Thân trang theo Tab được chọn
      body: _currentNavIndex == 1
          ? AnalyticsView(products: allProducts)
          : _currentNavIndex == 2
              ? _buildAccountTab(isFirebase)
              : _buildMobileProductList(allProducts, displayedProducts, totalStock),

      // Thanh điều hướng dưới đáy chuẩn Android (Curved Bottom Navigation)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentNavIndex,
          onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryLight,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Kho Hàng',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics_rounded, color: AppColors.primary),
              label: 'Thống Kê',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Tài Khoản',
            ),
          ],
        ),
      ),

      floatingActionButton: _currentNavIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              onPressed: () => _openProductDialog(),
            )
          : null,
    );
  }

  Widget _buildMobileProductList(
    List<Product> allProducts,
    List<Product> displayedProducts,
    int totalStock,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner trên Android
          ClayBanner(
            totalProducts: allProducts.length,
            totalStock: totalStock,
            activeTag: _activeCategoryTag,
            onTagSelected: (tag) => setState(() => _activeCategoryTag = tag),
          ),
          const SizedBox(height: 14),

          // Ô Tìm kiếm trên mobile
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên sản phẩm...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            ),
          ),
          const SizedBox(height: 12),

          // Bộ lọc nhanh trên Mobile
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', StockFilter.all),
                const SizedBox(width: 6),
                _buildFilterChip('Còn hàng', StockFilter.inStock),
                const SizedBox(width: 6),
                _buildFilterChip('Sắp hết', StockFilter.lowStock),
                const SizedBox(width: 6),
                _buildFilterChip('Hết hàng', StockFilter.outOfStock),
                const SizedBox(width: 8),
                _buildSortDropdown(),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tiêu đề danh sách
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh Sách Sản Phẩm (${displayedProducts.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSelectionMode = !_isSelectionMode;
                        if (!_isSelectionMode) _selectedProductIds.clear();
                      });
                    },
                    child: Text(
                      _isSelectionMode ? 'Hủy chọn' : 'Chọn nhiều',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Đổi chế độ xem trên mobile
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _isListView = false),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: !_isListView ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.grid_view_rounded, size: 14, color: !_isListView ? Colors.white : AppColors.textSecondary),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _isListView = true),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: _isListView ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.view_list_rounded, size: 14, color: _isListView ? Colors.white : AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isSelectionMode && _selectedProductIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_sweep, size: 16),
                label: Text('Xóa ${_selectedProductIds.length} sản phẩm đã chọn'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.softRed),
                onPressed: _confirmDeleteSelected,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Hiển thị sản phẩm tối ưu trên Android (Không khoảng trắng thừa)
          if (displayedProducts.isEmpty)
            _buildEmptyState()
          else if (_isListView)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedProducts.length,
              itemBuilder: (context, index) {
                final product = displayedProducts[index];
                final isSelected = _selectedProductIds.contains(product.id);

                return ClayProductCard(
                  product: product,
                  isListView: true,
                  isSelectionMode: _isSelectionMode,
                  isSelected: isSelected,
                  onSelectChanged: (val) {
                    setState(() {
                      if (val == true) {
                        if (product.id != null) _selectedProductIds.add(product.id!);
                      } else {
                        _selectedProductIds.remove(product.id);
                      }
                    });
                  },
                  onEdit: () => _openProductDialog(product),
                  onDelete: () => _confirmDelete(product),
                  onAdjustStock: (delta) => _handleAdjustStock(product, delta),
                );
              },
            )
          else
            LayoutBuilder(
              builder: (context, mobileConstraints) {
                final isVerySmall = mobileConstraints.maxWidth < 360;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isVerySmall ? 1 : 2,
                    childAspectRatio: isVerySmall ? 1.35 : 0.88, // 0.88 tỉ lệ vàng gọn gàng không khoảng trắng
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    final product = displayedProducts[index];
                    final isSelected = _selectedProductIds.contains(product.id);

                    return ClayProductCard(
                      product: product,
                      isListView: false,
                      isSelectionMode: _isSelectionMode,
                      isSelected: isSelected,
                      onSelectChanged: (val) {
                        setState(() {
                          if (val == true) {
                            if (product.id != null) _selectedProductIds.add(product.id!);
                          } else {
                            _selectedProductIds.remove(product.id);
                          }
                        });
                      },
                      onEdit: () => _openProductDialog(product),
                      onDelete: () => _confirmDelete(product),
                      onAdjustStock: (delta) => _handleAdjustStock(product, delta),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAccountTab(bool isFirebase) {
    final auth = AuthService();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.person, color: AppColors.primary, size: 36),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quản Trị Viên (Admin)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        auth.userEmail.isNotEmpty ? auth.userEmail : 'admin@store.com',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: Icon(
              isFirebase ? Icons.cloud_done : Icons.cloud_off,
              color: isFirebase ? AppColors.sageGreen : AppColors.warmAmber,
            ),
            title: const Text('Trạng thái CSDL Firebase'),
            subtitle: Text(isFirebase ? 'Đã kết nối Cloud Firestore' : 'Chế độ lưu trữ cục bộ (Local Fallback)'),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.dataset_outlined, color: AppColors.primary),
            title: const Text('Nạp lại dữ liệu mẫu'),
            subtitle: const Text('Khôi phục 8 sản phẩm mẫu chuẩn ban đầu'),
            onTap: _seedSampleData,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Đăng Xuất Khỏi Hệ Thống'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, StockFilter filter) {
    final isSelected = _selectedFilter == filter;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filter),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: _selectedSort,
          icon: const Icon(Icons.sort, size: 16, color: AppColors.textPrimary),
          isDense: true,
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          onChanged: (val) {
            if (val != null) setState(() => _selectedSort = val);
          },
          items: const [
            DropdownMenuItem(value: SortOption.defaultOrder, child: Text('Sắp xếp: Mặc định')),
            DropdownMenuItem(value: SortOption.nameAsc, child: Text('Tên: A -> Z')),
            DropdownMenuItem(value: SortOption.nameDesc, child: Text('Tên: Z -> A')),
            DropdownMenuItem(value: SortOption.priceAsc, child: Text('Giá: Thấp -> Cao')),
            DropdownMenuItem(value: SortOption.priceDesc, child: Text('Giá: Cao -> Thấp')),
            DropdownMenuItem(value: SortOption.quantityAsc, child: Text('Tồn: Ít -> Nhiều')),
            DropdownMenuItem(value: SortOption.quantityDesc, child: Text('Tồn: Nhiều -> Ít')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 60, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Không tìm thấy sản phẩm nào khớp với "$_searchQuery"'
                  : 'Chưa có sản phẩm nào trong kho hàng',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Thêm sản phẩm mới'),
              onPressed: () => _openProductDialog(),
            ),
          ],
        ),
      ),
    );
  }
}
