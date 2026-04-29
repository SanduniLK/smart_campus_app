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
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, 'smart_campus.db');
  
  // 🔥 TEMPORARY - DELETE OLD DATABASE (RUN ONCE)
  if (await File(path).exists()) {
    print('🗑️ Deleting old database...');
    await File(path).delete();
  }
  
  return await openDatabase(
    path,
    version: 1,
    onCreate: _onCreate,
  );
}

Future<void> _onCreate(Database db, int version) async {
  print('📦 Creating fresh database...');

  // Users Table
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

  // Students Table
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

  // Staff Table
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

  // Courses Table
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

  // Timetable Slots Table - FIXED TYPO (courseId not courseld)
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

  print('✅ Database created with all tables!');
}
  // ==================== USER OPERATIONS ====================
  
  Future<void> insertOrUpdateUser(Map<String, dynamic> userData) async {
    final db = await database;
    try {
      await db.insert(
        'users',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ User saved: ${userData['uid']}');
    } catch (e) {
      print('❌ Error saving user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    final db = await database;
    final result = await db.query('users', where: 'uid = ?', whereArgs: [uid]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateLastLogin(String uid) async {
    final db = await database;
    await db.update(
      'users',
      {'lastLoginAt': DateTime.now().toIso8601String()},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  Future<void> updateEmailVerificationStatus(String uid, bool isVerified) async {
    final db = await database;
    await db.update(
      'users',
      {'isEmailVerified': isVerified ? 1 : 0},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // ==================== STUDENT OPERATIONS ====================

  Future<void> insertStudentDetails(Map<String, dynamic> studentData) async {
    final db = await database;
    await db.insert('students', studentData, conflictAlgorithm: ConflictAlgorithm.replace);
    print('✅ Student details saved');
  }

  Future<Map<String, dynamic>?> getStudentDetails(String uid) async {
    final db = await database;
    final result = await db.query('students', where: 'uid = ?', whereArgs: [uid]);
    return result.isNotEmpty ? result.first : null;
  }

  // ==================== STAFF OPERATIONS ====================

  Future<void> insertStaffDetails(Map<String, dynamic> staffData) async {
    final db = await database;
    await db.insert('staff', staffData, conflictAlgorithm: ConflictAlgorithm.replace);
    print('✅ Staff details saved');
  }

  Future<Map<String, dynamic>?> getStaffDetails(String uid) async {
    final db = await database;
    final result = await db.query('staff', where: 'uid = ?', whereArgs: [uid]);
    return result.isNotEmpty ? result.first : null;
  }

  // ==================== SESSION OPERATIONS ====================

  Future<void> recordLogin(String uid) async {
    print('📝 Login recorded for: $uid');
    await updateLastLogin(uid);
  }

  Future<void> recordLogout(String uid) async {
    print('📝 Logout recorded for: $uid');
  }

  // ==================== COMPLETE USER PROFILE ====================

  Future<Map<String, dynamic>?> getCompleteUserProfile(String uid) async {
    final userData = await getUserByUid(uid);
    if (userData == null) return null;
    
    final role = userData['role'];
    Map<String, dynamic>? roleData;
    
    if (role == 'student') {
      roleData = await getStudentDetails(uid);
    } else if (role == 'staff') {
      roleData = await getStaffDetails(uid);
    }
    
    return {...userData, 'details': roleData ?? {}};
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getUserByEmailComplete(String email) async {
    final userData = await getUserByEmail(email);
    if (userData == null) return null;
    
    final uid = userData['uid'];
    final role = userData['role'];
    
    Map<String, dynamic>? roleData;
    
    if (role == 'student') {
      roleData = await getStudentDetails(uid);
    } else if (role == 'staff') {
      roleData = await getStaffDetails(uid);
    }
    
    return {...userData, 'details': roleData ?? {}};
  }
}