import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../widgets/custom_form_fields.dart';

class UpdateEmployeeScreen extends StatefulWidget {
  final Employee employee;

  const UpdateEmployeeScreen({Key? key, required this.employee})
      : super(key: key);

  @override
  State<UpdateEmployeeScreen> createState() => _UpdateEmployeeScreenState();
}

class _UpdateEmployeeScreenState extends State<UpdateEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _salaryController;

  String? _selectedDepartment;
  String? _selectedPosition;
  bool _isLoading = false;

  final List<String> _departments = [
    'Engineering',
    'Marketing',
    'Finance',
    'Human Resources',
    'Sales',
    'Operations',
    'Research & Development',
    'Customer Support',
  ];

  final List<String> _positions = [
    'Manager',
    'Director',
    'Team Lead',
    'Senior Developer',
    'Junior Developer',
    'Intern',
    'Analyst',
    'Specialist',
    'Coordinator',
  ];

  final EmployeeService _service = EmployeeService();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.employee.name);
    _ageController = TextEditingController(
      text: widget.employee.age.toString(),
    );
    _emailController = TextEditingController(text: widget.employee.email);
    _phoneController = TextEditingController(text: widget.employee.phone);
    _addressController = TextEditingController(text: widget.employee.address);
    _salaryController = TextEditingController(
      text: widget.employee.salary.toString(),
    );

    // Ensure department exists in the list, otherwise use the first item
    _selectedDepartment = _departments.contains(widget.employee.department)
        ? widget.employee.department
        : _departments.isNotEmpty
            ? _departments[0]
            : null;

    // Ensure position exists in the list, otherwise use the first item
    _selectedPosition = _positions.contains(widget.employee.position)
        ? widget.employee.position
        : _positions.isNotEmpty
            ? _positions[0]
            : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedEmployee = Employee(
          id: widget.employee.id,
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          department: _selectedDepartment!,
          position: _selectedPosition!,
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          salary: double.parse(_salaryController.text.trim()),
        );

        await _service.updateEmployee(updatedEmployee);
        if (!mounted) return;

        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update employee: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Employee')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter employee name',
                controller: _nameController,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              CustomNumberField(
                label: 'Age',
                hint: 'Enter employee age',
                controller: _ageController,
                prefixIcon: Icons.cake,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  final age = int.tryParse(value);
                  if (age == null) {
                    return 'Please enter a valid age';
                  }
                  if (age < 18 || age > 100) {
                    return 'Age must be between 18 and 100';
                  }
                  return null;
                },
              ),
              CustomTextField(
                label: 'Email',
                hint: 'Enter employee email',
                controller: _emailController,
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              CustomTextField(
                label: 'Phone',
                hint: 'Enter employee phone',
                controller: _phoneController,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              CustomTextField(
                label: 'Address',
                hint: 'Enter employee address',
                controller: _addressController,
                prefixIcon: Icons.location_on,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              CustomDropdownField(
                label: 'Department',
                value: _selectedDepartment,
                items: _departments,
                prefixIcon: Icons.business,
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a department';
                  }
                  return null;
                },
              ),
              CustomDropdownField(
                label: 'Position',
                value: _selectedPosition,
                items: _positions,
                prefixIcon: Icons.work,
                onChanged: (value) {
                  setState(() {
                    _selectedPosition = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a position';
                  }
                  return null;
                },
              ),
              CustomNumberField(
                label: 'Salary',
                hint: 'Enter employee salary',
                controller: _salaryController,
                prefixIcon: Icons.attach_money,
                allowDecimal: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a salary';
                  }
                  final salary = double.tryParse(value);
                  if (salary == null) {
                    return 'Please enter a valid salary';
                  }
                  if (salary < 0) {
                    return 'Salary cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Update Employee',
                icon: Icons.save,
                isLoading: _isLoading,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
