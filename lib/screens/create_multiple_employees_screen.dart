import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../widgets/custom_form_fields.dart';

class CreateMultipleEmployeesScreen extends StatefulWidget {
  const CreateMultipleEmployeesScreen({Key? key}) : super(key: key);

  @override
  State<CreateMultipleEmployeesScreen> createState() =>
      _CreateMultipleEmployeesScreenState();
}

class _CreateMultipleEmployeesScreenState
    extends State<CreateMultipleEmployeesScreen> {
  final List<EmployeeFormData> _employeeForms = [];
  bool _isLoading = false;
  final EmployeeService _service = EmployeeService();

  @override
  void initState() {
    super.initState();
    // Start with one employee form
    _addEmployeeForm();
  }

  void _addEmployeeForm() {
    setState(() {
      _employeeForms.add(EmployeeFormData());
    });
  }

  void _removeEmployeeForm(int index) {
    if (_employeeForms.length > 1) {
      setState(() {
        _employeeForms.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least one employee form'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _submitForms() async {
    // Validate all forms
    bool allValid = true;
    for (var form in _employeeForms) {
      if (!form.formKey.currentState!.validate()) {
        allValid = false;
      }
    }

    if (!allValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the forms'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a list of employee objects
      List<Employee> employees = _employeeForms
          .map((form) => Employee(
                name: form.nameController.text.trim(),
                age: int.parse(form.ageController.text.trim()),
                department: form.selectedDepartment!,
                position: form.selectedPosition!,
                email: form.emailController.text.trim(),
                phone: form.phoneController.text.trim(),
                address: form.addressController.text.trim(),
                salary: double.parse(form.salaryController.text.trim()),
              ))
          .toList();

      // Use the service to create multiple employees
      final result = await _service.createMultipleEmployees(employees);

      setState(() {
        _isLoading = false;
      });

      if (result == 'Employees created successfully') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employees created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create employees '),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Multiple Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submitForms,
            tooltip: 'Save All',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Multiple Employees',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Fill out the forms below to add multiple employees at once. All fields are required.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _employeeForms.length,
                    itemBuilder: (context, index) {
                      return EmployeeFormCard(
                        formData: _employeeForms[index],
                        index: index,
                        onRemove: () => _removeEmployeeForm(index),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Add Another Employee',
                    icon: Icons.add,
                    onPressed: _addEmployeeForm,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Submit All Employees',
                    icon: Icons.save,
                    isLoading: _isLoading,
                    onPressed: _submitForms,
                  ),
                ],
              ),
            ),
    );
  }
}

class EmployeeFormData {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final salaryController = TextEditingController();

  String? selectedDepartment;
  String? selectedPosition;

  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    salaryController.dispose();
  }
}

class EmployeeFormCard extends StatefulWidget {
  final EmployeeFormData formData;
  final int index;
  final VoidCallback onRemove;

  const EmployeeFormCard({
    Key? key,
    required this.formData,
    required this.index,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<EmployeeFormCard> createState() => _EmployeeFormCardState();
}

class _EmployeeFormCardState extends State<EmployeeFormCard> {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: widget.formData.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Employee ${widget.index + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onRemove,
                    tooltip: 'Remove',
                  ),
                ],
              ),
              const Divider(),
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter employee name',
                controller: widget.formData.nameController,
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
                controller: widget.formData.ageController,
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
                controller: widget.formData.emailController,
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
                controller: widget.formData.phoneController,
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
                controller: widget.formData.addressController,
                prefixIcon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              CustomDropdownField(
                label: 'Department',
                value: widget.formData.selectedDepartment,
                items: _departments,
                prefixIcon: Icons.business,
                onChanged: (value) {
                  setState(() {
                    widget.formData.selectedDepartment = value;
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
                value: widget.formData.selectedPosition,
                items: _positions,
                prefixIcon: Icons.work,
                onChanged: (value) {
                  setState(() {
                    widget.formData.selectedPosition = value;
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
                controller: widget.formData.salaryController,
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
            ],
          ),
        ),
      ),
    );
  }
}
