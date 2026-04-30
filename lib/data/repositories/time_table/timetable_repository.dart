import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import '../../models/time_table_model/timetable_entry_model.dart';

class TimetableRepository {
  final DatabaseService _dbService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // Get entries by day
  Future<List<TimetableEntry>> getEntriesByDay(int dayOfWeek) async {
    final results = await _dbService.getTimetableByDay(dayOfWeek);
    return results.map((map) => TimetableEntry.fromMap(map)).toList();
  }

  // Get all entries
  Future<List<TimetableEntry>> getAllTimetableEntries() async {
    final results = await _dbService.getAllTimetable();
    return results.map((map) => TimetableEntry.fromMap(map)).toList();
  }

  // Add entry
  Future<int> addTimetableEntry(TimetableEntry entry) async {
    return await _dbService.insertTimetableEntry(entry.toMap());
  }

  // Update entry
  Future<void> updateTimetableEntry(TimetableEntry entry) async {
    await _dbService.updateTimetableEntry(entry.id!, entry.toMap());
  }

  // Delete entry
  Future<void> deleteTimetableEntry(int id, String? firestoreId) async {
    await _dbService.deleteTimetableEntry(id);
  }

  // Sync with cloud
  Future<void> syncWithCloud() async {
    await _firebaseService.syncLocalTimetableToFirestore();
    await _firebaseService.syncTimetableFromFirestoreToSQLite();
  }
}