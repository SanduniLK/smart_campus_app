import 'package:smart_campus_app/data/models/time_table_model/course_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/models/time_table_model/timetable_entry_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
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
    
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      singleInstance: true,
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
    level TEXT,
    currentSemester TEXT,
    currentSemesterNumber INTEGER DEFAULT 1,
    batchYear INTEGER,
    FOREIGN KEY (uid) REFERENCES users(uid) ON DELETE CASCADE
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
    
    // Events Table
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        eventDate TEXT NOT NULL,
        startTime TEXT,
        endTime TEXT,
        location TEXT NOT NULL,
        capacity INTEGER NOT NULL,
        registeredCount INTEGER DEFAULT 0,
        qrCode TEXT,
        isActive INTEGER DEFAULT 1,
        createdBy TEXT,
        createdByRole TEXT,
        createdByEmail TEXT,
        createdAt TEXT
      )
    ''');
    
    // Event Registrations Table
    await db.execute('''
      CREATE TABLE event_registrations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        registrationDate TEXT NOT NULL,
        qrScanned INTEGER DEFAULT 0,
        scannedAt TEXT,
        attendanceStatus TEXT DEFAULT 'Pending',
        FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users(uid) ON DELETE CASCADE,
        UNIQUE(eventId, userId)
      )
    ''');
    
    // Timetable Table
    await db.execute('''
      CREATE TABLE timetable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firestoreId TEXT,
        lecturerName TEXT NOT NULL,
        lecturerId TEXT,
        level TEXT NOT NULL,
        semester TEXT NOT NULL,
        courseId TEXT NOT NULL,
        courseName TEXT NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        roomNumber TEXT NOT NULL,
        building TEXT,
        createdBy TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        isSynced INTEGER DEFAULT 1
      )
    ''');
    
    print('✅ Database created successfully!');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
        await db.execute('ALTER TABLE users ADD COLUMN department TEXT');
        print('✅ Added phone and department columns');
      } catch (e) {
        print('⚠️ Error adding columns: $e');
      }
    }
    
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE students ADD COLUMN level TEXT');
        await db.execute('ALTER TABLE students ADD COLUMN currentSemester TEXT');
        print('✅ Added level and currentSemester columns');
      } catch (e) {
        print('⚠️ Error adding level columns: $e');
      }
      
      try {
        await db.execute('ALTER TABLE timetable ADD COLUMN firestoreId TEXT');
        await db.execute('ALTER TABLE timetable ADD COLUMN updatedAt TEXT');
        await db.execute('ALTER TABLE timetable ADD COLUMN isSynced INTEGER DEFAULT 1');
        print('✅ Added sync columns to timetable');
      } catch (e) {
        print('⚠️ Error adding sync columns: $e');
      }
    }
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  // ==================== USER OPERATIONS ====================
  
  Future<void> insertOrUpdateUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert('users', userData, conflictAlgorithm: ConflictAlgorithm.replace);
    print('✅ User saved: ${userData['uid']}');
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
    await db.update('users', {'lastLoginAt': DateTime.now().toIso8601String()}, where: 'uid = ?', whereArgs: [uid]);
  }

  Future<void> updateEmailVerificationStatus(String uid, bool isVerified) async {
    final db = await database;
    await db.update('users', {'isEmailVerified': isVerified ? 1 : 0}, where: 'uid = ?', whereArgs: [uid]);
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

  Future<List<Map<String, dynamic>>> getAcademicStaff() async {
  final db = await database;
  
  // Academic staff are stored in users table with staffType = 'academic'
  // They are also in staff table with their details
  final result = await db.rawQuery('''
    SELECT 
      u.uid, 
      u.fullName, 
      u.email,
      u.staffType,
      s.staffId, 
      s.faculty, 
      s.department
    FROM users u
    LEFT JOIN staff s ON u.uid = s.uid
    WHERE u.role = 'staff' AND u.staffType = 'academic'
    ORDER BY u.fullName
  ''');
  
  print('📚 Found ${result.length} academic staff members');
  for (var staff in result) {
    print('  - ${staff['fullName']} (${staff['staffType']})');
  }
  
  return result;
}

  // ==================== EVENT OPERATIONS ====================

  Future<int> insertEvent(Map<String, dynamic> eventData) async {
    final db = await database;
    return await db.insert('events', eventData);
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final db = await database;
    return await db.query('events', orderBy: 'eventDate DESC');
  }

  Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    return await db.query(
      'events',
      where: 'eventDate >= ? AND isActive = 1',
      whereArgs: [today],
      orderBy: 'eventDate ASC',
    );
  }

  Future<Map<String, dynamic>?> getEventById(int id) async {
    final db = await database;
    final result = await db.query('events', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> registerForEvent(int eventId, String userId) async {
    final db = await database;
    
    final existing = await db.query(
      'event_registrations',
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    
    if (existing.isNotEmpty) return -1;
    
    final result = await db.insert('event_registrations', {
      'eventId': eventId,
      'userId': userId,
      'registrationDate': DateTime.now().toIso8601String(),
      'qrScanned': 0,
      'attendanceStatus': 'Pending',
    });
    
    await db.update(
      'events',
      {'registeredCount': db.rawUpdate('registeredCount + 1')},
      where: 'id = ?',
      whereArgs: [eventId],
    );
    
    return result;
  }

  Future<bool> isUserRegisteredForEvent(int eventId, String userId) async {
    final db = await database;
    final result = await db.query(
      'event_registrations',
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getUserEventRegistrations(String userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT e.*, er.registrationDate, er.qrScanned, er.attendanceStatus
      FROM event_registrations er
      INNER JOIN events e ON er.eventId = e.id
      WHERE er.userId = ?
      ORDER BY e.eventDate DESC
    ''', [userId]);
  }

  Future<bool> scanQRCode(int eventId, String userId) async {
    final db = await database;
    final result = await db.update(
      'event_registrations',
      {
        'qrScanned': 1,
        'scannedAt': DateTime.now().toIso8601String(),
        'attendanceStatus': 'Present',
      },
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    return result > 0;
  }

  // ==================== TIMETABLE OPERATIONS ====================

  Future<int> insertTimetableEntry(Map<String, dynamic> entryData) async {
    final db = await database;
    return await db.insert('timetable', entryData);
  }

  Future<List<Map<String, dynamic>>> getTimetableByDay(int dayOfWeek) async {
    final db = await database;
    return await db.query(
      'timetable',
      where: 'dayOfWeek = ?',
      whereArgs: [dayOfWeek],
      orderBy: 'startTime',
    );
  }

  Future<List<Map<String, dynamic>>> getAllTimetable() async {
    final db = await database;
    return await db.query('timetable', orderBy: 'dayOfWeek, startTime');
  }

  Future<List<Map<String, dynamic>>> getTimetableByLecturer(String lecturerName) async {
    final db = await database;
    return await db.query(
      'timetable',
      where: 'lecturerName = ?',
      whereArgs: [lecturerName],
      orderBy: 'dayOfWeek, startTime',
    );
  }

  Future<int> updateTimetableEntry(int id, Map<String, dynamic> entryData) async {
    final db = await database;
    return await db.update('timetable', entryData, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTimetableEntry(int id) async {
    final db = await database;
    return await db.delete('timetable', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== TIMETABLE SYNC METHODS ====================

  Future<void> insertOrUpdateTimetableEntry(TimetableEntry entry) async {
    final db = await database;
    await db.insert(
      'timetable',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TimetableEntry>> getUnsyncedTimetableEntries() async {
    final db = await database;
    final result = await db.query(
      'timetable',
      where: 'isSynced = 0',
    );
    return result.map((map) => TimetableEntry.fromMap(map)).toList();
  }

  Future<void> updateTimetableFirestoreId(int localId, String firestoreId) async {
  final db = await database;
  await db.update(
    'timetable',
    {'firestoreId': firestoreId},
    where: 'id = ?',
    whereArgs: [localId],
  );
}


  Future<void> markTimetableAsSynced(int localId) async {
  final db = await database;
  await db.update(
    'timetable',
    {'isSynced': 1},
    where: 'id = ?',
    whereArgs: [localId],
  );
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
    return userData;
  }

  // ==================== LECTURER METHODS ====================

  Future<Map<String, dynamic>?> getLecturerByName(String fullName) async {
  final db = await database;
  final result = await db.rawQuery('''
    SELECT 
      u.uid, 
      u.fullName, 
      u.email,
      u.staffType,
      s.staffId, 
      s.faculty, 
      s.department
    FROM users u
    LEFT JOIN staff s ON u.uid = s.uid
    WHERE u.role = 'staff' AND u.staffType = 'academic' AND u.fullName = ?
  ''', [fullName]);
  
  return result.isNotEmpty ? result.first : null;
}
  Future<void> insertOrUpdateCourse(Course course) async {
  final db = await database;
  await db.insert(
    'courses',
    course.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Course>> getUnsyncedCourses() async {
  final db = await database;
  final result = await db.query(
    'courses',
    where: 'isSynced = 0',
  );
  return result.map((map) => Course.fromMap(map)).toList();
}

Future<void> updateCourse(int id, Map<String, dynamic> updates) async {
  final db = await database;
  await db.update('courses', updates, where: 'id = ?', whereArgs: [id]);
}
}