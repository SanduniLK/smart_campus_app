import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'smart_campus.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Users Table (matches Firebase user data)
    await db.execute('''
      CREATE TABLE users(
        uid TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        fullName TEXT,
        role TEXT,
        isEmailVerified INTEGER DEFAULT 0,
        createdAt TEXT,
        lastLoginAt TEXT
      )
    ''');

    // Create Students Table (extends user data for students)
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
        FOREIGN KEY (uid) REFERENCES users (uid) ON DELETE CASCADE
      )
    ''');

    // Create Staff Table (extends user data for staff)
    await db.execute('''
      CREATE TABLE staff(
        uid TEXT PRIMARY KEY,
        staffId TEXT,
        department TEXT,
        position TEXT,
        FOREIGN KEY (uid) REFERENCES users (uid) ON DELETE CASCADE
      )
    ''');

    // Create Sessions Table for tracking
    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT,
        loginTime TEXT,
        logoutTime TEXT,
        FOREIGN KEY (uid) REFERENCES users (uid) ON DELETE CASCADE
      )
    ''');
  }

  // ==================== USER OPERATIONS ====================

  // Insert or Update User
  Future<void> insertOrUpdateUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get User by UID
  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Get User by Email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Update Email Verification Status
  Future<void> updateEmailVerificationStatus(String uid, bool isVerified) async {
    final db = await database;
    await db.update(
      'users',
      {'isEmailVerified': isVerified ? 1 : 0},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // Update Last Login
  Future<void> updateLastLogin(String uid) async {
    final db = await database;
    await db.update(
      'users',
      {'lastLoginAt': DateTime.now().toIso8601String()},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // ==================== STUDENT OPERATIONS ====================

  // Insert Student Details
  Future<void> insertStudentDetails(Map<String, dynamic> studentData) async {
    final db = await database;
    await db.insert(
      'students',
      studentData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get Student Details by UID
  Future<Map<String, dynamic>?> getStudentDetails(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // ==================== STAFF OPERATIONS ====================

  // Insert Staff Details
  Future<void> insertStaffDetails(Map<String, dynamic> staffData) async {
    final db = await database;
    await db.insert(
      'staff',
      staffData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get Staff Details by UID
  Future<Map<String, dynamic>?> getStaffDetails(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // ==================== SESSION OPERATIONS ====================

  // Record Login
  Future<void> recordLogin(String uid) async {
    final db = await database;
    await db.insert('sessions', {
      'uid': uid,
      'loginTime': DateTime.now().toIso8601String(),
    });
  }

  // Record Logout
  Future<void> recordLogout(String uid) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE sessions 
      SET logoutTime = ? 
      WHERE uid = ? AND logoutTime IS NULL
      ORDER BY id DESC LIMIT 1
    ''', [DateTime.now().toIso8601String(), uid]);
  }

  // Get User Sessions
  Future<List<Map<String, dynamic>>> getUserSessions(String uid) async {
    final db = await database;
    return await db.query(
      'sessions',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'loginTime DESC',
    );
  }

  // ==================== COMPLETE USER PROFILE ====================

  // Get Complete User Profile (with role-specific details)
  Future<Map<String, dynamic>?> getCompleteUserProfile(String uid) async {
    final db = await database;
    
    // Get base user data
    final userData = await getUserByUid(uid);
    if (userData == null) return null;
    
    String role = userData['role'];
    Map<String, dynamic>? roleData;
    
    if (role == 'student') {
      roleData = await getStudentDetails(uid);
    } else if (role == 'staff') {
      roleData = await getStaffDetails(uid);
    }
    
    return {
      ...userData,
      'details': roleData ?? {},
    };
  }

  // Delete User (when account is deleted)
  Future<void> deleteUser(String uid) async {
    final db = await database;
    await db.delete('users', where: 'uid = ?', whereArgs: [uid]);
    // Related records will be deleted automatically due to CASCADE
  }
}