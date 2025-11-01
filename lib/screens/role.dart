import 'package:flutter/material.dart';

// Mô phỏng dữ liệu vai trò
class AppRole {
  final String name;
  final String description;
  final int employeeCount;

  const AppRole({
    required this.name,
    required this.description,
    required this.employeeCount,
  });
}

class RoleManagementScreen extends StatelessWidget {
  const RoleManagementScreen({super.key});

  final List<AppRole> _sampleRoles = const [
    AppRole(
      name: 'Owner (Chủ cửa hàng)',
      description: 'Toàn quyền quản lý, bao gồm cả nhân viên và vai trò.',
      employeeCount: 1,
    ),
    AppRole(
      name: 'Quản lý',
      description: 'Quản lý sản phẩm, kho hàng, và xem báo cáo doanh thu.',
      employeeCount: 2,
    ),
    AppRole(
      name: 'Nhân viên bán hàng',
      description: 'Thực hiện giao dịch thanh toán và xem sản phẩm.',
      employeeCount: 5,
    ),
    AppRole(
      name: 'Kho',
      description: 'Chỉ được phép quản lý nhập/xuất kho.',
      employeeCount: 3,
    ),
  ];

  // Widget hiển thị mỗi dòng vai trò
  Widget _buildRoleTile(AppRole role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        title: Text(
          role.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              role.description,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Số nhân viên: ${role.employeeCount}',
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Logic chỉnh sửa quyền hạn vai trò
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý vai trò',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 30),
            onPressed: () {
              // Logic Thêm vai trò mới
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _sampleRoles.length,
        itemBuilder: (context, index) {
          return _buildRoleTile(_sampleRoles[index]);
        },
      ),
    );
  }
}