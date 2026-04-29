class Course {
  final int? id;
  final String courseCode;
  final String courseName;
  final int credits;
  final String lecturerName;
  final String batchYear;
  final String department;

  Course({
    this.id,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.lecturerName,
    required this.batchYear,
    required this.department,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'credits': credits,
      'lecturerName': lecturerName,
      'batchYear': batchYear,
      'department': department,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      courseCode: map['courseCode'],
      courseName: map['courseName'],
      credits: map['credits'],
      lecturerName: map['lecturerName'],
      batchYear: map['batchYear'],
      department: map['department'],
    );
  }
}