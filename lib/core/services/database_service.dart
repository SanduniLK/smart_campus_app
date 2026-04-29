import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    // ✅ Return existing database if already open
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'smart_campus.db');
    
    print('📂 Opening database at: $path');
    
    // ✅ NO DELETION - Just open existing
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      singleInstance: true,  // ✅ Prevent multiple instances
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('📦 Creating new database...');
    
    await db.execute('''
      CREATE TABLE users(
        uid TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        fullName TEXT,
        role TEXT,
        staffType TEXT,
        isEmailVerified INTEGER DEFAULT 0,
        createdAt TEXT,
        lastLoginAt TEXT,
        phone TEXT,
        department TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE students(
        uid TEXT PRIMARY KEY,
        indexNumber TEXT,
        campusId TEXT,
        nic TEXT,
        phone TEXT,
        dob TEXT,
        department TEXT,
        degree TEXT,
        intake TEXT,
        currentSemester INTEGER DEFAULT 1,
        batchYear INTEGER,
        FOREIGN KEY (uid) REFERENCES users(uid) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE staff(
        uid TEXT PRIMARY KEY,
        staffId TEXT,
        faculty TEXT,
        department TEXT,
        staffType TEXT,
        position TEXT,
        workLocation TEXT,
        FOREIGN KEY (uid) REFERENCES users(uid) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseCode TEXT NOT NULL,
        courseName TEXT NOT NULL,
        credits INTEGER DEFAULT 3,
        lecturerName TEXT NOT NULL,
        batchYear TEXT,
        department TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE timetable_slots(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseId INTEGER NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        roomNumber TEXT NOT NULL,
        building TEXT NOT NULL,
        type TEXT DEFAULT 'Lecture',
        FOREIGN KEY (courseId) REFERENCES courses(id) ON DELETE CASCADE
      )
    ''');
    
    print('✅ Database created');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
      } catch (e) {}
      try {
        await db.execute('ALTER TABLE users ADD COLUMN department TEXT');
      } catch (e) {}
    }
  }

  // ✅ Close database when done (call this on app exit)
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  // ==================== YOUR EXISTING METHODS ====================
  
  Future<void> insertOrUpdateUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert('users', userData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    final db = await database;
    final result = await db.query('users', where: 'uid = ?', whereArgs: [uid]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateLastLogin(String uid) async {
    final db = await database;
    await db.update('users', {'lastLoginAt': DateTime.now().toIso8601String()}, where: 'uid = ?', whereArgs: [uid]);
  }

  Future<void> updateEmailVerificationStatus(String uid, bool isVerified) async {
    final db = await database;
    await db.update('users', {'isEmailVerified': isVerified ? 1 : 0}, where: 'uid = ?', whereArgs: [uid]);
  }

  Future<void> insertStudentDetails(Map<String, dynamic> studentData) async {
    final db = await database;
    await db.insert('students', studentData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getStudentDetails(String uid) async {
    final db = await database;
    final result = await db.query('students', where: 'uid = ?', whereArgs: [uid]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> insertStaffDetails(Map<String, dynamic> staffData) async {
    final db = await database;
    await db.insert('staff', staffData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getStaffDetails(String uid) async {
    final db = await database;
    final result = await db.query('staff', where: 'uid = ?', whereArgs: [uid]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertCourse(Map<String, dynamic> courseData) async {
    final db = await database;
    return await db.insert('courses', courseData);
  }

  Future<List<Map<String, dynamic>>> getAllCourses() async {
    final db = await database;
    return await db.query('courses');
  }

  Future<int> insertTimetableSlot(Map<String, dynamic> slotData) async {
    final db = await database;
    return await db.insert('timetable_slots', slotData);
  }

  Future<List<Map<String, dynamic>>> getTimetableByDay(int dayOfWeek) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ts.*, c.courseCode, c.courseName, c.lecturerName 
      FROM timetable_slots ts
      INNER JOIN courses c ON ts.courseId = c.id
      WHERE ts.dayOfWeek = ?
      ORDER BY ts.startTime
    ''', [dayOfWeek]);
  }

  Future<void> recordLogin(String uid) async {
    print('📝 Login recorded for: $uid');
    await updateLastLogin(uid);
  }

  Future<void> recordLogout(String uid) async {
    print('📝 Logout recorded for: $uid');
  }

  Future<Map<String, dynamic>?> getCompleteUserProfile(String uid) async {
    final userData = await getUserByUid(uid);
    if (userData == null) return null;
    return userData;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }
}