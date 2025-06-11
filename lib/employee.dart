class Employee {
  final int id;
  final String name;
  final int age;
  final String department;
  final String position;
  final String email;
  final String phone;
  final String address;
  final double salary;

  Employee({
    required this.id,
    required this.name,
    required this.age,
    required this.department,
    required this.position,
    required this.email,
    required this.phone,
    required this.address,
    required this.salary,
  });

  factory Employee.fromJson(Map<String, dynamic> Mapjson) {
    return Employee(
      id: Mapjson['id'],
      name: Mapjson['name'],
      age: Mapjson['age'],
      department: Mapjson['department'],
      position: Mapjson['position'],
      email: Mapjson['email'],
      phone: Mapjson['phone'],
      address: Mapjson['address'],
      salary: (Mapjson['salary'] as num).toDouble(),
    );
  }
}
