// lib/screens/import_inventory_screen.dart (ĐÃ CHỈNH SỬA)

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/inventory_history.dart'; // <<< THÊM IMPORT MODEL LỊCH SỬ
import '../services/db_service.dart'; // <<< Đảm bảo bạn có DBService và hàm inventoryHistory()

class ImportInventoryScreen extends StatefulWidget {
  const ImportInventoryScreen({super.key});

  @override
  State<ImportInventoryScreen> createState() => _ImportInventoryScreenState();
}

class _ImportInventoryScreenState extends State<ImportInventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _newFormKey = GlobalKey<FormState>();

  // New item controllers
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '0');

  String? _pickedImagePath;
  bool _processing = false;

  Future<void> _pickImage() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      setState(() => _pickedImagePath = file.path);
    }
  }

  // --- HÀM GHI LỊCH SỬ CHO SẢN PHẨM ĐÃ CÓ ---
  Future<void> _addToExisting(Product item) async {
    final qtyController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nhập thêm vào: ${item.name}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số lượng',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Nhập số lượng';
              final n = int.tryParse(v);
              if (n == null || n <= 0) return 'Số không hợp lệ';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(int.parse(qtyController.text.trim()));
              }
            },
            child: const Text('Nhập'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _processing = true);
      try {
        // SỬA THÀNH:
        final box = DBService.products();
        final existing = box.get(item.id);

        if (existing == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi: Sản phẩm không còn trong kho.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // 1. Cập nhật tồn kho
          existing.stockQuantity = existing.stockQuantity + result;
          // Vì InventoryItem không kế thừa HiveObject (chỉ có save()), 
          // ta dùng box.put để cập nhật lại key:item.id.
          await box.put(existing.id, existing);

          // 2. <<< GHI LỊCH SỬ NHẬP KHO >>>
          final historyItem = InventoryHistory(
            productId: existing.id,
            productName: existing.name,
            quantity: result,
            timestamp: DateTime.now(),
            transactionType: 'IN', // Loại giao dịch: Nhập
            unitPrice: existing.price, // Giá nhập (lấy tạm là giá bán hiện tại)
          );
          await DBService.inventoryHistory().add(historyItem); // LƯU

          // Báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã nhập $result vào ${existing.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi nhập hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _processing = false);
      }
    }
  }

  // --- HÀM GHI LỊCH SỬ CHO SẢN PHẨM MỚI ---
  Future<void> _createNewInventoryItem() async {
    if (!_newFormKey.currentState!.validate()) return;
    setState(() => _processing = true);
    try {
      final id = _idController.text.trim();
      final box = DBService.products();

      // Kiểm tra trùng ID
      if (box.containsKey(id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mã sản phẩm đã tồn tại trong kho!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final unit = _unitController.text.trim();
      final qty = int.parse(_qtyController.text.trim());

      final item = Product(
        id: id,
        name: name,
        price: price,
        unit: unit,
        stockQuantity: qty,
      );
      await box.put(item.id, item);

      // Giả định DBService có productImages() để xử lý ảnh
      if (_pickedImagePath != null) {
        // Hãy đảm bảo DBService.productImages() là một Hive Box<String>
        // và bạn đã mở nó trong main.dart
        await DBService.productImages().put(item.id, _pickedImagePath!);
      }

      // <<< GHI LỊCH SỬ NHẬP KHO CHO MẶT HÀNG MỚI >>>
      final historyItem = InventoryHistory(
        productId: item.id,
        productName: item.name,
        quantity: item.stockQuantity,
        timestamp: DateTime.now(),
        transactionType: 'IN',
        unitPrice: item.price,
      );
      await DBService.inventoryHistory().add(historyItem); // LƯU

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${item.name} vào kho với SL: ${item.stockQuantity}'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _idController.clear();
      _nameController.clear();
      _priceController.clear();
      _unitController.clear();
      _qtyController.text = '0';
      _newFormKey.currentState!.reset();
      _pickedImagePath = null;

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi thêm hàng mới: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  // ... (Phần UI build giữ nguyên)
  @override
  Widget build(BuildContext context) {
    // ... (Code UI của bạn)
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nhập hàng vào kho',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Phần danh sách tìm kiếm sản phẩm đã có)

            const Text(
              'Nhập hàng mới (Sản phẩm chưa có trong kho)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _newFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'Mã SP (Dùng làm Key)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nhập mã SP' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên sản phẩm',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nhập tên SP' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Giá bán (đơn vị)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Nhập giá bán';
                      final n = double.tryParse(v);
                      if (n == null || n <= 0) return 'Số không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Đơn vị tính (kg, chiếc, hộp...)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nhập đơn vị' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _qtyController,
                    decoration: const InputDecoration(
                      labelText: 'Số lượng nhập (ban đầu)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Nhập số lượng';
                      final n = int.tryParse(v);
                      if (n == null || n < 0) return 'Số không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Chọn ảnh'),
                      ),
                      const SizedBox(width: 12),
                      if (_pickedImagePath != null)
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: Image.file(
                            File(_pickedImagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _processing ? null : _createNewInventoryItem,
                      child: _processing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Thêm vào kho'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}