import 'package:flutter/foundation.dart';
import 'dart:developer';
import 'dart:async';
import '../../data/models/note_model.dart';
import '../../data/repositories/notes_repository.dart';

enum NotesState { initial, loading, loaded, error }

class NotesProvider extends ChangeNotifier {
  final NotesRepository _notesRepository;

  NotesProvider(this._notesRepository);

  NotesState _notesState = NotesState.initial;
  List<NoteModel> _notes = [];
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription<List<NoteModel>>? _notesSubscription;
  String? _currentUserId;
  int? _lastNotesHash;

  NotesState get notesState => _notesState;
  List<NoteModel> get notes => List.unmodifiable(_notes);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasNotes => _notes.isNotEmpty;
  int get notesCount => _notes.length;

  void initializeNotesStream(String userId) {
    try {
      _logOperation('Initializing notes stream for user: $userId');
      if (_currentUserId == userId && _notesSubscription != null) {
        _logOperation(
            'Stream already initialized for this user, skipping reinitialization');
        return;
      }
      if (_notesSubscription != null) {
        _logOperation('Cancelling existing stream subscription');
        _notesSubscription!.cancel();
        _notesSubscription = null;
      }
      _setLoadingState(true);
      _setNotesState(NotesState.loading);
      _clearError();
      _currentUserId = userId;
      _lastNotesHash = null;
      final stream = _notesRepository.getUserNotesStream(userId);
      _notesSubscription = stream.listen(
        (notes) {
          try {
            final currentHash = _createNotesHash(notes);
            _logOperation(
                'Stream update received - Current hash: $currentHash, Last hash: $_lastNotesHash, Notes count: ${notes.length}');
            if (_lastNotesHash == null || _lastNotesHash != currentHash) {
              _lastNotesHash = currentHash;
              _notes = notes;
              _setNotesState(NotesState.loaded);
              _setLoadingState(false);
              _clearError();
              notifyListeners();
              _logOperation(
                  '✅ Notes stream updated - Total notes: ${notes.length} (Hash: $currentHash)');
            } else {
              _logOperation(
                  '🚫 Duplicate stream update ignored - Hash unchanged: $currentHash');
            }
          } catch (e) {
            _logError('Error processing stream data', e);
            _handleStreamError('Error processing notes data: ${e.toString()}');
          }
        },
        onError: (error) {
          _logError('Notes stream error', error);
          final errorMessage = error.toString();
          if (errorMessage.toLowerCase().contains('network') ||
              errorMessage.toLowerCase().contains('connection') ||
              errorMessage.toLowerCase().contains('offline') ||
              errorMessage.toLowerCase().contains('unavailable')) {
            _handleStreamError('No internet connection. Please check your network and try again.');
          } else {
            _handleStreamError('Failed to load notes: $errorMessage');
          }
        },
        onDone: () {
          _logOperation('Notes stream completed');
        },
      );

      _logOperation('Notes stream subscription created successfully');
    } catch (e) {
      _logError('Failed to initialize notes stream', e);
      _handleStreamError('Failed to initialize notes stream: ${e.toString()}');
    }
  }

  void _handleStreamError(String errorMessage) {
    String userFriendlyMessage = _getUserFriendlyErrorMessage(errorMessage);
    _setError(userFriendlyMessage);
    _setNotesState(NotesState.error);
    _setLoadingState(false);
    notifyListeners();
  }

