import 'dart:convert';
import 'package:http/http.dart' as http;
import 'employee.dart';

class EmployeeService {
  // final String baseUrl = 'http://192.168.1.10:9090/employees';
  final String baseUrl =
      'https://employeemangementapi-production.up.railway.app/employees';

  Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }
}
