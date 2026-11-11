import 'package:flutter/material.dart';

enum SortOption {
  defaultOrder,
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  quantityAsc,
  quantityDesc,
}

enum StockFilter {
  all,
  inStock,
  lowStock,
  outOfStock,
}

/// Thanh tìm kiếm, lọc và sắp xếp sản phẩm
class FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final SortOption selectedSort;
  final ValueChanged<SortOption> onSortChanged;
  final StockFilter selectedFilter;
  final ValueChanged<StockFilter> onFilterChanged;
  final bool isGridView;
  final ValueChanged<bool> onViewChanged;

  const FilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedSort,
    required this.onSortChanged,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.isGridView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 750;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              if (isSmall) ...[
                // Mobile: Thanh tìm kiếm ở trên
                TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên sản phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 8),
                // Hàng công cụ bên dưới
                Row(
                  children: [
                    Expanded(child: _buildFilterDropdown()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSortDropdown()),
                    const SizedBox(width: 8),
                    _buildViewToggle(),
                  ],
                ),
              ] else ...[
                // Desktop / Web: Hàng ngang chuyên nghiệp
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm theo tên (name)...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    onSearchChanged('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 3, child: _buildFilterDropdown()),
                    const SizedBox(width: 12),
                    Expanded(flex: 3, child: _buildSortDropdown()),
                    const SizedBox(width: 12),
                    _buildViewToggle(),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StockFilter>(
          value: selectedFilter,
          isExpanded: true,
          icon: const Icon(Icons.filter_list, size: 20),
          onChanged: (val) {
            if (val != null) onFilterChanged(val);
          },
          items: const [
            DropdownMenuItem(value: StockFilter.all, child: Text('Tất cả trạng thái', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: StockFilter.inStock, child: Text('Còn hàng (> 0)', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: StockFilter.lowStock, child: Text('Sắp hết (<= 5)', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: StockFilter.outOfStock, child: Text('Hết hàng (= 0)', overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: selectedSort,
          isExpanded: true,
          icon: const Icon(Icons.sort, size: 20),
          onChanged: (val) {
            if (val != null) onSortChanged(val);
          },
          items: const [
            DropdownMenuItem(value: SortOption.defaultOrder, child: Text('Mặc định', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: SortOption.nameAsc, child: Text('Tên: A -> Z', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: SortOption.nameDesc, child: Text('Tên: Z -> A', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: SortOption.priceAsc, child: Text('Giá: Thấp -> Cao', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: SortOption.priceDesc, child: Text('Giá: Cao -> Thấp', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: SortOption.quantityAsc, child: Text('SL: Ít -> Nhiều', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: SortOption.quantityDesc, child: Text('SL: Nhiều -> Ít', overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.grid_view,
              color: isGridView ? Colors.deepPurple : Colors.grey,
            ),
            tooltip: 'Xem dạng lưới',
            onPressed: () => onViewChanged(true),
          ),
          IconButton(
            icon: Icon(
              Icons.view_list,
              color: !isGridView ? Colors.deepPurple : Colors.grey,
            ),
            tooltip: 'Xem dạng danh sách',
            onPressed: () => onViewChanged(false),
          ),
        ],
      ),
    );
  }
}
