import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import '../services/firebase_service.dart';

//Optimized Notes Repository with minimal logging and essential functions only
class NotesRepository {
  final FirebaseService _firebaseService = FirebaseService();

  //Add new note
  Future<String> addNote({
    required String title,
    required String message,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _validateNoteInput(title, message, userId);

      final docRef = await _firebaseService.createNote(
        userId: userId,
        title: title,
        message: message,
        metadata: metadata,
      );

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  //Update existing note
  Future<void> updateNote({
    required String noteId,
    required String title,
    required String message,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _validateNoteInput(title, message, userId, noteId: noteId);

      await _firebaseService.updateNote(
        userId: userId,
        noteId: noteId,
        title: title,
        message: message,
        metadata: metadata,
      );

    } catch (e) {
      rethrow;
    }
  }

  //Delete note
  Future<void> deleteNote({
    required String noteId,
    required String userId,
  }) async {
    try {
      _validateIds(noteId, userId);

      await _firebaseService.deleteNote(
        userId: userId,
        noteId: noteId,
      );

    } catch (e) {
      rethrow;
    }
  }

  //Get note by ID
  Future<NoteModel?> getNoteById(String noteId, String userId) async {
    try {
      _validateIds(noteId, userId);

      final docSnapshot = await _firebaseService.getNote(
        userId: userId,
        noteId: noteId,
      );

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return NoteModel.fromFirestore(data, docSnapshot.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  //Get user's notes stream with filtering options
  Stream<List<NoteModel>> getUserNotesStream(
    String userId, {
    int? limit,
    String? orderBy,
    bool? descending,
    bool includeArchived = false,
    bool pinnedOnly = false,
    bool archivedOnly = false,
  }) {
    try {
      if (userId.isEmpty) throw Exception('User ID is required');

      Query<Object?> queryBuilder(Query<Object?> query) {
        // Apply filters based on parameters
        if (archivedOnly) {
          query = query.where('isArchived', isEqualTo: true);
        } else if (!includeArchived) {
          query = query.where('isArchived', isEqualTo: false);
        }

        if (pinnedOnly) {
          query = query.where('isPinned', isEqualTo: true);
        }

        // Apply ordering
        final orderField = orderBy ?? 'updatedAt';
        final isDescending = descending ?? true;
        query = query.orderBy(orderField, descending: isDescending);

        // Apply limit
        if (limit != null) {
          query = query.limit(limit);
        }

        return query;
      }

      return _firebaseService
          .getUserNotesStream(userId, queryBuilder: queryBuilder)
          .map((querySnapshot) => _parseNotesList(querySnapshot, userId));
    } catch (e) {
      rethrow;
    }
  }

  //Search notes by title or content
  Stream<List<NoteModel>> searchNotes({
    required String userId,
    required String searchQuery,
    int? limit,
  }) {
    try {
      if (userId.isEmpty) throw Exception('User ID is required');
      if (searchQuery.trim().isEmpty) return Stream.value([]);

      return _firebaseService
          .searchNotes(
            userId: userId,
            searchQuery: searchQuery.toLowerCase(),
            limit: limit,
          )
          .map((querySnapshot) => _parseNotesList(querySnapshot, userId));
    } catch (e) {
      rethrow;
    }
  }

  //Get notes in date range
  Stream<List<NoteModel>> getNotesInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String orderBy = 'createdAt',
    bool descending = true,
  }) {
    try {
      if (userId.isEmpty) throw Exception('User ID is required');
      if (startDate.isAfter(endDate)) {
        throw Exception('Start date cannot be after end date');
      }

      return _firebaseService
          .getNotesByDateRange(
            userId: userId,
            startDate: startDate,
            endDate: endDate,
            orderBy: orderBy,
            descending: descending,
          )
          .map((querySnapshot) => _parseNotesList(querySnapshot, userId));
    } catch (e) {
      rethrow;
    }
  }

  //Toggle note archive status
  Future<void> toggleNoteArchive({
    required String noteId,
    required String userId,
    required bool isArchived,
  }) async {
    try {
      _validateIds(noteId, userId);
      await _firebaseService.toggleNoteArchive(
        userId: userId,
        noteId: noteId,
        isArchived: isArchived,
      );
    } catch (e) {
      rethrow;
    }
  }

  //Toggle note pin status
  Future<void> toggleNotePin({
    required String noteId,
    required String userId,
    required bool isPinned,
  }) async {
    try {
      _validateIds(noteId, userId);
      await _firebaseService.toggleNotePin(
        userId: userId,
        noteId: noteId,
        isPinned: isPinned,
      );
    } catch (e) {
      rethrow;
    }
  }

  //Update note tags
  Future<void> updateNoteTags({
    required String noteId,
    required String userId,
    required List<String> tags,
  }) async {
    try {
      _validateIds(noteId, userId);

      final cleanTags = tags
          .map((tag) => tag.trim().toLowerCase())
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList();

      await _firebaseService.updateNoteTags(
        userId: userId,
        noteId: noteId,
        tags: cleanTags,
      );
    } catch (e) {
      rethrow;
    }
  }

  //Delete multiple notes at once
  Future<void> batchDeleteNotes({
    required String userId,
    required List<String> noteIds,
  }) async {
    try {
      if (userId.isEmpty) throw Exception('User ID is required');
      if (noteIds.isEmpty) throw Exception('Note IDs list cannot be empty');

      final validNoteIds = noteIds.where((id) => id.isNotEmpty).toList();
      if (validNoteIds.isEmpty) throw Exception('No valid note IDs provided');

      await _firebaseService.batchDeleteNotes(
        userId: userId,
        noteIds: validNoteIds,
      );
    } catch (e) {
      rethrow;
    }
  }

  //Get user notes statistics
  Future<Map<String, dynamic>> getUserNotesStats(String userId) async {
    try {
      if (userId.isEmpty) throw Exception('User ID is required');
      return await _firebaseService.getUserStats(userId);
    } catch (e) {
      rethrow;
    }
  }

  //Check connectivity
  Future<bool> isOnline() async {
    try {
      return await _firebaseService.checkConnectivity();
    } catch (e) {
      return false;
    }
  }

  //Sync offline data
  Future<void> syncOfflineData() async {
    try {
      await _firebaseService.syncOfflineData();
    } catch (e) {
      rethrow;
    }
  }

  //Get notes count
  Future<int> getNotesCount(String userId) async {
    try {
      if (userId.isEmpty) throw Exception('User ID is required');

      final userDoc = await _firebaseService.getUserDocument(userId);
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['notesCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  //Get today's notes
  Stream<List<NoteModel>> getTodayNotes(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getNotesInDateRange(
      userId: userId,
      startDate: startOfDay,
      endDate: endOfDay,
      orderBy: 'createdAt',
      descending: true,
    );
  }

  //Get recent notes (last 7 days)
  Stream<List<NoteModel>> getRecentNotes(String userId, {int days = 7}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    return getNotesInDateRange(
      userId: userId,
      startDate: startDate,
      endDate: now,
      orderBy: 'updatedAt',
      descending: true,
    );
  }

  //Get pinned notes
  Stream<List<NoteModel>> getPinnedNotes(String userId) {
    return getUserNotesStream(
      userId,
      pinnedOnly: true,
      orderBy: 'updatedAt',
      descending: true,
    );
  }

  //Get archived notes
  Stream<List<NoteModel>> getArchivedNotes(String userId) {
    return getUserNotesStream(
      userId,
      archivedOnly: true,
      orderBy: 'updatedAt',
      descending: true,
    );
  }

  //Restore note from archive
  Future<void> restoreNoteFromArchive({
    required String noteId,
    required String userId,
  }) async {
    return toggleNoteArchive(
      noteId: noteId,
      userId: userId,
      isArchived: false,
    );
  }

  //Permanently delete archived notes
  Future<void> permanentlyDeleteArchivedNotes(String userId) async {
    try {
      if (userId.isEmpty) throw Exception('User ID is required');

      final archivedNotesSnapshot = await _firebaseService
          .getUserNotesRef(userId)
          .where('isArchived', isEqualTo: true)
          .get();

      if (archivedNotesSnapshot.docs.isNotEmpty) {
        final noteIds =
            archivedNotesSnapshot.docs.map((doc) => doc.id).toList();
        await batchDeleteNotes(userId: userId, noteIds: noteIds);
      }
    } catch (e) {
      rethrow;
    }
  }

  //Export notes as JSON
  Future<List<Map<String, dynamic>>> exportNotesAsJson(String userId) async {
    try {
      if (userId.isEmpty) throw Exception('User ID is required');

      final notesSnapshot = await _firebaseService
          .getUserNotesRef(userId)
          .orderBy('createdAt', descending: false)
          .get();

      return notesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final exportData = Map<String, dynamic>.from(data);

        // Convert Timestamps to ISO strings
        if (exportData['createdAt'] is Timestamp) {
          exportData['createdAt'] =
              (exportData['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (exportData['updatedAt'] is Timestamp) {
          exportData['updatedAt'] =
              (exportData['updatedAt'] as Timestamp).toDate().toIso8601String();
        }

        return exportData;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  //Import notes from JSON
  Future<int> importNotesFromJson({
    required String userId,
    required List<Map<String, dynamic>> notesData,
  }) async {
    try {
      if (userId.isEmpty) throw Exception('User ID is required');
      if (notesData.isEmpty) return 0;

      int importedCount = 0;

      for (final noteData in notesData) {
        try {
          final title = noteData['title']?.toString() ?? 'Imported Note';
          final message = noteData['message']?.toString() ?? '';

          final metadata = <String, dynamic>{};
          if (noteData['tags'] != null) metadata['tags'] = noteData['tags'];
          if (noteData['isArchived'] != null)
            metadata['isArchived'] = noteData['isArchived'];
          if (noteData['isPinned'] != null)
            metadata['isPinned'] = noteData['isPinned'];
          if (noteData['color'] != null) metadata['color'] = noteData['color'];

          await addNote(
            title: title,
            message: message,
            userId: userId,
            metadata: metadata,
          );
          importedCount++;
        } catch (e) {
          continue;
        }
      }

      return importedCount;
    } catch (e) {
      rethrow;
    }
  }

  //Clean up user notes (for account deletion)
  Future<void> cleanupUserNotes(String userId) async {
    try {
      if (userId.isEmpty) throw Exception('User ID is required');

      final notesSnapshot =
          await _firebaseService.getUserNotesRef(userId).get();
      if (notesSnapshot.docs.isNotEmpty) {
        final noteIds = notesSnapshot.docs.map((doc) => doc.id).toList();
        await batchDeleteNotes(userId: userId, noteIds: noteIds);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Private helper methods
  void _validateNoteInput(String title, String message, String userId,
      {String? noteId}) {
    if (noteId != null && noteId.isEmpty)
      throw Exception('Note ID is required');
    if (title.trim().isEmpty) throw Exception('Note title cannot be empty');
    if (message.trim().isEmpty) throw Exception('Note message cannot be empty');
    if (userId.isEmpty) throw Exception('User ID is required');
  }

  void _validateIds(String noteId, String userId) {
    if (noteId.isEmpty) throw Exception('Note ID is required');
    if (userId.isEmpty) throw Exception('User ID is required');
  }

  List<NoteModel> _parseNotesList(QuerySnapshot querySnapshot, String userId) {
    return querySnapshot.docs
        .map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            return NoteModel.fromFirestore(data, doc.id);
          } catch (e) {
            return null;
          }
        })
        .where((note) => note != null)
        .cast<NoteModel>()
        .toList();
  }
}
