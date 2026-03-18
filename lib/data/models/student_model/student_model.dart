class StudentModel {
  final String uid;
  final String indexNumber;
  final String campusId;
  final String nic;
  final String phone;
  final String dob;
  final String department;
  final String degree;
  final String intake;

  StudentModel({
    required this.uid,
    required this.indexNumber,
    required this.campusId,
    required this.nic,
    required this.phone,
    required this.dob,
    required this.department,
    required this.degree,
    required this.intake,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uid: map['uid'],
      indexNumber: map['indexNumber'],
      campusId: map['campusId'],
      nic: map['nic'],
      phone: map['phone'],
      dob: map['dob'],
      department: map['department'],
      degree: map['degree'],
      intake: map['intake'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'indexNumber': indexNumber,
      'campusId': campusId,
      'nic': nic,
      'phone': phone,
      'dob': dob,
      'department': department,
      'degree': degree,
      'intake': intake,
    };
  }
}