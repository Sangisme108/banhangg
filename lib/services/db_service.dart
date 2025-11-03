import 'package:hive_flutter/hive_flutter.dart';
// KHÔNG cần import 'package:flutter/foundation.dart' nữa vì đã dùng print()
import '../models/product.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../models/order_line.dart';

class DBService {
  static const String productsBox = 'products';
  static const String usersBox = 'users';
  static const String ordersBox = 'orders';
  static const String settingsBox = 'settings';
  static const String cartsBox = 'carts';

  static Future<void> init() async {
    // 1. Initialize Hive & Register Adapters
    await Hive.initFlutter();
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(OrderAdapter());
    Hive.registerAdapter(OrderLineAdapter());

    // 2. Open Boxes
    await Hive.openBox<Product>(productsBox);
    await Hive.openBox<User>(usersBox);
    await Hive.openBox<Order>(ordersBox);
    await Hive.openBox(cartsBox);
    await Hive.openBox(settingsBox);

    // 3. Migrate product keys (if they were stored with numeric keys)
    await _migrateProductsToIdKeys();

    // 4. Seed Data
    await seedProducts();
    await seedUsers();
  }

  // CÁC HÀM GETTER
  static Box<Product> products() => Hive.box<Product>(productsBox);
  static Box<User> users() => Hive.box<User>(usersBox);
  static Box<Order> orders() => Hive.box<Order>(ordersBox);
  static Box carts() => Hive.box(cartsBox);
  static Box settings() => Hive.box(settingsBox);

  // --- LOGIC SEEDING ---

  static Future<void> seedProducts() async {
    final box = products();
    if (box.isEmpty) {
      final List<Product> sampleProducts = [
        // ĐÃ SỬA: Dữ liệu mẫu dùng unit và stockQuantity
        Product(
          id: 'banana',
          name: 'Chuối tây',
          price: 3000.0,
          unit: 'nải',
          stockQuantity: 15,
        ),
        Product(
          id: 'apple',
          name: 'Táo đỏ',
          price: 20000.0,
          unit: 'kg',
          stockQuantity: 50,
        ),
        Product(
          id: 'coke',
          name: 'Nước Coke',
          price: 10000.0,
          unit: 'lon',
          stockQuantity: 100,
        ),
        Product(
          id: 'diet_coke',
          name: 'Diet Coke',
          price: 12000.0,
          unit: 'lon',
          stockQuantity: 80,
        ),
        Product(
          id: 'tomato',
          name: 'Cà chua',
          price: 15000.0,
          unit: 'kg',
          stockQuantity: 60,
        ),
        Product(
          id: 'brocoli',
          name: 'Bông cải',
          price: 25000.0,
          unit: 'cây',
          stockQuantity: 30,
        ),
      ];

      // Save using product.id as the Hive key so lookups by id work
      for (final p in sampleProducts) {
        await box.put(p.id, p);
      }
      // 💡 ĐÃ SỬA LỖI: Dùng print thay cho debugPrint
      print(
        '--- ĐÃ XÓA VÀ TẠO ${sampleProducts.length} SẢN PHẨM MẪU THÀNH CÔNG ---',
      );
    }
  }

  static Future<void> seedUsers() async {
    final box = users();
    if (box.isEmpty) {
      box.add(User(email: 'abc', password: '123', role: 'owner'));
      box.add(User(email: 'xyz', password: '123', role: 'staff'));
    }
  }

  // Migrate products stored with numeric keys to use product.id as key.
  // This ensures products().get(productId) works correctly.
  static Future<void> _migrateProductsToIdKeys() async {
    final box = products();
    // Copy current mapping to avoid concurrent modification while iterating
    final current = Map<dynamic, Product>.from(
      box.toMap().cast<dynamic, Product>(),
    );
    for (final e in current.entries) {
      final key = e.key;
      final product = e.value;
      if (key is! String) {
        // Move entry to use product.id as key
        await box.put(product.id, product);
        await box.delete(key);
      }
    }
  }

  // --- LOGIC QUẢN LÝ KHO & BÁN HÀNG ---

  // Tên hàm đã được chuẩn hóa là saveOrder
  static Future<void> saveOrder(Order order) async {
    await orders().put(order.id, order);

    // Cập nhật tồn kho
    for (var line in order.items) {
      final product = products().get(line.productId);
      if (product != null) {
        product.stockQuantity -= line.quantity;
        // Đảm bảo tồn kho không âm
        if (product.stockQuantity < 0) {
          product.stockQuantity = 0;
        }
        await product.save(); // Lưu lại sản phẩm đã được cập nhật tồn kho
      }
    }
  }

  static List<Product> getAllProducts() {
    return products().values.toList();
  }

  static List<Order> getAllOrders() {
    final allOrders = orders().values.cast<Order>().toList();
    // Sắp xếp đơn hàng mới nhất lên đầu
    allOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return allOrders;
  }

  static int getOrderCount() {
    return orders().length;
  }

  static double getTotalRevenue() {
    // Tính tổng doanh thu từ tất cả các đơn hàng
    return orders().values.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  static Map<String, int> getCartForUser(String email) {
    final raw = carts().get(email);
    if (raw == null) return <String, int>{};
    try {
      return Map<String, int>.from(raw as Map);
    } catch (_) {
      return <String, int>{};
    }
  }

  static Future<void> saveCartForUser(
    String email,
    Map<String, int> cart,
  ) async {
    final Map<String, int> cleanCart = Map.from(cart)
      ..removeWhere((key, value) => value <= 0);
    await carts().put(email, cleanCart);
  }

  static List<Product> searchProducts(String query, List<Product> source) {
    if (query.isEmpty) {
      return source;
    }
    final lowerQuery = query.toLowerCase();
    return source
        .where(
          (p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              p.id.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}
