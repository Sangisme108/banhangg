import 'package:flutter/material.dart';

// Mô phỏng dữ liệu nhân viên
class Employee {
  final String name;
  final String role;
  final String email;
  final String phone;
  final String status;
  final Color statusColor;

  const Employee({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.status,
    required this.statusColor,
  });
}

class EmployeeManagementScreen extends StatelessWidget {
  const EmployeeManagementScreen({super.key});

  final List<Employee> _sampleEmployees = const [
    Employee(
      name: 'Nguyễn Văn A',
      role: 'Quản lý',
      email: 'a.nguyen@email.com',
      phone: '0901xxx123',
      status: 'Đang làm',
      statusColor: Colors.green,
    ),
    Employee(
      name: 'Trần Thị B',
      role: 'Nhân viên bán hàng',
      email: 'b.tran@email.com',
      phone: '0902xxx456',
      status: 'Đang làm',
      statusColor: Colors.green,
    ),
    Employee(
      name: 'Lê Văn C',
      role: 'Kho',
      email: 'c.le@email.com',
      phone: '0903xxx789',
      status: 'Nghỉ việc',
      statusColor: Colors.red,
    ),
  ];

  // Widget hiển thị mỗi dòng nhân viên
  Widget _buildEmployeeTile(Employee employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF4C7FFF),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(employee.role, style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13)),
            Text(employee.phone, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: employee.statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            employee.status,
            style: TextStyle(
              color: employee.statusColor.withOpacity(1.0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          // Logic xem chi tiết nhân viên
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý nhân viên',
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
            icon: const Icon(Icons.person_add_alt_1, size: 30),
            onPressed: () {
              // Logic Thêm nhân viên mới
            },
          ),
          const SizedBox(width: 8),
        ],
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
                        hintText: 'Tìm kiếm nhân viên',
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

          // Danh sách nhân viên
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0).copyWith(top: 8),
              itemCount: _sampleEmployees.length,
              itemBuilder: (context, index) {
                return _buildEmployeeTile(_sampleEmployees[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}