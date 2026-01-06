import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Firebase service class with proper security rules implementation
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String usersCollection = 'users';
  static const String notesCollection = 'notes';

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  User? get currentUser => _auth.currentUser;

  //Initialize Firebase service
  Future<void> initialize() async {
    try {
      // Configure Firestore settings
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

    } catch (e) {
    }
  }

  //Get users collection reference
  CollectionReference get usersRef => _firestore.collection(usersCollection);

  //Get user-specific notes subcollection reference
  CollectionReference getUserNotesRef(String userId) {
    return usersRef.doc(userId).collection(notesCollection);
  }

  //Create user document after authentication
  Future<void> createUserDocument({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      // Check current authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not properly authenticated');
      }

      final userDoc = usersRef.doc(userId);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        final userData = {
          'uid': userId,
          'email': email,
          'displayName': displayName ?? email.split('@')[0],
          'photoUrl': photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'notesCount': 0,
          'isActive': true,
        };

        await userDoc.set(userData);
      } else {
        // Update last login time
        await userDoc.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  //Create a new note in user's subcollection
  Future<DocumentReference> createNote({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      // Prepare note data with all required fields
      final noteData = {
        'title': title.trim(),
        'message': message.trim(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isArchived': false,
        'isPinned': false,
        'tags': <String>[],
        'color': null,
        ...?metadata,
      };

      // Add note to user's subcollection
      final noteRef = await getUserNotesRef(userId).add(noteData);

      // Update note with its own ID for easier reference
      await noteRef.update({'id': noteRef.id});

      // Increment user's notes count
      await _incrementUserNotesCount(userId);

      return noteRef;
    } catch (e) {
      rethrow;
    }
  }

  //Update an existing note
  Future<void> updateNote({
    required String userId,
    required String noteId,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      final updateData = {
        'title': title.trim(),
        'message': message.trim(),
        'userId': userId, // Ensure userId is maintained
        'updatedAt': FieldValue.serverTimestamp(),
        ...?metadata,
      };

      await getUserNotesRef(userId).doc(noteId).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  //Delete a note
  Future<void> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      await getUserNotesRef(userId).doc(noteId).delete();

      // Decrement user's notes count
      await _decrementUserNotesCount(userId);

    } catch (e) {
      rethrow;
    }
  }

  //Get a specific note by ID
  Future<DocumentSnapshot> getNote({
    required String userId,
    required String noteId,
  }) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      return await getUserNotesRef(userId).doc(noteId).get();
    } catch (e) {
      rethrow;
    }
  }

  //Get user's notes stream for real-time updates
  Stream<QuerySnapshot> getUserNotesStream(
    String userId, {
    int? limit,
    String? orderBy = 'updatedAt',
    bool descending = true,
    Query<Object?>? Function(Query<Object?> query)? queryBuilder,
  }) {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      Query<Object?> query = getUserNotesRef(userId);

      // Apply custom query if provided
      if (queryBuilder != null) {
        query = queryBuilder(query)!;
      } else {
        // Default ordering
        if (orderBy != null) {
          query = query.orderBy(orderBy, descending: descending);
        }

        // Apply limit if specified
        if (limit != null) {
          query = query.limit(limit);
        }
      }

      return query.snapshots();
    } catch (e) {
      rethrow;
    }
  }

  //Search notes by title (Firestore text search is limited)
  Stream<QuerySnapshot> searchNotes({
    required String userId,
    required String searchQuery,
    int? limit = 50,
  }) {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      // Note: Firestore doesn't support full-text search
      // This is a basic prefix search on title
      final query = getUserNotesRef(userId).orderBy('title').startAt(
          [searchQuery]).endAt([searchQuery + '\uf8ff']).limit(limit ?? 50);

      return query.snapshots();
    } catch (e) {
      rethrow;
    }
  }

  //Get notes by date range
  Stream<QuerySnapshot> getNotesByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String orderBy = 'createdAt',
    bool descending = true,
  }) {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      return getUserNotesRef(userId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy(orderBy, descending: descending)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }

  //Toggle note archive status
  Future<void> toggleNoteArchive({
    required String userId,
    required String noteId,
    required bool isArchived,
  }) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      await getUserNotesRef(userId).doc(noteId).update({
        'isArchived': isArchived,
        'userId': userId, // Maintain userId for security
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    }
  }

  //Toggle note pin status
  Future<void> toggleNotePin({
    required String userId,
    required String noteId,
    required bool isPinned,
  }) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      await getUserNotesRef(userId).doc(noteId).update({
        'isPinned': isPinned,
        'userId': userId, // Maintain userId for security
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    }
  }

  //Update note tags
  Future<void> updateNoteTags({
    required String userId,
    required String noteId,
    required List<String> tags,
  }) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      await getUserNotesRef(userId).doc(noteId).update({
        'tags': tags,
        'userId': userId, // Maintain userId for security
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    }
  }

  //Batch delete multiple notes
  Future<void> batchDeleteNotes({
    required String userId,
    required List<String> noteIds,
  }) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      final batch = _firestore.batch();
      final userNotesRef = getUserNotesRef(userId);

      for (final noteId in noteIds) {
        batch.delete(userNotesRef.doc(noteId));
      }

      await batch.commit();

      // Update user's notes count
      await _updateUserNotesCount(userId, -noteIds.length);

    } catch (e) {
      rethrow;
    }
  }

  //Get user document
  Future<DocumentSnapshot> getUserDocument(String userId) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      return await usersRef.doc(userId).get();
    } catch (e) {
      rethrow;
    }
  }

  //Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (additionalData != null) updateData.addAll(additionalData);

      await usersRef.doc(userId).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  //Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      final userDoc = await getUserDocument(userId);
      final userData = userDoc.data() as Map<String, dynamic>?;

      // Get real-time notes count
      final notesQuery = await getUserNotesRef(userId).get();
      final totalNotes = notesQuery.docs.length;

      // Get archived notes count
      final archivedQuery = await getUserNotesRef(userId)
          .where('isArchived', isEqualTo: true)
          .get();
      final archivedNotes = archivedQuery.docs.length;

      // Get pinned notes count
      final pinnedQuery = await getUserNotesRef(userId)
          .where('isPinned', isEqualTo: true)
          .get();
      final pinnedNotes = pinnedQuery.docs.length;

      return {
        'totalNotes': totalNotes,
        'archivedNotes': archivedNotes,
        'pinnedNotes': pinnedNotes,
        'activeNotes': totalNotes - archivedNotes,
        'joinedAt': userData?['createdAt'],
        'lastLoginAt': userData?['lastLoginAt'],
      };
    } catch (e) {
      rethrow;
    }
  }

  //Clean up user data (for account deletion)
  Future<void> cleanupUserData(String userId) async {
    try {
      // Verify authentication
      if (_auth.currentUser == null || _auth.currentUser!.uid != userId) {
        throw Exception('User not authenticated or userId mismatch');
      }

      final batch = _firestore.batch();

      // Delete all user's notes
      final notesQuery = await getUserNotesRef(userId).get();
      for (final doc in notesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user document
      batch.delete(usersRef.doc(userId));

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  //Increment user's notes count
  Future<void> _incrementUserNotesCount(String userId) async {
    try {
      await usersRef.doc(userId).update({
        'notesCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't rethrow as this is not critical
    }
  }

  //Decrement user's notes count
  Future<void> _decrementUserNotesCount(String userId) async {
    try {
      await usersRef.doc(userId).update({
        'notesCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't rethrow as this is not critical
    }
  }

  //Update user's notes count by a specific amount
  Future<void> _updateUserNotesCount(String userId, int change) async {
    try {
      await usersRef.doc(userId).update({
        'notesCount': FieldValue.increment(change),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't rethrow as this is not critical
    }
  }

  //Check connectivity
  Future<bool> checkConnectivity() async {
    try {
      await _firestore.enableNetwork();
      return true;
    } catch (e) {
      return false;
    }
  }

  //Sync offline data
  Future<void> syncOfflineData() async {
    try {
      await _firestore.enableNetwork();
    } catch (e) {
    }
  }
}
