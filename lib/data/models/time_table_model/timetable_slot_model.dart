class TimetableSlot {
  final int? id;
  final int courseId;
  final int dayOfWeek;  // 1=Monday, 2=Tuesday... 6=Saturday, 7=Sunday
  final String startTime;
  final String endTime;
  final String roomNumber;
  final String building;
  final String type;  // Lecture, Lab, Tutorial
  
  // For display (joined from courses)
  String? courseCode;
  String? courseName;
  String? lecturerName;

  TimetableSlot({
    this.id,
    required this.courseId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
    required this.building,
    required this.type,
    this.courseCode,
    this.courseName,
    this.lecturerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'roomNumber': roomNumber,
      'building': building,
      'type': type,
    };
  }

  factory TimetableSlot.fromMap(Map<String, dynamic> map) {
    return TimetableSlot(
      id: map['id'],
      courseId: map['courseId'],
      dayOfWeek: map['dayOfWeek'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      roomNumber: map['roomNumber'],
      building: map['building'],
      type: map['type'],
      courseCode: map['courseCode'],
      courseName: map['courseName'],
      lecturerName: map['lecturerName'],
    );
  }
}