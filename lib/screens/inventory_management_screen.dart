// lib/screens/inventory_management_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../services/db_service.dart';
import 'add_product_screen.dart'; // Màn hình Thêm/Sửa sản phẩm

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {

  Widget _buildInventoryTile(BuildContext context, Product product) {
    const int minStock = 50;
    String status;
    Color statusColor;

    if (product.stockQuantity == 0) {
      status = 'Hết hàng';
      statusColor = Colors.red;
    } else if (product.stockQuantity <= minStock) {
      status = 'Sắp hết';
      statusColor = Colors.orange;
    } else {
      status = 'Còn hàng';
      statusColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddProductScreen(product: product),
            ),
          );
        },

        leading: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.inventory_2_outlined, color: Colors.blue.shade700),
        ),

        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã: ${product.id}'),
            Text('Giá: ${product.price.toStringAsFixed(0)} đ / ${product.unit}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Tồn: ${product.stockQuantity} ${product.unit}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: statusColor),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(fontSize: 12, color: statusColor.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddProductPressed() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddProductScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Kho hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.black45, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm sản phẩm',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 💡 PHẦN CUỘN: ĐÃ DÙNG EXPANDED
          Expanded(
            child: ValueListenableBuilder<Box<Product>>(
              valueListenable: DBService.products().listenable(),
              builder: (context, box, _) {
                final List<Product> products = box.values.toList();

                if (products.isEmpty) {
                  return const Center(
                    child: Text('Kho hàng đang trống. Hãy thêm sản phẩm mới.'),
                  );
                }

                // ListView.builder đã nằm trong Expanded
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0).copyWith(top: 8),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildInventoryTile(context, products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddProductPressed,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Nhập hàng'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}