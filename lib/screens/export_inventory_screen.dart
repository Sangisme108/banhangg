// lib/screens/export_inventory_screen.dart (ĐÃ CHỈNH SỬA LOGIC XUẤT KHO)
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart'; // Đảm bảo import Product model
import '../services/db_service.dart'; // Đảm bảo import DBService

class ExportInventoryScreen extends StatefulWidget {
  const ExportInventoryScreen({super.key});

  @override
  State<ExportInventoryScreen> createState() => _ExportInventoryScreenState();
}

class _ExportInventoryScreenState extends State<ExportInventoryScreen> {
  final _productSearchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Product? _selectedProduct;

  // HÀM TÌM SẢN PHẨM THEO MÃ HOẶC TÊN
  void _searchProduct(String query) {
    if (query.isEmpty) {
      setState(() => _selectedProduct = null);
      return;
    }

    final box = DBService.products();
    final product = box.values.firstWhere(
          (p) => p.id.toLowerCase() == query.toLowerCase() || p.name.toLowerCase().contains(query.toLowerCase()),
      orElse: () => null as Product,
    );

    setState(() => _selectedProduct = product);
  }

  // --- LOGIC CỐT LÕI: TRỪ SỐ LƯỢNG VÀ LƯU KHO ---
  void _onConfirmExport() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn sản phẩm và nhập đủ thông tin.')));
      return;
    }

    final int exportQuantity = int.tryParse(_quantityController.text) ?? 0;

    if (exportQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số lượng xuất phải lớn hơn 0.')));
      return;
    }

    if (exportQuantity > _selectedProduct!.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Số lượng xuất vượt quá tồn kho (${_selectedProduct!.stockQuantity} ${_selectedProduct!.unit}).'))
      );
      return;
    }

    try {
      // 1. Cập nhật số lượng tồn kho (TRỪ ĐI)
      _selectedProduct!.stockQuantity -= exportQuantity;

      // 2. LƯU VÀO CƠ SỞ DỮ LIỆU (Bước quan trọng nhất!)
      await _selectedProduct!.save();

      // 3. Thông báo và trở về
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xuất thành công $exportQuantity ${_selectedProduct!.unit} của ${_selectedProduct!.name}. Tồn kho mới: ${_selectedProduct!.stockQuantity}'))
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu kho: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xuất kho'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trường Tìm kiếm sản phẩm
              const Text('Tìm kiếm sản phẩm', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _productSearchController,
                onChanged: _searchProduct, // Tìm kiếm khi gõ
                decoration: InputDecoration(
                  hintText: 'Nhập tên hoặc mã sản phẩm...',
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              if (_selectedProduct != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sản phẩm đã chọn: ${_selectedProduct!.name} (Mã: ${_selectedProduct!.id})', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Tồn kho hiện tại: ${_selectedProduct!.stockQuantity} ${_selectedProduct!.unit}', style: TextStyle(color: Colors.blue.shade800)),
                      const Divider(height: 20),
                    ],
                  ),
                )
              else if (_productSearchController.text.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text('Không tìm thấy sản phẩm.', style: TextStyle(color: Colors.red)),
                ),

              // Trường Số lượng xuất
              const Text('Số lượng xuất', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  final int? quantity = int.tryParse(val ?? '');
                  if (quantity == null || quantity <= 0) {
                    return 'Số lượng phải là số nguyên dương.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Trường Lý do xuất hủy
              const Text('Lý do xuất hủy', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Nhập lý do xuất hủy...',
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Nút Xác nhận xuất hủy
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onConfirmExport, // GỌI HÀM LƯU KHO (TRỪ)
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Xác nhận xuất hủy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}