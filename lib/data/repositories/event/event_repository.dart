// lib/data/repositories/event/event_repository.dart
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/data/models/event/event_model.dart';

class EventRepository {
  final DatabaseService _db = DatabaseService();
  final FirebaseService _firebase = FirebaseService();

  // Create Event - Save to BOTH SQLite and Firestore
  Future<int> createEvent(Event event) async {
    // 1. Save to SQLite first (offline cache)
    final localId = await _db.insertEvent(event.toMap());
    print('✅ Event saved to SQLite with ID: $localId');
    
    // 2. Save to Firestore (cloud backup)
    try {
      final firestoreId = await _firebase.saveEventToFirestore(event);
      
      // 3. Update SQLite with Firestore ID
      await _db.updateEventFirestoreId(localId, firestoreId);
      await _db.updateEventSyncStatus(localId, true);
      print('✅ Event saved to Firestore with ID: $firestoreId');
    } catch (e) {
      // Mark as unsynced for later sync
      await _db.updateEventSyncStatus(localId, false);
      print('⚠️ Event saved only to SQLite (offline mode). Will sync later.');
    }
    
    return localId;
  }

  // Get All Events - Try Firestore first, fallback to SQLite
  Future<List<Event>> getAllEvents() async {
    // Try to get from Firestore first
    try {
      final firestoreEvents = await _firebase.getAllEventsFromFirestore();
      if (firestoreEvents.isNotEmpty) {
        // Sync to SQLite
        for (var event in firestoreEvents) {
          await _db.insertOrUpdateEvent(event.toMap());
        }
        return firestoreEvents;
      }
    } catch (e) {
      print('⚠️ Firestore unavailable, using SQLite cache');
    }
    
    // Fallback to SQLite
    final result = await _db.getAllEvents();
    return result.map((map) => Event.fromMap(map)).toList();
  }

  // Get Pending Events
  Future<List<Event>> getPendingEvents() async {
    // Try Firestore first
    try {
      final firestoreEvents = await _firebase.getPendingEventsFromFirestore();
      if (firestoreEvents.isNotEmpty) {
        for (var event in firestoreEvents) {
          await _db.insertOrUpdateEvent(event.toMap());
        }
        return firestoreEvents;
      }
    } catch (e) {
      print('⚠️ Firestore unavailable, using SQLite cache');
    }
    
    final result = await _db.getEventsByStatus('pending');
    return result.map((map) => Event.fromMap(map)).toList();
  }

  // Approve Event - Update BOTH
  Future<void> approveEvent(int eventId) async {
    // Get event details and convert to Event object
    final eventMap = await _db.getEventById(eventId);
    if (eventMap == null) return;
    
    final event = Event.fromMap(eventMap);
    
    // 1. Update SQLite
    await _db.updateEventStatus(eventId, 'approved');
    print('✅ Event approved in SQLite');
    
    // 2. Update Firestore if has firestoreId
    if (event.firestoreId != null && event.firestoreId!.isNotEmpty) {
      try {
        await _firebase.updateEventStatus(event.firestoreId!, 'approved');
        print('✅ Event approved in Firestore');
      } catch (e) {
        print('⚠️ Firestore update failed, will sync later');
        await _db.updateEventSyncStatus(eventId, false);
      }
    }
  }

  // Reject Event
  Future<void> rejectEvent(int eventId) async {
    final eventMap = await _db.getEventById(eventId);
    if (eventMap == null) return;
    
    final event = Event.fromMap(eventMap);
    
    await _db.updateEventStatus(eventId, 'rejected');
    
    if (event.firestoreId != null && event.firestoreId!.isNotEmpty) {
      try {
        await _firebase.updateEventStatus(event.firestoreId!, 'rejected');
      } catch (e) {
        await _db.updateEventSyncStatus(eventId, false);
      }
    }
  }

  // Register for Event - Save to BOTH
  Future<String> registerForEvent(int eventId, String userId) async {
    final qrData = '$eventId|$userId|${DateTime.now().millisecondsSinceEpoch}';
    
    // 1. Save to SQLite
    await _db.registerForEvent(eventId, userId);
    print('✅ Registration saved to SQLite');
    
    // 2. Save to Firestore
    try {
      await _firebase.saveRegistrationToFirestore(eventId, userId, qrData);
      print('✅ Registration saved to Firestore');
    } catch (e) {
      print('⚠️ Registration saved only to SQLite');
    }
    
    return qrData;
  }

  // Get User Registrations
  Future<List<Map<String, dynamic>>> getUserRegistrations(String userId) async {
    // Try Firestore first
    try {
      final firestoreRegs = await _firebase.getUserRegistrationsFromFirestore(userId);
      if (firestoreRegs.isNotEmpty) {
        return firestoreRegs;
      }
    } catch (e) {
      print('⚠️ Firestore unavailable, using SQLite');
    }
    
    return await _db.getUserEventRegistrations(userId);
  }

  // Scan QR - Update BOTH
  Future<void> scanQR(int eventId, String userId) async {
    // 1. Update SQLite
    await _db.scanQRCode(eventId, userId);
    print('✅ QR scanned in SQLite');
    
    // 2. Update Firestore
    try {
      await _firebase.updateRegistrationScan(eventId, userId);
      print('✅ QR scanned in Firestore');
    } catch (e) {
      print('⚠️ Firestore update failed');
    }
  }
}