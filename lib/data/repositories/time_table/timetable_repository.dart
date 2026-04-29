import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/data/models/time_table_model/course_model.dart';
import 'package:smart_campus_app/data/models/time_table_model/timetable_slot_model.dart';
import 'package:sqflite/sqflite.dart';

class TimetableRepository {
  final DatabaseService _dbService = DatabaseService();

  // ==================== COURSE OPERATIONS ====================

  Future<int> addCourse(Course course) async {
    final db = await _dbService.database;
    return await db.insert('courses', course.toMap());
  }

  Future<List<Course>> getAllCourses() async {
    final db = await _dbService.database;
    final result = await db.query('courses', orderBy: 'courseCode');
    return result.map((map) => Course.fromMap(map)).toList();
  }

  Future<Course?> getCourseById(int id) async {
    final db = await _dbService.database;
    final result = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Course.fromMap(result.first);
  }

  Future<int> deleteCourse(int id) async {
    final db = await _dbService.database;
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== TIMETABLE SLOT OPERATIONS ====================

  Future<int> addTimetableSlot(TimetableSlot slot) async {
    final db = await _dbService.database;
    
    // Check for conflicts
    final conflicts = await _checkConflicts(slot);
    if (conflicts.isNotEmpty) {
      throw Exception('Time or room conflict with existing slot');
    }
    
    return await db.insert('timetable_slots', slot.toMap());
  }

  Future<List<TimetableSlot>> getAllTimetableSlots() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT ts.*, c.courseCode, c.courseName, c.lecturerName 
      FROM timetable_slots ts
      INNER JOIN courses c ON ts.courseId = c.id
      ORDER BY ts.dayOfWeek, ts.startTime
    ''');
    return result.map((map) => TimetableSlot.fromMap(map)).toList();
  }

  Future<List<TimetableSlot>> getTimetableByDay(int dayOfWeek) async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT ts.*, c.courseCode, c.courseName, c.lecturerName 
      FROM timetable_slots ts
      INNER JOIN courses c ON ts.courseId = c.id
      WHERE ts.dayOfWeek = ?
      ORDER BY ts.startTime
    ''', [dayOfWeek]);
    return result.map((map) => TimetableSlot.fromMap(map)).toList();
  }

  Future<List<TimetableSlot>> getTimetableByBatch(String batchYear, String department) async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT ts.*, c.courseCode, c.courseName, c.lecturerName 
      FROM timetable_slots ts
      INNER JOIN courses c ON ts.courseId = c.id
      WHERE c.batchYear = ? AND c.department = ?
      ORDER BY ts.dayOfWeek, ts.startTime
    ''', [batchYear, department]);
    return result.map((map) => TimetableSlot.fromMap(map)).toList();
  }

  Future<int> updateTimetableSlot(TimetableSlot slot) async {
    final db = await _dbService.database;
    return await db.update(
      'timetable_slots',
      slot.toMap(),
      where: 'id = ?',
      whereArgs: [slot.id],
    );
  }

  Future<int> deleteTimetableSlot(int id) async {
    final db = await _dbService.database;
    return await db.delete('timetable_slots', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TimetableSlot>> _checkConflicts(TimetableSlot newSlot) async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT ts.*, c.courseCode, c.courseName 
      FROM timetable_slots ts
      INNER JOIN courses c ON ts.courseId = c.id
      WHERE ts.dayOfWeek = ? 
        AND ts.roomNumber = ?
        AND ts.startTime = ?
    ''', [newSlot.dayOfWeek, newSlot.roomNumber, newSlot.startTime]);
    return result.map((map) => TimetableSlot.fromMap(map)).toList();
  }
}