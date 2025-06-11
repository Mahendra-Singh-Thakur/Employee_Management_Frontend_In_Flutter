import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import 'update_employee_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailScreen({Key? key, required this.employeeId})
      : super(key: key);

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  final EmployeeService _service = EmployeeService();
  late Future<Employee> _employeeFuture;

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  void _loadEmployee() {
    _employeeFuture = _service.fetchEmployeeById(widget.employeeId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // Return true to trigger refresh
        return false; // Prevent default back behavior since we're handling it
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employee Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final employee = await _employeeFuture;
                if (!mounted) return;

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UpdateEmployeeScreen(employee: employee),
                  ),
                );

                if (result == true) {
                  setState(() {
                    _loadEmployee();
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Employee updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: FutureBuilder<Employee>(
          future: _employeeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Employee not found'));
            }

            final employee = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(employee),
                  const SizedBox(height: 24),
                  _buildInfoSection('Personal Information', [
                    _buildInfoRow(Icons.person, 'Name', employee.name),
                    _buildInfoRow(Icons.cake, 'Age', '${employee.age} years'),
                    _buildInfoRow(Icons.email, 'Email', employee.email),
                    _buildInfoRow(Icons.phone, 'Phone', employee.phone),
                    _buildInfoRow(
                        Icons.location_on, 'Address', employee.address),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoSection('Employment Information', [
                    _buildInfoRow(
                      Icons.business,
                      'Department',
                      employee.department,
                    ),
                    _buildInfoRow(Icons.work, 'Position', employee.position),
                    _buildInfoRow(
                      Icons.attach_money,
                      'Salary',
                      '₹${employee.salary.toStringAsFixed(2)}',
                    ),
                  ]),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Employee employee) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              employee.name,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              employee.position,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              employee.department,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
