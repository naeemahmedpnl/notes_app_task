import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class NoteModel {
  final String id;
  final String title;
  final String message;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final bool isPinned;
  final List<String> tags;
  final String? color;

  const NoteModel({
    required this.id,
    required this.title,
    required this.message,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.isPinned = false,
    this.tags = const [],
    this.color,
  });

  factory NoteModel.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    try {
      return NoteModel(
        id: documentId,
        title: data['title']?.toString() ?? '',
        message: data['message']?.toString() ?? '',
        userId: data['userId']?.toString() ?? '',
        createdAt: _parseTimestamp(data['createdAt']),
        updatedAt: _parseTimestamp(data['updatedAt']),
        isArchived: data['isArchived'] as bool? ?? false,
        isPinned: data['isPinned'] as bool? ?? false,
        tags: _parseStringList(data['tags']),
        color: data['color']?.toString(),
      );
    } catch (e) {
      return NoteModel(
        id: documentId,
        title: 'Error Loading Note',
        message: 'This note could not be loaded properly.',
        userId: data['userId']?.toString() ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    try {
      return NoteModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
        isArchived: json['isArchived'] as bool? ?? false,
        isPinned: json['isPinned'] as bool? ?? false,
        tags: _parseStringList(json['tags']),
        color: json['color']?.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isArchived': isArchived,
      'isPinned': isPinned,
      'tags': tags,
      'color': color,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isArchived': isArchived,
      'isPinned': isPinned,
      'tags': tags,
      'color': color,
    };
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? message,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isPinned,
    List<String>? tags,
    String? color,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  String get messagePreview {
    if (message.isEmpty) return 'No content';

    const maxLength = 100;
    if (message.length <= maxLength) return message;

    final truncated = message.substring(0, maxLength);
    final lastSpaceIndex = truncated.lastIndexOf(' ');

    if (lastSpaceIndex > 0) {
      return '${truncated.substring(0, lastSpaceIndex)}...';
    }

    return '$truncated...';
  }

  int get wordCount {
    if (message.trim().isEmpty) return 0;
    return message.trim().split(RegExp(r'\s+')).length;
  }

  int get characterCount => message.length;

  bool get isRecentlyCreated {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inMinutes < 60;
  }

  bool get wasEdited {
    final difference = updatedAt.difference(createdAt);
    return difference.inMinutes > 1;
  }

  String get timeSinceUpdate {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedCreationDate {
    return _formatDate(createdAt);
  }

  String get formattedUpdateDate {
    return _formatDate(updatedAt);
  }

  bool containsQuery(String query) {
    if (query.trim().isEmpty) return true;

    final lowercaseQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowercaseQuery) ||
        message.toLowerCase().contains(lowercaseQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }

  bool get hasTags => tags.isNotEmpty;
  bool get hasCustomColor => color != null && color!.isNotEmpty;

  String get status {
    if (isArchived) return 'Archived';
    if (isPinned) return 'Pinned';
    return 'Active';
  }

  int get estimatedReadingTime {
    const wordsPerMinute = 200;
    final words = wordCount;
    final minutes = (words / wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  bool get isEmpty => title.trim().isEmpty && message.trim().isEmpty;
  bool get isValid => title.trim().isNotEmpty || message.trim().isNotEmpty;

  int get priority {
    if (isPinned) return 3;
    if (isRecentlyCreated) return 2;
    return 1;
  }

  Map<String, dynamic> toSearchIndex() {
    return {
      'id': id,
      'title_lower': title.toLowerCase(),
      'message_lower': message.toLowerCase(),
      'tags_lower': tags.map((tag) => tag.toLowerCase()).toList(),
      'word_count': wordCount,
      'character_count': characterCount,
      'created_timestamp': createdAt.millisecondsSinceEpoch,
      'updated_timestamp': updatedAt.millisecondsSinceEpoch,
      'is_archived': isArchived,
      'is_pinned': isPinned,
    };
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return DateTime.now();
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    try {
      if (dateTime is String) {
        return DateTime.parse(dateTime);
      } else if (dateTime is Timestamp) {
        return dateTime.toDate();
      } else if (dateTime is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateTime);
      } else {
        return DateTime.now();
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  static List<String> _parseStringList(dynamic list) {
    try {
      if (list is List) {
        return list.map((item) => item.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) {
      return 'Today ${_formatTime(date)}';
    } else if (noteDate == yesterday) {
      return 'Yesterday ${_formatTime(date)}';
    } else if (now.difference(date).inDays < 7) {
      return '${_getDayName(date.weekday)} ${_formatTime(date)}';
    } else if (date.year == now.year) {
      return '${_getMonthName(date.month)} ${date.day} ${_formatTime(date)}';
    } else {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  static String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NoteModel &&
        other.id == id &&
        other.title == title &&
        other.message == message &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isArchived == isArchived &&
        other.isPinned == isPinned &&
        listEquals(other.tags, tags) &&
        other.color == color;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      message,
      userId,
      createdAt,
      updatedAt,
      isArchived,
      isPinned,
      tags,
      color,
    );
  }

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, userId: $userId, '
        'createdAt: $createdAt, isArchived: $isArchived, isPinned: $isPinned)';
  }
}

//Extension methods for List<NoteModel>
extension NoteListExtensions on List<NoteModel> {
  //Filter notes by archived status
  List<NoteModel> filterByArchived(bool isArchived) {
    return where((note) => note.isArchived == isArchived).toList();
  }

  List<NoteModel> filterByPinned(bool isPinned) {
    return where((note) => note.isPinned == isPinned).toList();
  }

  List<NoteModel> filterByTag(String tag) {
    return where((note) => note.tags.contains(tag)).toList();
  }

  List<NoteModel> search(String query) {
    if (query.trim().isEmpty) return this;
    return where((note) => note.containsQuery(query)).toList();
  }

  List<NoteModel> sortByCreationDate({bool descending = true}) {
    final sorted = List<NoteModel>.from(this);
    sorted.sort((a, b) => descending
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  List<NoteModel> sortByUpdateDate({bool descending = true}) {
    final sorted = List<NoteModel>.from(this);
    sorted.sort((a, b) => descending
        ? b.updatedAt.compareTo(a.updatedAt)
        : a.updatedAt.compareTo(b.updatedAt));
    return sorted;
  }

  List<NoteModel> sortByTitle({bool descending = false}) {
    final sorted = List<NoteModel>.from(this);
    sorted.sort((a, b) =>
        descending ? b.title.compareTo(a.title) : a.title.compareTo(b.title));
    return sorted;
  }

  List<NoteModel> sortByPriority() {
    final sorted = List<NoteModel>.from(this);
    sorted.sort((a, b) {
      final priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return sorted;
  }

  int get totalWordCount {
    return fold<int>(0, (sum, note) => sum + note.wordCount);
  }

  int get totalCharacterCount {
    return fold<int>(0, (sum, note) => sum + note.characterCount);
  }

  List<String> get allTags {
    final tags = <String>{};
    for (final note in this) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }

  Map<String, List<NoteModel>> groupByDate() {
    final grouped = <String, List<NoteModel>>{};

    for (final note in this) {
      final dateKey = note.formattedCreationDate.split(' ').first;
      grouped.putIfAbsent(dateKey, () => []).add(note);
    }

    return grouped;
  }

  List<NoteModel> get recentNotes {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return where((note) => note.createdAt.isAfter(sevenDaysAgo)).toList();
  }

  List<NoteModel> get activeNotes => filterByArchived(false);
  List<NoteModel> get archivedNotes => filterByArchived(true);
  List<NoteModel> get pinnedNotes => filterByPinned(true);
}
