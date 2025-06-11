import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';

class EmployeeService {
  // Base URL for the API
  final String baseUrl =
      'https://employeemangementapi-production.up.railway.app/employees';

  // GET /employees - Fetch all employees
  Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  // GET /employees/{id} - Fetch a specific employee
  Future<Employee> fetchEmployeeById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Employee.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load employee with ID: $id');
    }
  }

  // POST /employees - Create a new employee
  Future<void> createEmployees(List<Employee> employees) async {
    final url = Uri.parse(baseUrl);
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode(
      employees.map((e) => e.toJson()).toList(),
    );

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create employees');
    }
  }

  // POST /employees - Create multiple employees
  Future<String> createMultipleEmployees(List<Employee> employees) async {
    final List<Map<String, dynamic>> employeeJsonList =
        employees.map((employee) => employee.toJson()).toList();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(employeeJsonList),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return 'Employees created successfully';
    } else {
      throw Exception('Failed to create employees: ${response.body}');
    }
  }

// PUT /employees/{id} - Update an existing employee
  Future<String> updateEmployee(Employee employee) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${employee.id}'), // corrected URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(employee.toJson()),
    );

    if (response.statusCode == 200) {
      return response.body; // returns: "Employee updated successfully"
    } else {
      throw Exception('Failed to update employee');
    }
  }

  // DELETE /employees/{id} - Delete an employee
  Future<bool> deleteEmployee(int id) async {
    // final response = await http.delete(Uri.parse('$baseUrl/$id'));

    await http.delete(Uri.parse('$baseUrl/$id'));

    // if (response.statusCode == 204) {
    return true;
    // } else {
    //   throw Exception('Failed to delete employee');
    // }
  }

  // Search employees by name or department
  Future<List<Employee>> searchEmployees(String query) async {
    final employees = await fetchEmployees();

    if (query.isEmpty) {
      return employees;
    }

    final lowercaseQuery = query.toLowerCase();
    return employees.where((employee) {
      return employee.name.toLowerCase().contains(lowercaseQuery) ||
          employee.department.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
