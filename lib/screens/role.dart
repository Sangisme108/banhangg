import 'package:flutter/material.dart';
import 'add_role_screen.dart'; // ✅ nhớ import file vừa tạo

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

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  final List<AppRole> _roles = [
    const AppRole(
      name: 'Owner (Chủ cửa hàng)',
      description: 'Toàn quyền quản lý, bao gồm cả nhân viên và vai trò.',
      employeeCount: 1,
    ),
    const AppRole(
      name: 'Quản lý',
      description: 'Quản lý sản phẩm, kho hàng, và xem báo cáo doanh thu.',
      employeeCount: 2,
    ),
    const AppRole(
      name: 'Nhân viên bán hàng',
      description: 'Thực hiện giao dịch thanh toán và xem sản phẩm.',
      employeeCount: 5,
    ),
    const AppRole(
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
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey),
        onTap: () {
          // Nhấn vào vai trò → hiển thị dialog xoá
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Xoá vai trò "${role.name}"?'),
              content: const Text('Bạn có chắc muốn xoá vai trò này không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Huỷ'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _roles.remove(role);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã xoá vai trò "${role.name}"')),
                    );
                  },
                  child:
                  const Text('Xoá', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
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
            onPressed: () async {
              final newRole = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRoleScreen()),
              );

              if (newRole != null && newRole is AppRole) {
                setState(() {
                  _roles.add(newRole);
                });
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _roles.length,
        itemBuilder: (context, index) {
          return _buildRoleTile(_roles[index]);
        },
      ),
    );
  }
}
