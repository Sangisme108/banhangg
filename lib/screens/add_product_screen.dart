// lib/screens/add_product_screen.dart (ĐÃ CHỈNH SỬA)
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/db_service.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  // Thêm tham số isAddingStock để phân biệt mục đích:
  // - false (mặc định): Thêm mới hoặc Sửa chi tiết (ghi đè tồn kho)
  // - true: Chỉ để nhập thêm (cộng dồn tồn kho)
  // Tuy nhiên, theo logic mới, ta chỉ giữ lại logic: Thêm mới và Chỉnh sửa (ghi đè tồn kho)
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _unitController;
  late TextEditingController _stockQuantityController;
  bool _isProcessing = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Controllers với dữ liệu hiện có nếu là chế độ chỉnh sửa
    _idController = TextEditingController(text: widget.product?.id ?? '');
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
        text: widget.product?.price.toString() ?? '');
    _unitController = TextEditingController(
        text: widget.product?.unit ?? '');
    _stockQuantityController = TextEditingController(
        text: widget.product?.stockQuantity.toString() ?? '0');

    // Nếu là chế độ chỉnh sửa, không cho phép sửa ID
    if (_isEditing) {
      _idController.addListener(() {
        if (_idController.text != widget.product!.id) {
          _idController.text = widget.product!.id;
          _idController.selection = TextSelection.fromPosition(TextPosition(offset: _idController.text.length));
        }
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final String id = _idController.text.trim();
      final String name = _nameController.text.trim();
      final double price = double.parse(_priceController.text);
      final String unit = _unitController.text.trim();
      final int stockQuantity = int.parse(_stockQuantityController.text); // Lượng tồn kho mới

      final box = DBService.products();

      if (_isEditing) {
        // CHẾ ĐỘ CHỈNH SỬA/NHẬP KHO (GHI ĐÈ TỒN KHO):
        widget.product!.name = name;
        widget.product!.price = price;
        widget.product!.unit = unit;
        widget.product!.stockQuantity = stockQuantity; // GHI ĐÈ số lượng
        await widget.product!.save();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật sản phẩm thành công!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        // CHẾ ĐỘ THÊM MỚI:
        if (box.containsKey(id)) {
          throw Exception('Mã sản phẩm đã tồn tại. Vui lòng chọn Mã khác.');
        }

        final Product newProduct = Product(
          id: id,
          name: name,
          price: price,
          unit: unit,
          stockQuantity: stockQuantity, // Tồn kho ban đầu
        );

        await box.put(newProduct.id, newProduct);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm sản phẩm thành công!'), backgroundColor: Colors.green),
        );
        // Xóa các trường sau khi thêm mới
        _nameController.clear();
        _priceController.clear();
        _unitController.clear();
        _stockQuantityController.text = '0';
        _idController.clear();
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa Sản phẩm' : 'Thêm Sản phẩm Mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mã sản phẩm
              TextFormField(
                controller: _idController,
                readOnly: _isEditing, // KHÔNG cho phép sửa ID khi chỉnh sửa
                decoration: InputDecoration(
                  labelText: 'Mã Sản phẩm (ID)',
                  hintText: 'VD: TAO_DO, COKE...',
                  border: const OutlineInputBorder(),
                  filled: _isEditing,
                  fillColor: _isEditing ? Colors.grey.shade100 : Colors.white,
                  suffixIcon: _isEditing ? const Icon(Icons.lock_outline, color: Colors.grey) : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Mã Sản phẩm.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tên Sản phẩm
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên Sản phẩm',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Tên Sản phẩm.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Giá bán
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá bán (VNĐ)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Giá bán.';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Giá bán phải là số dương.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Đơn vị tính
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Đơn vị tính (VD: cái, kg, lon, nải)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Đơn vị tính.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Số lượng tồn kho
              TextFormField(
                controller: _stockQuantityController,
                decoration: InputDecoration(
                  labelText: _isEditing ? 'Tồn kho MỚI (Ghi đè)' : 'Tồn kho Ban đầu',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Tồn kho.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Vui lòng nhập Số lượng hợp lệ (số nguyên).';
                  }
                  if (int.tryParse(value)! < 0) {
                    return 'Tồn kho không thể là số âm.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Nút Lưu/Thêm
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _isEditing ? 'CẬP NHẬT SẢN PHẨM' : 'THÊM SẢN PHẨM MỚI',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}