// lib/data/repositories/event/event_repository.dart
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/data/models/event/event_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class EventRepository {
  final DatabaseService _db = DatabaseService();
  final FirebaseService _firebase = FirebaseService();
  final Connectivity _connectivity = Connectivity();
  
  bool _isSyncing = false;
  List<Event> _cachedEvents = [];

  // ✅ Check internet connectivity
  Future<bool> _hasInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ✅ GET ALL EVENTS - Online: Firebase, Offline: SQLite
  Future<List<Event>> getAllEvents() async {
    final hasInternet = await _hasInternet();
    
    if (hasInternet) {
      try {
        // Get from Firebase when online
        print('🌐 Online: Fetching events from Firebase...');
        final firestoreEvents = await _firebase.getAllEventsFromFirestore();
        
        if (firestoreEvents.isNotEmpty) {
          // Sync to SQLite for offline cache
          for (var event in firestoreEvents) {
            await _db.insertOrUpdateEvent(event.toMap());
          }
          _cachedEvents = firestoreEvents;
          print('✅ Got ${firestoreEvents.length} events from Firebase');
          return firestoreEvents;
        }
      } catch (e) {
        print('⚠️ Firebase error: $e, falling back to SQLite');
      }
    }
    
    // Offline or Firebase failed - use SQLite
    print('📱 Offline: Loading events from SQLite...');
    final result = await _db.getAllEvents();
    final events = result.map((map) => Event.fromMap(map)).toList();
    _cachedEvents = events;
    print('✅ Got ${events.length} events from SQLite');
    return events;
  }

  // ✅ GET APPROVED EVENTS - Online: Firebase, Offline: SQLite
  Future<List<Event>> getApprovedEvents() async {
    final hasInternet = await _hasInternet();
    
    if (hasInternet) {
      try {
        print('🌐 Online: Fetching approved events from Firebase...');
        final firestoreEvents = await _firebase.getApprovedEventsFromFirestore();
        
        if (firestoreEvents.isNotEmpty) {
          // Sync to SQLite
          for (var event in firestoreEvents) {
            await _db.insertOrUpdateEvent(event.toMap());
          }
          print('✅ Got ${firestoreEvents.length} approved events from Firebase');
          return firestoreEvents;
        }
      } catch (e) {
        print('⚠️ Firebase error: $e, falling back to SQLite');
      }
    }
    
    // Offline fallback
    print('📱 Offline: Loading approved events from SQLite...');
    final events = await _db.getEventsByStatus('approved');
    final eventList = events.map((map) => Event.fromMap(map)).toList();
    print('✅ Got ${eventList.length} approved events from SQLite');
    return eventList;
  }

  // ✅ GET PENDING EVENTS - Online: Firebase, Offline: SQLite
  Future<List<Event>> getPendingEvents() async {
    final hasInternet = await _hasInternet();
    
    if (hasInternet) {
      try {
        print('🌐 Online: Fetching pending events from Firebase...');
        final firestoreEvents = await _firebase.getPendingEventsFromFirestore();
        
        if (firestoreEvents.isNotEmpty) {
          for (var event in firestoreEvents) {
            await _db.insertOrUpdateEvent(event.toMap());
          }
          print('✅ Got ${firestoreEvents.length} pending events from Firebase');
          return firestoreEvents;
        }
      } catch (e) {
        print('⚠️ Firebase error: $e, falling back to SQLite');
      }
    }
    
    print('📱 Offline: Loading pending events from SQLite...');
    final events = await _db.getPendingEvents();
    final eventList = events.map((map) => Event.fromMap(map)).toList();
    print('✅ Got ${eventList.length} pending events from SQLite');
    return eventList;
  }

  // ✅ CREATE EVENT - Save to SQLite FIRST, then sync to Firebase
  Future<int> createEvent(Event event) async {
    // 1. Save to SQLite immediately (offline first)
    final localId = await _db.insertEvent(event.toMap());
    print('✅ Event saved to SQLite with ID: $localId');
    
    // 2. Try to sync to Firebase if online
    final hasInternet = await _hasInternet();
    if (hasInternet) {
      try {
        final eventWithId = Event(
          id: localId,
          firestoreId: event.firestoreId,
          title: event.title,
          description: event.description,
          eventDate: event.eventDate,
          startTime: event.startTime,
          endTime: event.endTime,
          location: event.location,
          capacity: event.capacity,
          registeredCount: event.registeredCount,
          status: event.status,
          createdBy: event.createdBy,
          createdByRole: event.createdByRole,
          createdByEmail: event.createdByEmail,
          createdAt: event.createdAt,
          updatedAt: event.updatedAt,
        );
        
        final firestoreId = await _firebase.saveEventToFirestore(eventWithId);
        await _db.updateEventFirestoreId(localId, firestoreId);
        await _db.updateEventSyncStatus(localId, true);
        print('✅ Event synced to Firebase');
      } catch (e) {
        print('⚠️ Failed to sync to Firebase, will retry later: $e');
        await _db.updateEventSyncStatus(localId, false);
      }
    } else {
      print('📱 Offline: Event saved to SQLite only, will sync when online');
    }
    
    return localId;
  }

  // ✅ REGISTER FOR EVENT - Save to SQLite FIRST
  Future<String> registerForEvent(int eventId, String userId) async {
    final qrData = '$eventId|$userId|${DateTime.now().millisecondsSinceEpoch}';
    
    // 1. Save to SQLite immediately
    await _db.registerForEvent(eventId, userId);
    print('✅ Registration saved to SQLite');
    
    // 2. Sync to Firebase if online
    final hasInternet = await _hasInternet();
    if (hasInternet) {
      try {
        await _firebase.saveRegistrationToFirestore(eventId, userId, qrData);
        print('✅ Registration synced to Firebase');
      } catch (e) {
        print('⚠️ Failed to sync registration: $e');
      }
    }
    
    return qrData;
  }

  // ✅ GET USER REGISTRATIONS - Online first, offline fallback
  Future<List<Map<String, dynamic>>> getUserRegistrations(String userId) async {
    final hasInternet = await _hasInternet();
    
    if (hasInternet) {
      try {
        print('🌐 Online: Fetching registrations from Firebase...');
        final firestoreRegs = await _firebase.getUserRegistrationsFromFirestore(userId);
        if (firestoreRegs.isNotEmpty) {
          return firestoreRegs;
        }
      } catch (e) {
        print('⚠️ Firebase error: $e');
      }
    }
    
    print('📱 Offline: Loading registrations from SQLite...');
    return await _db.getUserEventRegistrations(userId);
  }

  // ✅ SCAN QR - Update SQLite FIRST
  Future<void> scanQR(int eventId, String userId) async {
    // 1. Update SQLite immediately
    final success = await _db.scanQRCode(eventId, userId);
    if (!success) {
      throw Exception('Failed to scan QR code');
    }
    print('✅ QR scanned in SQLite');
    
    // 2. Sync to Firebase if online
    final hasInternet = await _hasInternet();
    if (hasInternet) {
      try {
        await _firebase.updateRegistrationScan(eventId, userId);
        print('✅ QR scan synced to Firebase');
      } catch (e) {
        print('⚠️ Failed to sync QR scan: $e');
      }
    }
  }

  // ✅ APPROVE EVENT - Update both
  Future<void> approveEvent(int eventId) async {
    // 1. Update SQLite
    await _db.updateEventStatus(eventId, 'approved');
    print('✅ Event approved in SQLite');
    
    // 2. Update Firebase if online
    final hasInternet = await _hasInternet();
    if (hasInternet) {
      final eventMap = await _db.getEventById(eventId);
      if (eventMap != null && eventMap['firestoreId'] != null) {
        try {
          await _firebase.updateEventStatusInFirestore(eventMap['firestoreId'], 'approved');
          print('✅ Event approved in Firebase');
        } catch (e) {
          print('⚠️ Failed to sync approval: $e');
        }
      }
    }
  }

  // ✅ REJECT EVENT
  Future<void> rejectEvent(int eventId) async {
    await _db.updateEventStatus(eventId, 'rejected');
    print('✅ Event rejected in SQLite');
    
    final hasInternet = await _hasInternet();
    if (hasInternet) {
      final eventMap = await _db.getEventById(eventId);
      if (eventMap != null && eventMap['firestoreId'] != null) {
        try {
          await _firebase.updateEventStatusInFirestore(eventMap['firestoreId'], 'rejected');
          print('✅ Event rejected in Firebase');
        } catch (e) {
          print('⚠️ Failed to sync rejection: $e');
        }
      }
    }
  }

  // ✅ SYNC LOCAL CHANGES TO FIREBASE (background sync)
  Future<void> syncPendingChanges() async {
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      print('📱 No internet, skipping sync');
      return;
    }
    
    if (_isSyncing) return;
    _isSyncing = true;
    
    try {
      // Get unsynced events
      final unsyncedEvents = await _db.getUnsyncedEvents();
      for (var event in unsyncedEvents) {
        try {
          final firestoreId = await _firebase.saveEventToFirestore(Event.fromMap(event));
          await _db.updateEventFirestoreId(event['id'], firestoreId);
          await _db.updateEventSyncStatus(event['id'], true);
          print('✅ Synced unsynced event: ${event['title']}');
        } catch (e) {
          print('⚠️ Failed to sync event: $e');
        }
      }
      
      print('✅ Sync completed');
    } catch (e) {
      print('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Helper methods
  Future<bool> hasUserScannedForEvent(int eventId, String userId) async {
    return await _db.hasUserScannedForEvent(eventId, userId);
  }

  Future<String?> getAttendanceStatus(int eventId, String userId) async {
    return await _db.getAttendanceStatus(eventId, userId);
  }
  
  Future<List<Map<String, dynamic>>> getUserEventRegistrations(String userId) async {
    return await _db.getUserEventRegistrations(userId);
  }
}