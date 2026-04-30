// lib/data/repositories/event/event_repository.dart
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/data/models/event/event_model.dart';

class EventRepository {
  final DatabaseService _db = DatabaseService();
  final FirebaseService _firebase = FirebaseService();
  
  // Flag to prevent multiple syncs
  bool _isSyncing = false;

  // ✅ CREATE EVENT - Save to SQLite FIRST, then sync to Firestore
  Future<int> createEvent(Event event) async {
    // 1. Save to SQLite first (immediate response)
    final localId = await _db.insertEvent(event.toMap());
    print('✅ Event saved to SQLite with ID: $localId');
    
    // 2. Background sync to Firestore (don't await)
    _syncEventToFirestore(event.copyWith(id: localId));
    
    return localId;
  }

  // ✅ GET ALL EVENTS - ONLY from SQLite (single source of truth)
  Future<List<Event>> getAllEvents() async {
    try {
      final result = await _db.getAllEvents();
      final events = result.map((map) => Event.fromMap(map)).toList();
      print('📱 Loaded ${events.length} events from SQLite');
      return events;
    } catch (e) {
      print('❌ Error loading events from SQLite: $e');
      return [];
    }
  }

  // ✅ GET APPROVED EVENTS - ONLY from SQLite
  Future<List<Event>> getApprovedEvents() async {
    try {
      final events = await _db.getEventsByStatus('approved');
      final eventList = events.map((map) => Event.fromMap(map)).toList();
      print('📱 Loaded ${eventList.length} approved events from SQLite');
      return eventList;
    } catch (e) {
      print('❌ Error loading approved events: $e');
      return [];
    }
  }

  // ✅ GET PENDING EVENTS - ONLY from SQLite
  Future<List<Event>> getPendingEvents() async {
    try {
      final events = await _db.getPendingEvents();
      final eventList = events.map((map) => Event.fromMap(map)).toList();
      print('📱 Loaded ${eventList.length} pending events from SQLite');
      return eventList;
    } catch (e) {
      print('❌ Error loading pending events: $e');
      return [];
    }
  }

  // ✅ APPROVE EVENT - Update SQLite FIRST, then sync
  Future<void> approveEvent(int eventId) async {
    // 1. Update SQLite first
    await _db.updateEventStatus(eventId, 'approved');
    print('✅ Event approved in SQLite');
    
    // 2. Background sync to Firestore
    _syncEventStatusToFirestore(eventId, 'approved');
  }

  // ✅ REJECT EVENT - Update SQLite FIRST, then sync
  Future<void> rejectEvent(int eventId) async {
    // 1. Update SQLite first
    await _db.updateEventStatus(eventId, 'rejected');
    print('✅ Event rejected in SQLite');
    
    // 2. Background sync to Firestore
    _syncEventStatusToFirestore(eventId, 'rejected');
  }

  // ✅ REGISTER FOR EVENT - Save to SQLite FIRST, then sync
  Future<String> registerForEvent(int eventId, String userId) async {
    final qrData = '$eventId|$userId|${DateTime.now().millisecondsSinceEpoch}';
    
    // 1. Save to SQLite first
    await _db.registerForEvent(eventId, userId);
    print('✅ Registration saved to SQLite');
    
    // 2. Background sync to Firestore
    _syncRegistrationToFirestore(eventId, userId, qrData);
    
    return qrData;
  }

  // ✅ GET USER REGISTRATIONS - ONLY from SQLite
  Future<List<Map<String, dynamic>>> getUserRegistrations(String userId) async {
    try {
      return await _db.getUserEventRegistrations(userId);
    } catch (e) {
      print('❌ Error loading registrations: $e');
      return [];
    }
  }

  // ✅ GET USER EVENT REGISTRATIONS - ONLY from SQLite
  Future<List<Map<String, dynamic>>> getUserEventRegistrations(String userId) async {
    try {
      return await _db.getUserEventRegistrations(userId);
    } catch (e) {
      print('❌ Error loading user event registrations: $e');
      return [];
    }
  }

