// මෙය Model class එකක්, Widget එකක් නෙවෙයි
class ProgressStatsModel {
  final double attendance;
  final double gpa;
  final int completedCredits;

  ProgressStatsModel({
    required this.attendance,
    required this.gpa,
    required this.completedCredits,
  });
}

class ClassModel {
  final String code;
  final String name;
  final String time;
  final String room;
  final String lecturer;
  final bool isNext;

  ClassModel({
    required this.code,
    required this.name,
    required this.time,
    required this.room,
    required this.lecturer,
    this.isNext = false,
  });
}

class EventModel {
  final String title;
  final String date;
  final String location;
  final String emoji;
  final bool isRegistered;

  EventModel({
    required this.title,
    required this.date,
    required this.location,
    required this.emoji,
    this.isRegistered = false,
  });
}

class AnnouncementModel {
  final String emoji;
  final String title;
  final String description;
  final String time;
  final bool isUrgent;

  AnnouncementModel({
    required this.emoji,
    required this.title,
    required this.description,
    required this.time,
    this.isUrgent = false,
  });
}