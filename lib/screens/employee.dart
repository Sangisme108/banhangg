import 'package:flutter/material.dart';
import 'add_employee_screen.dart';

class Employee {
  final String name;
  final String role;
  final String phone;
  final String status;
  final Color statusColor;

  const Employee({
    required this.name,
    required this.role,
    required this.phone,
    required this.status,
    required this.statusColor,
  });
}

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final List<Employee> _employees = [
    const Employee(
      name: 'Nguyễn Văn A',
      role: 'Quản lý',
      phone: '0901xxx123',
      status: 'Đang làm',
      statusColor: Colors.green,
    ),
    const Employee(
      name: 'Trần Thị B',
      role: 'Nhân viên bán hàng',
      phone: '0902xxx456',
      status: 'Đang làm',
      statusColor: Colors.green,
    ),
    const Employee(
      name: 'Lê Văn C',
      role: 'Kho',
      phone: '0903xxx789',
      status: 'Nghỉ việc',
      statusColor: Colors.red,
    ),
  ];

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
              color: employee.statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Xoá ${employee.name}?'),
              content: const Text('Bạn có chắc muốn xoá nhân viên này không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Huỷ'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _employees.remove(employee);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã xoá ${employee.name}')),
                    );
                  },
                  child: const Text('Xoá', style: TextStyle(color: Colors.red)),
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
        title: const Text('Quản lý nhân viên', style: TextStyle(fontWeight: FontWeight.bold)),
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
            onPressed: () async {
              final newEmployee = await Navigator.push<Employee>(
                context,
                MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
              );

              if (newEmployee != null) {
                setState(() {
                  _employees.add(newEmployee);
                });
              }
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
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                return _buildEmployeeTile(_employees[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
