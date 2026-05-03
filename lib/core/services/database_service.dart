
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
    version: 4,  
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
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firestoreId TEXT,
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
      status TEXT DEFAULT 'pending',
      createdBy TEXT,
      createdByRole TEXT,
      createdByEmail TEXT,
      approvedBy TEXT,
      approvedAt TEXT,
      createdAt TEXT,
      updatedAt TEXT,
      isSynced INTEGER DEFAULT 1
    ''');
    
    // Event Registrations Table
    await db.execute('''
      CREATE TABLE event_registrations(
         id INTEGER PRIMARY KEY AUTOINCREMENT,
      firestoreId TEXT,
      eventId INTEGER NOT NULL,
      userId TEXT NOT NULL,
      registrationDate TEXT NOT NULL,
      qrScanned INTEGER DEFAULT 0,
      scannedAt TEXT,
      attendanceStatus TEXT DEFAULT 'Pending',
      qrCodeData TEXT,
      isSynced INTEGER DEFAULT 1,
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

    await db.execute('''
  CREATE TABLE campus_buildings(
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    description TEXT,
    type TEXT NOT NULL,
    facilities TEXT,
    openingHours TEXT,
    phone TEXT,
    imageUrl TEXT
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
    } catch (e) { print('⚠️ Error adding columns: $e'); }
  }
  
  if (oldVersion < 3) {
    try {
      await db.execute('ALTER TABLE students ADD COLUMN level TEXT');
      await db.execute('ALTER TABLE students ADD COLUMN currentSemester TEXT');
      print('✅ Added level and currentSemester columns');
    } catch (e) { print('⚠️ Error adding level columns: $e'); }
    
    try {
      await db.execute('ALTER TABLE timetable ADD COLUMN firestoreId TEXT');
      await db.execute('ALTER TABLE timetable ADD COLUMN updatedAt TEXT');
      await db.execute('ALTER TABLE timetable ADD COLUMN isSynced INTEGER DEFAULT 1');
      print('✅ Added sync columns to timetable');
    } catch (e) { print('⚠️ Error adding sync columns: $e'); }
  }
  
  // ✅ ADD THIS FOR VERSION 4
  if (oldVersion < 4) {
    try {
      await db.execute('ALTER TABLE events ADD COLUMN status TEXT DEFAULT "pending"');
      print('✅ Added status column to events table');
    } catch (e) { print('⚠️ status column error: $e'); }
    
    try {
      await db.execute('ALTER TABLE events ADD COLUMN firestoreId TEXT');
      print('✅ Added firestoreId column to events');
    } catch (e) { print('⚠️ firestoreId column error: $e'); }
    
    try {
      await db.execute('ALTER TABLE events ADD COLUMN isSynced INTEGER DEFAULT 1');
      print('✅ Added isSynced column to events');
    } catch (e) { print('⚠️ isSynced column error: $e'); }
    
    try {
      await db.execute('ALTER TABLE events ADD COLUMN approvedBy TEXT');
      print('✅ Added approvedBy column to events');
    } catch (e) { print('⚠️ approvedBy column error: $e'); }
    
    try {
      await db.execute('ALTER TABLE events ADD COLUMN approvedAt TEXT');
      print('✅ Added approvedAt column to events');
    } catch (e) { print('⚠️ approvedAt column error: $e'); }
    
    try {
      await db.execute('ALTER TABLE event_registrations ADD COLUMN firestoreId TEXT');
      print('✅ Added firestoreId column to event_registrations');
    } catch (e) { print('⚠️ firestoreId column error: $e'); }
    
    try {
      await db.execute('ALTER TABLE event_registrations ADD COLUMN qrCodeData TEXT');
      print('✅ Added qrCodeData column to event_registrations');
    } catch (e) { print('⚠️ qrCodeData column error: $e'); }
    
    try {
      await db.execute('ALTER TABLE event_registrations ADD COLUMN isSynced INTEGER DEFAULT 1');
      print('✅ Added isSynced column to event_registrations');
    } catch (e) { print('⚠️ isSynced column error: $e'); }
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
// Add to database_service.dart




// ==================== EVENT OPERATIONS (KEEP ONLY THESE) ====================

Future<int> insertEvent(Map<String, dynamic> eventData) async {
  final db = await database;
  return await db.insert('events', eventData);
}

Future<List<Map<String, dynamic>>> getAllEvents() async {
  final db = await database;
  // Use DISTINCT to avoid duplicates
  return await db.query(
    'events', 
    distinct: true,
    orderBy: 'eventDate DESC',
  );
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

Future<List<Map<String, dynamic>>> getEventsByStatus(String status) async {
  final db = await database;
  final result = await db.query(
    'events',
    where: 'status = ?',
    whereArgs: [status],
    orderBy: 'createdAt DESC',
  );
  print('📚 SQLite: Found ${result.length} events with status: $status');
  return result;
}
Future<List<Map<String, dynamic>>> getPendingEvents() async {
  final db = await database;
  
  // First, check if status column exists
  final columns = await db.rawQuery("PRAGMA table_info(events)");
  final hasStatusColumn = columns.any((col) => col['name'] == 'status');
  
  if (!hasStatusColumn) {
    print('⚠️ Status column missing! Adding it...');
    await db.execute('ALTER TABLE events ADD COLUMN status TEXT DEFAULT "pending"');
  }
  
  final result = await db.query(
    'events',
    where: 'status = ?',
    whereArgs: ['pending'],
    orderBy: 'createdAt DESC',
  );
  
  print('🔍 SQLite getPendingEvents query returned ${result.length} rows');
  for (var row in result) {
    print('  - ID: ${row['id']}, Title: ${row['title']}, Status: ${row['status']}');
  }
  
  return result;
}

Future<void> updateEventStatus(int id, String status) async {
  final db = await database;
  await db.update(
    'events',
    {
      'status': status,
      'approvedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [id],
  );
  print('✅ SQLite: Event $id status updated to $status');
}
Future<void> updateEventFirestoreId(int localId, String firestoreId) async {
  final db = await database;
  await db.update(
    'events',
    {'firestoreId': firestoreId},
    where: 'id = ?',
    whereArgs: [localId],
  );
}

Future<void> updateEventSyncStatus(int localId, bool isSynced) async {
  final db = await database;
  await db.update(
    'events',
    {'isSynced': isSynced ? 1 : 0},
    where: 'id = ?',
    whereArgs: [localId],
  );
}

Future<void> insertOrUpdateEvent(Map<String, dynamic> eventData) async {
  final db = await database;
  
  // Check if event already exists by firestoreId or id
  final existingEvent = await db.query(
    'events',
    where: 'firestoreId = ? OR id = ?',
    whereArgs: [eventData['firestoreId'], eventData['id']],
  );
  
  if (existingEvent.isNotEmpty) {
    // Update existing event
    await db.update(
      'events',
      eventData,
      where: 'id = ?',
      whereArgs: [existingEvent.first['id']],
    );
    print('✅ Updated existing event: ${eventData['title']}');
  } else {
    // Insert new event
    await db.insert('events', eventData);
    print('✅ Inserted new event: ${eventData['title']}');
  }
}

// In lib/data/services/database_service.dart

Future<String> registerForEvent(int eventId, String userId) async {
  final db = await database;
  
  // Check if already registered
  final existing = await db.query(
    'event_registrations',
    where: 'eventId = ? AND userId = ?',
    whereArgs: [eventId, userId],
  );
  
  if (existing.isNotEmpty) return 'already_registered';
  
  final qrData = '$eventId|$userId|${DateTime.now().millisecondsSinceEpoch}';
  
  // Insert registration
  await db.insert('event_registrations', {
    'eventId': eventId,
    'userId': userId,
    'registrationDate': DateTime.now().toIso8601String(),
    'qrScanned': 0,
    'attendanceStatus': 'Pending',
    'qrCodeData': qrData,
  });
  
  // ✅ FIXED: Correct SQL syntax for incrementing registeredCount
  await db.rawUpdate(
    'UPDATE events SET registeredCount = registeredCount + 1 WHERE id = ?',
    [eventId]
  );
  
  return qrData;
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
  final now = DateTime.now().toIso8601String();
  
  try {
    // First check if registration exists
    final registration = await db.query(
      'event_registrations',
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    
    if (registration.isEmpty) {
      print('❌ No registration found for event $eventId and user $userId');
      return false;
    }
    
    // Check if already scanned
    final isScanned = registration.first['qrScanned'] == 1;
    if (isScanned) {
      print('⚠️ QR Code already scanned for this registration');
      return false; // Already scanned
    }
    
    // Update the registration
    final result = await db.update(
      'event_registrations',
      {
        'qrScanned': 1,
        'scannedAt': now,
        'attendanceStatus': 'Present',
      },
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    
    print('✅ QR Code scanned successfully for event $eventId, user $userId');
    return result > 0;
  } catch (e) {
    print('❌ Error scanning QR code: $e');
    return false;
  }
}
Future<bool> hasUserScannedForEvent(int eventId, String userId) async {
  final db = await database;
  final result = await db.query(
    'event_registrations',
    where: 'eventId = ? AND userId = ? AND qrScanned = 1',
    whereArgs: [eventId, userId],
  );
  return result.isNotEmpty;
}

// Add method to get attendance status
Future<String?> getAttendanceStatus(int eventId, String userId) async {
  final db = await database;
  final result = await db.query(
    'event_registrations',
    where: 'eventId = ? AND userId = ?',
    whereArgs: [eventId, userId],
  );
  if (result.isNotEmpty) {
    return result.first['attendanceStatus'] as String?;
  }
  return null;
}
Future<List<Map<String, dynamic>>> getUnsyncedEvents() async {
  final db = await database;
  return await db.query(
    'events',
    where: 'isSynced = 0 OR isSynced IS NULL',
  );
}
Future<void> insertCampusBuilding(Map<String, dynamic> building) async {
  final db = await database;
  await db.insert('campus_buildings', building,
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<Map<String, dynamic>>> getAllCampusBuildings() async {
  final db = await database;
  return await db.query('campus_buildings', orderBy: 'name');
}

Future<Map<String, dynamic>?> getCampusBuildingById(String id) async {
  final db = await database;
  final result = await db.query(
    'campus_buildings',
    where: 'id = ?',
    whereArgs: [id],
  );
  return result.isNotEmpty ? result.first : null;
}
}