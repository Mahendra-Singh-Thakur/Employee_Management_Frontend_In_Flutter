import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../widgets/employee_card.dart';
import 'employee_detail_screen.dart';
import 'create_employee_screen.dart';
import 'create_multiple_employees_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final EmployeeService _service = EmployeeService();
  final TextEditingController _searchController = TextEditingController();
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final employees = await _service.fetchEmployees();
      setState(() {
        _employees = employees;
        _filteredEmployees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterEmployees(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredEmployees = _employees;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        return employee.name.toLowerCase().contains(lowercaseQuery) ||
            employee.department.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  Future<void> _deleteEmployee(int id) async {
    try {
      await _service.deleteEmployee(id);
      _loadEmployees();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete employee: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              // Toggle theme
              final brightness = Theme.of(context).brightness;
              final themeMode = brightness == Brightness.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              // This would typically be handled by a theme provider
              // For now, we'll just show a message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Theme would change to ${themeMode == ThemeMode.light ? "light" : "dark"}',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or department',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterEmployees('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterEmployees,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text('Error: $_errorMessage'))
                    : _filteredEmployees.isEmpty
                        ? const Center(child: Text('No employees found'))
                        : RefreshIndicator(
                            onRefresh: _loadEmployees,
                            child: ListView.builder(
                              itemCount: _filteredEmployees.length,
                              padding: const EdgeInsets.all(8.0),
                              itemBuilder: (context, index) {
                                final employee = _filteredEmployees[index];
                                return EmployeeCard(
                                  employee: employee,
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EmployeeDetailScreen(
                                          employeeId: employee.id!,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadEmployees();
                                    }
                                  },
                                  onDelete: () => _deleteEmployee(employee.id!),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btn2',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEmployeeScreen(),
                ),
              );
              if (result == true) {
                _loadEmployees();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Emp'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'btn1',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateMultipleEmployeesScreen(),
                ),
              );
              if (result == true) {
                _loadEmployees();
              }
            },
            icon: const Icon(Icons.group_add),
            label: const Text('Add Multiple'),
            // backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}
