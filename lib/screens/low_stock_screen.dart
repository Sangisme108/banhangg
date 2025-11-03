// lib/screens/low_stock_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../services/db_service.dart';
import 'add_product_screen.dart'; // Để có thể ấn vào sản phẩm và nhập thêm/sửa

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  static const int _MIN_STOCK = 50;

  // Widget hiển thị từng sản phẩm
  Widget _buildProductTile(BuildContext context, Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200, width: 1.5), // Nhấn mạnh sắp hết
      ),
      child: ListTile(
        onTap: () async {
          // Khi ấn vào, điều hướng đến màn hình Thêm/Sửa để nhập thêm hàng
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
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sắp hết',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm Sắp hết hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<Box<Product>>(
        valueListenable: DBService.products().listenable(),
        builder: (context, box, _) {
          // Lọc ra các sản phẩm sắp hết hàng
          final List<Product> lowStockProducts = box.values
              .where((p) => p.stockQuantity > 0 && p.stockQuantity <= _MIN_STOCK)
              .toList();

          if (lowStockProducts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, color: Colors.green, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Tuyệt vời! Hiện tại không có sản phẩm nào sắp hết hàng.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: lowStockProducts.length,
            itemBuilder: (context, index) {
              return _buildProductTile(context, lowStockProducts[index]);
            },
          );
        },
      ),
    );
  }
}