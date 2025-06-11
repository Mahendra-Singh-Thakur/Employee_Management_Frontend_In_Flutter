class Employee {
  final int? id;
  final String name;
  final int age;
  final String department;
  final String position;
  final String email;
  final String phone;
  final String address;
  final double salary;

  Employee({
    this.id,
    required this.name,
    required this.age,
    required this.department,
    required this.position,
    required this.email,
    required this.phone,
    required this.address,
    required this.salary,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      department: json['department'],
      position: json['position'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      salary: (json['salary'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'age': age,
      'department': department,
      'position': position,
      'email': email,
      'phone': phone,
      'address': address,
      'salary': salary,
    };
  }

  Employee copyWith({
    int? id,
    String? name,
    int? age,
    String? department,
    String? position,
    String? email,
    String? phone,
    String? address,
    double? salary,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      department: department ?? this.department,
      position: position ?? this.position,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      salary: salary ?? this.salary,
    );
  }
}