  String _getUserFriendlyErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    if (errorLower.contains('network') ||
        errorLower.contains('connection') ||
        errorLower.contains('offline') ||
        errorLower.contains('unavailable') ||
        errorLower.contains('failed host lookup') ||
        errorLower.contains('socket')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (errorLower.contains('permission') || errorLower.contains('denied')) {
      return 'Permission denied. Please check your account access.';
    }
    if (errorLower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    return error;
  }

  int _createNotesHash(List<NoteModel> notes) {
    if (notes.isEmpty) {
      _logOperation('Hash created for empty notes list: 0');
      return 0;
    }
    final sortedNotes = List<NoteModel>.from(notes)
      ..sort((a, b) => a.id.compareTo(b.id));
    String hashString = '';
    for (final note in sortedNotes) {
      hashString +=
          '${note.id}-${note.title}-${note.message.length}-${note.createdAt.millisecondsSinceEpoch}';
    }

    final hash = hashString.hashCode;
    _logOperation(
        'Hash created: $hash from ${notes.length} notes (stable hash)');

    return hash;
  }

  void refreshNotes(String userId) {
    _logOperation('Manual notes refresh requested - forcing reinitialization');
    _notesSubscription?.cancel();
    _notesSubscription = null;
    _currentUserId = null;
    _lastNotesHash = null;
    _clearError();
    _setLoadingState(true);
    _setNotesState(NotesState.loading);
    initializeNotesStream(userId);
  }

  Future<bool> addNote({
    required String title,
    required String message,
    required String userId,
  }) async {
    return await _performOperation(
      operation: () => _notesRepository.addNote(
        title: title,
        message: message,
        userId: userId,
      ),
      operationName: 'Creating note',
      successMessage: 'Note created successfully',
      context: {'title': title, 'userId': userId},
    );
  }

  Future<bool> updateNote({
    required String noteId,
    required String title,
    required String message,
    required String userId,
  }) async {
    return await _performOperation(
      operation: () => _notesRepository.updateNote(
        noteId: noteId,
        title: title,
        message: message,
        userId: userId,
      ),
      operationName: 'Updating note',
      successMessage: 'Note updated successfully',
      context: {'noteId': noteId, 'title': title},
    );
  }

  Future<bool> deleteNote({
    required String noteId,
    required String userId,
  }) async {
    return await _performOperation(
      operation: () => _notesRepository.deleteNote(
        noteId: noteId,
        userId: userId,
      ),
      operationName: 'Deleting note',
      successMessage: 'Note deleted successfully',
      context: {'noteId': noteId},
    );
  }

  Future<bool> _performOperation({
    required Future<void> Function() operation,
    required String operationName,
    required String successMessage,
    required Map<String, dynamic> context,
  }) async {
    final startTime = DateTime.now();

    try {
      _setLoadingState(true);
      _clearError();

      _logOperation('$operationName - ${context.toString()}');
      await operation();

      final duration = DateTime.now().difference(startTime);
      _logSuccess(successMessage, {
        ...context,
        'duration': '${duration.inMilliseconds}ms',
      });

      return true;
    } catch (e) {
      _logError('Failed to ${operationName.toLowerCase()}', e);
      final errorMessage = e.toString();
      String userFriendlyMessage;
      if (errorMessage.toLowerCase().contains('network') ||
          errorMessage.toLowerCase().contains('connection') ||
          errorMessage.toLowerCase().contains('offline') ||
          errorMessage.toLowerCase().contains('unavailable')) {
        userFriendlyMessage = 'No internet connection. Please check your network and try again.';
      } else {
        userFriendlyMessage = errorMessage;
      }
      _setError(userFriendlyMessage);
      _setNotesState(NotesState.error);
      return false;
    } finally {
      _setLoadingState(false);
    }
  }

  Future<NoteModel?> getNoteById(String noteId, String userId) async {
    try {
      _clearError();
      _logOperation('Fetching note by ID - ID: $noteId');

      final note = await _notesRepository.getNoteById(noteId, userId);

      if (note != null) {
        _logOperation('Note fetched successfully - Title: ${note.title}');
      } else {
        _logOperation('Note not found - ID: $noteId');
      }

      return note;
    } catch (e) {
      _logError('Failed to fetch note', e);
      _setError(e.toString());
      return null;
    }
  }

  List<NoteModel> searchNotes(String query) {
    if (query.trim().isEmpty) return notes;

    final lowercaseQuery = query.toLowerCase();
    final results = _notes.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
          note.message.toLowerCase().contains(lowercaseQuery);
    }).toList();

    _logOperation(
        'Search performed - Query: "$query", Results: ${results.length}');
    return results;
  }

  List<NoteModel> getNotesInDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final results = _notes.where((note) {
      return note.createdAt
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          note.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    _logOperation('Date range filter applied - Results: ${results.length}');
    return results;
  }

  List<NoteModel> getTodayNotes() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final results = _notes.where((note) {
      return note.createdAt
              .isAfter(today.subtract(const Duration(seconds: 1))) &&
          note.createdAt.isBefore(tomorrow);
    }).toList();

    _logOperation('Today\'s notes retrieved - Count: ${results.length}');
    return results;
  }

  void clearNotes() {
    final previousCount = _notes.length;
    _notesSubscription?.cancel();
    _notesSubscription = null;
    _currentUserId = null;
    _notes.clear();
    _lastNotesHash = null;
    _setNotesState(NotesState.initial);
    _clearError();
    _setLoadingState(false);
    notifyListeners();

    _logOperation('Notes cleared - Previous count: $previousCount');
  }

  void clearError() => _clearError();

  void setLoading(bool loading) {
    _setLoadingState(loading);
  }

  bool get isStreamActive => _notesSubscription != null && _currentUserId != null;

  void _setNotesState(NotesState state) {
    if (_notesState != state) {
      _notesState = state;
      notifyListeners();
    }
  }

  void _setLoadingState(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _logOperation(String message) {
    final timestamp = DateTime.now().toIso8601String();
    log('[$timestamp] NotesProvider: $message');
  }

  void _logSuccess(String message, Map<String, dynamic> data) {
    final timestamp = DateTime.now().toIso8601String();
    log('[$timestamp] ✅ NotesProvider SUCCESS: $message');
    log('[$timestamp] Details: ${data.toString()}');
  }

  void _logError(String message, dynamic error) {
    final timestamp = DateTime.now().toIso8601String();
    log('[$timestamp] ❌ NotesProvider ERROR: $message');
    log('[$timestamp] Error: ${error.toString()}');
  }

  @override
  void dispose() {
    _logOperation('NotesProvider disposed - Cleaning up resources');
    _notesSubscription?.cancel();
    _notesSubscription = null;
    _currentUserId = null;
    _notes.clear();
    _lastNotesHash = null;

    super.dispose();
  }
}