  // ✅ SCAN QR - Update SQLite FIRST, then sync
  Future<void> scanQR(int eventId, String userId) async {
    // 1. Update SQLite first
    final success = await _db.scanQRCode(eventId, userId);
    if (!success) {
      throw Exception('Failed to scan QR code');
    }
    print('✅ QR scanned in SQLite');
    
    // 2. Background sync to Firestore
    _syncScanToFirestore(eventId, userId);
  }

  // ✅ CHECK IF USER SCANNED - ONLY from SQLite
  Future<bool> hasUserScannedForEvent(int eventId, String userId) async {
    return await _db.hasUserScannedForEvent(eventId, userId);
  }

  // ✅ GET ATTENDANCE STATUS - ONLY from SQLite
  Future<String?> getAttendanceStatus(int eventId, String userId) async {
    return await _db.getAttendanceStatus(eventId, userId);
  }

  // ✅ SYNC FROM FIRESTORE TO SQLITE (pull updates from cloud)
  // Call this method periodically or when app comes online
  Future<void> syncFromFirestore() async {
    if (_isSyncing) {
      print('⚠️ Sync already in progress');
      return;
    }
    
    _isSyncing = true;
    print('🔄 Starting sync from Firestore to SQLite...');
    
    try {
      // Get all events from Firestore
      final firestoreEvents = await _firebase.getAllEventsFromFirestore();
      print('☁️ Found ${firestoreEvents.length} events in Firestore');
      
      for (var event in firestoreEvents) {
        // Check if event exists in SQLite
        final existingEvent = await _db.getEventById(event.id ?? 0);
        
        if (existingEvent == null) {
          // New event - insert
          await _db.insertOrUpdateEvent(event.toMap());
          print('  ✅ Added new event: ${event.title}');
        } else {
          // Existing event - update if newer
          final existingUpdatedAt = existingEvent['updatedAt'];
          final newUpdatedAt = event.updatedAt?.toIso8601String();
          
          if (newUpdatedAt != null && existingUpdatedAt != newUpdatedAt) {
            await _db.insertOrUpdateEvent(event.toMap());
            print('  ✅ Updated event: ${event.title}');
          }
        }
      }
      
      // Also sync pending events
      final pendingEvents = await _firebase.getPendingEventsFromFirestore();
      for (var event in pendingEvents) {
        await _db.insertOrUpdateEvent(event.toMap());
      }
      
      print('✅ Sync completed successfully');
      
    } catch (e) {
      print('❌ Error syncing from Firestore: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // ========== PRIVATE BACKGROUND SYNC METHODS ==========
  
  Future<void> _syncEventToFirestore(Event event) async {
    try {
      final firestoreId = await _firebase.saveEventToFirestore(event);
      await _db.updateEventFirestoreId(event.id!, firestoreId);
      await _db.updateEventSyncStatus(event.id!, true);
      print('✅ Event synced to Firestore: ${event.title}');
    } catch (e) {
      print('⚠️ Failed to sync event to Firestore: $e');
      await _db.updateEventSyncStatus(event.id!, false);
    }
  }

  Future<void> _syncEventStatusToFirestore(int eventId, String status) async {
    try {
      final eventMap = await _db.getEventById(eventId);
      if (eventMap != null) {
        final firestoreId = eventMap['firestoreId'] as String?;
        if (firestoreId != null && firestoreId.isNotEmpty) {
          await _firebase.updateEventStatusInFirestore(firestoreId, status);
          print('✅ Event status synced to Firestore');
        }
      }
    } catch (e) {
      print('⚠️ Failed to sync event status to Firestore: $e');
    }
  }

  Future<void> _syncRegistrationToFirestore(int eventId, String userId, String qrData) async {
    try {
      await _firebase.saveRegistrationToFirestore(eventId, userId, qrData);
      print('✅ Registration synced to Firestore');
    } catch (e) {
      print('⚠️ Failed to sync registration to Firestore: $e');
    }
  }

  Future<void> _syncScanToFirestore(int eventId, String userId) async {
    try {
      await _firebase.updateRegistrationScan(eventId, userId);
      print('✅ Scan synced to Firestore');
    } catch (e) {
      print('⚠️ Failed to sync scan to Firestore: $e');
    }
  }
}