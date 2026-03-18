class StaffModel {
  final String uid;
  final String staffId;
  final String faculty;      // Added faculty
  final String department;    // Added department
  final String designation;
  final String phone;
  final String? officeLocation;

  StaffModel({
    required this.uid,
    required this.staffId,
    required this.faculty,
    required this.department,
    required this.designation,
    required this.phone,
    this.officeLocation,
  });

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      uid: map['uid'] ?? '',
      staffId: map['staffId'] ?? '',
      faculty: map['faculty'] ?? '',
      department: map['department'] ?? '',
      designation: map['designation'] ?? '',
      phone: map['phone'] ?? '',
      officeLocation: map['officeLocation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'staffId': staffId,
      'faculty': faculty,
      'department': department,
      'designation': designation,
      'phone': phone,
      'officeLocation': officeLocation,
    };
  }
}