class TimetableSlot {
  final int? id;
  final String? firestoreId; 
  final int courseId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String roomNumber;
  final String building;
  final String type;
  
  String? courseCode;
  String? courseName;
  String? lecturerName;

  TimetableSlot({
    this.id,
    this.firestoreId,  
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
      'firestoreId': firestoreId,  
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
      firestoreId: map['firestoreId'],  
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