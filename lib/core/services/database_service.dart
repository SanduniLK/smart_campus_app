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
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'smart_campus.db');
    
    // FORCE DELETE OLD DATABASE - This ensures fresh schema
    if (await File(path).exists()) {
      print('🗑️ Deleting old database to fix schema...');
      await File(path).delete();
    }
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('📦 Creating fresh database with correct schema...');

    // ==================== USERS TABLE ====================
    await db.execute('''
      CREATE TABLE users(
        uid TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        fullName TEXT,
        role TEXT,
        staffType TEXT,
        isEmailVerified INTEGER DEFAULT 0,
        createdAt TEXT,
        lastLoginAt TEXT
      )
    ''');

    // ==================== STUDENTS TABLE ====================
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
        FOREIGN KEY (uid) REFERENCES users (uid) ON DELETE CASCADE
      )
    ''');

    // ==================== STAFF TABLE ====================
    await db.execute('''
      CREATE TABLE staff(
        uid TEXT PRIMARY KEY,
        staffId TEXT,
        faculty TEXT,
        department TEXT,
        staffType TEXT,
        position TEXT,
        workLocation TEXT,
        designation TEXT,
        specialization TEXT,
        qualifications TEXT,
        officeHours TEXT,
        officeLocation TEXT,
        joiningDate TEXT,
        isHOD INTEGER DEFAULT 0,
        division TEXT,
        shiftStart TEXT,
        shiftEnd TEXT,
        supervisorId TEXT,
        responsibilities TEXT,
        emergencyContact TEXT,
        FOREIGN KEY (uid) REFERENCES users (uid) ON DELETE CASCADE
      )
    ''');

    // ==================== COURSES TABLE ====================
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseCode TEXT UNIQUE NOT NULL,
        courseName TEXT NOT NULL,
        credits INTEGER NOT NULL,
        lecturerId TEXT,
        department TEXT,
        semester INTEGER,
        academicYear TEXT,
        description TEXT,
        FOREIGN KEY (lecturerId) REFERENCES users (uid) ON DELETE SET NULL
      )
    ''');

    // ==================== TIMETABLE SLOTS TABLE ====================
    await db.execute('''
      CREATE TABLE timetable_slots(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseId INTEGER NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        roomNumber TEXT NOT NULL,
        building TEXT NOT NULL,
        floor INTEGER,
        type TEXT CHECK(type IN ('Lecture', 'Lab', 'Tutorial', 'Practical')),
        groupName TEXT,
        isAlternateWeek INTEGER DEFAULT 0,
        colorCode TEXT,
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // ==================== ATTENDANCE TABLE ====================
    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timetableSlotId INTEGER NOT NULL,
        studentId TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT CHECK(status IN ('Present', 'Absent', 'Late', 'Excused')),
        checkInTime TEXT,
        latitude REAL,
        longitude REAL,
        remarks TEXT,
        FOREIGN KEY (timetableSlotId) REFERENCES timetable_slots (id) ON DELETE CASCADE,
        FOREIGN KEY (studentId) REFERENCES users (uid) ON DELETE CASCADE,
        UNIQUE(timetableSlotId, studentId, date)
      )
    ''');

    // ==================== EVENTS TABLE ====================
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        eventDate TEXT NOT NULL,
        startTime TEXT,
        endTime TEXT,
        location TEXT,
        venue TEXT,
        capacity INTEGER,
        registeredCount INTEGER DEFAULT 0,
        qrCode TEXT,
        qrCodeData TEXT,
        isActive INTEGER DEFAULT 1,
        createdBy TEXT,
        createdAt TEXT,
        category TEXT,
        imageUrl TEXT,
        FOREIGN KEY (createdBy) REFERENCES users (uid) ON DELETE SET NULL
      )
    ''');

    // ==================== EVENT REGISTRATIONS TABLE ====================
    await db.execute('''
      CREATE TABLE event_registrations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        registrationDate TEXT NOT NULL,
        qrScanned INTEGER DEFAULT 0,
        scannedAt TEXT,
        attendanceStatus TEXT DEFAULT 'Pending',
        FOREIGN KEY (eventId) REFERENCES events (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (uid) ON DELETE CASCADE,
        UNIQUE(eventId, userId)
      )
    ''');

    // ==================== ANNOUNCEMENTS TABLE ====================
    await db.execute('''
      CREATE TABLE announcements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        isUrgent INTEGER DEFAULT 0,
        targetAudience TEXT DEFAULT 'all',
        createdBy TEXT,
        imageUrl TEXT,
        link TEXT,
        FOREIGN KEY (createdBy) REFERENCES users (uid) ON DELETE SET NULL
      )
    ''');

    // ==================== SESSIONS TABLE ====================
    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT,
        loginTime TEXT,
        logoutTime TEXT,
        deviceInfo TEXT,
        ipAddress TEXT,
        FOREIGN KEY (uid) REFERENCES users (uid) ON DELETE CASCADE
      )
    ''');

    // ==================== INDEXES FOR PERFORMANCE ====================
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_role ON users(role)');
    await db.execute('CREATE INDEX idx_timetable_day ON timetable_slots(dayOfWeek)');
    await db.execute('CREATE INDEX idx_timetable_course ON timetable_slots(courseId)');
    await db.execute('CREATE INDEX idx_attendance_date ON attendance(date)');
    await db.execute('CREATE INDEX idx_attendance_student ON attendance(studentId)');
    await db.execute('CREATE INDEX idx_events_date ON events(eventDate)');
    await db.execute('CREATE INDEX idx_registrations_event ON event_registrations(eventId)');
    await db.execute('CREATE INDEX idx_registrations_user ON event_registrations(userId)');
    await db.execute('CREATE INDEX idx_announcements_date ON announcements(date)');
    
    print('✅ Database created successfully with all tables and columns!');
  }

  // ==================== USER OPERATIONS ====================

  Future<void> insertOrUpdateUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ User saved: ${userData['uid']}');
  }

  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'createdAt DESC');
  }

  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role],
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

  Future<void> updateLastLogin(String uid) async {
    final db = await database;
    await db.update(
      'users',
      {'lastLoginAt': DateTime.now().toIso8601String()},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    final db = await database;
    await db.update(
      'users',
      {'role': newRole},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // ==================== STUDENT OPERATIONS ====================

  Future<void> insertStudentDetails(Map<String, dynamic> studentData) async {
    final db = await database;
    await db.insert(
      'students',
      studentData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Student details saved for UID: ${studentData['uid']}');
  }

  Future<Map<String, dynamic>?> getStudentDetails(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> updateStudentDetails(String uid, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(
      'students',
      updates,
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // ==================== STAFF OPERATIONS ====================

  Future<void> insertStaffDetails(Map<String, dynamic> staffData) async {
    final db = await database;
    await db.insert(
      'staff',
      staffData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Staff details saved for UID: ${staffData['uid']}');
  }

  Future<Map<String, dynamic>?> getStaffDetails(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllStaff() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT u.*, s.* FROM users u 
      INNER JOIN staff s ON u.uid = s.uid 
      WHERE u.role = 'staff'
    ''');
  }

  Future<List<Map<String, dynamic>>> getStaffByType(String type) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT u.*, s.* FROM users u 
      INNER JOIN staff s ON u.uid = s.uid 
      WHERE u.role = 'staff' AND s.staffType = ?
    ''', [type]);
  }

  // ==================== COURSE OPERATIONS ====================

  Future<int> insertCourse(Map<String, dynamic> courseData) async {
    final db = await database;
    return await db.insert('courses', courseData);
  }

  Future<List<Map<String, dynamic>>> getAllCourses() async {
    final db = await database;
    return await db.query('courses', orderBy: 'courseCode');
  }

  Future<Map<String, dynamic>?> getCourseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<List<Map<String, dynamic>>> getCoursesByLecturer(String lecturerId) async {
    final db = await database;
    return await db.query(
      'courses',
      where: 'lecturerId = ?',
      whereArgs: [lecturerId],
    );
  }

  // ==================== TIMETABLE OPERATIONS ====================

  Future<int> insertTimetableSlot(Map<String, dynamic> slotData) async {
    final db = await database;
    return await db.insert('timetable_slots', slotData);
  }

  Future<List<Map<String, dynamic>>> getTimetableByDay(int dayOfWeek) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ts.*, c.courseCode, c.courseName, c.credits 
      FROM timetable_slots ts
      INNER JOIN courses c ON ts.courseId = c.id
      WHERE ts.dayOfWeek = ?
      ORDER BY ts.startTime
    ''', [dayOfWeek]);
  }

  Future<List<Map<String, dynamic>>> getStudentTimetable(String studentId) async {
    final db = await database;
    // This would join with enrollments in a real implementation
    return await db.rawQuery('''
      SELECT ts.*, c.courseCode, c.courseName 
      FROM timetable_slots ts
      INNER JOIN courses c ON ts.courseId = c.id
      ORDER BY ts.dayOfWeek, ts.startTime
    ''');
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

  Future<int> registerForEvent(int eventId, String userId) async {
    final db = await database;
    
    // Update registered count
    await db.update(
      'events',
      {'registeredCount': db.rawUpdate('registeredCount + 1')},
      where: 'id = ?',
      whereArgs: [eventId],
    );
    
    return await db.insert('event_registrations', {
      'eventId': eventId,
      'userId': userId,
      'registrationDate': DateTime.now().toIso8601String(),
      'qrScanned': 0,
    });
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

  Future<void> scanQRCode(int registrationId) async {
    final db = await database;
    await db.update(
      'event_registrations',
      {
        'qrScanned': 1,
        'scannedAt': DateTime.now().toIso8601String(),
        'attendanceStatus': 'Present',
      },
      where: 'id = ?',
      whereArgs: [registrationId],
    );
  }

  // ==================== ATTENDANCE OPERATIONS ====================

  Future<void> markAttendance({
    required int timetableSlotId,
    required String studentId,
    required String status,
    double? latitude,
    double? longitude,
  }) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await db.insert(
      'attendance',
      {
        'timetableSlotId': timetableSlotId,
        'studentId': studentId,
        'date': today,
        'status': status,
        'checkInTime': DateTime.now().toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> getAttendanceStats(String studentId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present,
        SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as absent,
        SUM(CASE WHEN status = 'Late' THEN 1 ELSE 0 END) as late
      FROM attendance
      WHERE studentId = ?
    ''', [studentId]);
    
    final total = (result.first['total'] as int?)?.toDouble() ?? 1;
    final present = (result.first['present'] as int?)?.toDouble() ?? 0;
    
    return {
      'percentage': (present / total) * 100,
      'present': present,
      'absent': (result.first['absent'] as int?)?.toDouble() ?? 0,
      'late': (result.first['late'] as int?)?.toDouble() ?? 0,
      'total': total,
    };
  }

  // ==================== ANNOUNCEMENT OPERATIONS ====================

  Future<int> insertAnnouncement(Map<String, dynamic> announcementData) async {
    final db = await database;
    return await db.insert('announcements', announcementData);
  }

  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final db = await database;
    return await db.query(
      'announcements',
      orderBy: 'date DESC',
      limit: 20,
    );
  }

  Future<List<Map<String, dynamic>>> getUrgentAnnouncements() async {
    final db = await database;
    return await db.query(
      'announcements',
      where: 'isUrgent = 1',
      orderBy: 'date DESC',
    );
  }

  // ==================== SESSION OPERATIONS ====================

  Future<void> recordLogin(String uid, {String? deviceInfo, String? ipAddress}) async {
    final db = await database;
    await db.insert('sessions', {
      'uid': uid,
      'loginTime': DateTime.now().toIso8601String(),
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
    });
    await updateLastLogin(uid);
    print('📝 Login recorded for: $uid');
  }

  Future<void> recordLogout(String uid) async {
    final db = await database;
    
    final result = await db.query(
      'sessions',
      where: 'uid = ? AND logoutTime IS NULL',
      whereArgs: [uid],
      orderBy: 'id DESC',
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      final sessionId = result.first['id'];
      await db.update(
        'sessions',
        {'logoutTime': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [sessionId],
      );
      print('📝 Logout recorded for: $uid');
    }
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
    
    return {
      ...userData,
      'details': roleData ?? {},
    };
  }

  // ==================== DELETE OPERATIONS ====================

  Future<void> deleteUser(String uid) async {
    final db = await database;
    await db.delete('users', where: 'uid = ?', whereArgs: [uid]);
    print('🗑️ User deleted: $uid');
  }

  Future<void> deleteEvent(int eventId) async {
    final db = await database;
    await db.delete('events', where: 'id = ?', whereArgs: [eventId]);
  }

  Future<void> deleteCourse(int courseId) async {
    final db = await database;
    await db.delete('courses', where: 'id = ?', whereArgs: [courseId]);
  }

  // ==================== UTILITY METHODS ====================

  Future<int> getRowCount(String table) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return result.first['count'] as int;
  }

  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }
}