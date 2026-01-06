class FirebaseConstants {
  static const String notesCollection = 'notes';
  static const String usersCollection = 'users';
  static const String settingsCollection = 'settings';
  static const String feedbackCollection = 'feedback';
  static const String idField = 'id';
  static const String titleField = 'title';
  static const String messageField = 'message';
  static const String userIdField = 'userId';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String emailField = 'email';
  static const String displayNameField = 'displayName';
  static const String emailVerifiedField = 'emailVerified';
  static const String lastSignInTimeField = 'lastSignInTime';
  static const String creationTimeField = 'creationTime';
  static const String userNotFoundError = 'user-not-found';
  static const String wrongPasswordError = 'wrong-password';
  static const String emailAlreadyInUseError = 'email-already-in-use';
  static const String weakPasswordError = 'weak-password';
  static const String invalidEmailError = 'invalid-email';
  static const String userDisabledError = 'user-disabled';
  static const String tooManyRequestsError = 'too-many-requests';
  static const String operationNotAllowedError = 'operation-not-allowed';
  static const String networkRequestFailedError = 'network-request-failed';
  static const String invalidCredentialError = 'invalid-credential';
  static const int defaultQueryLimit = 50;
  static const int maxQueryLimit = 100;
  static const int searchQueryLimit = 20;
  static const String notesUserIdCreatedAtIndex = 'notes_userId_createdAt';
  static const String notesUserIdUpdatedAtIndex = 'notes_userId_updatedAt';
  static const String notesUserIdTitleIndex = 'notes_userId_title';
  static const String userAvatarsPath = 'user_avatars';
  static const String noteAttachmentsPath = 'note_attachments';
  static const String tempUploadsPath = 'temp_uploads';
  static const String authenticatedUserRule = 'request.auth != null';
  static const String resourceOwnerRule = 'request.auth.uid == resource.data.userId';
  static const String createOwnerRule = 'request.auth.uid == request.resource.data.userId';
  static const bool enableOfflinePersistence = true;
  static const int cacheSizeBytes = 100 * 1024 * 1024;
  static const bool enableAppCheck = false;
  static const String appCheckToken = 'your-app-check-token';
  static const String noteCreatedEvent = 'note_created';
  static const String noteUpdatedEvent = 'note_updated';
  static const String noteDeletedEvent = 'note_deleted';
  static const String noteSearchedEvent = 'note_searched';
  static const String userSignedInEvent = 'user_signed_in';
  static const String userSignedUpEvent = 'user_signed_up';
  static const String userSignedOutEvent = 'user_signed_out';
  static const String authSignInTrace = 'auth_sign_in';
  static const String authSignUpTrace = 'auth_sign_up';
  static const String notesLoadTrace = 'notes_load';
  static const String noteCreateTrace = 'note_create';
  static const String noteUpdateTrace = 'note_update';
  static const String noteDeleteTrace = 'note_delete';
  static const String maxNotesPerUserKey = 'max_notes_per_user';
  static const String enableNewFeaturesKey = 'enable_new_features';
  static const String maintenanceModeKey = 'maintenance_mode';
  static const String minAppVersionKey = 'min_app_version';
  static const String allUsersTopic = 'all_users';
  static const String androidUsersTopic = 'android_users';
  static const String iosUsersTopic = 'ios_users';
  static const String webUsersTopic = 'web_users';
  static const String cleanupNotesFunction = 'cleanupNotes';
  static const String sendWelcomeEmailFunction = 'sendWelcomeEmail';
  static const String generateReportFunction = 'generateReport';
  static const String processImageFunction = 'processImage';
  static const Map<String, dynamic> noteValidationRules = {
    'title': {
      'required': true,
      'type': 'string',
      'minLength': 2,
      'maxLength': 100,
    },
    'message': {
      'required': true,
      'type': 'string',
      'minLength': 5,
      'maxLength': 1000,
    },
    'userId': {
      'required': true,
      'type': 'string',
      'pattern': r'^[a-zA-Z0-9]+$',
    },
    'createdAt': {
      'required': true,
      'type': 'timestamp',
    },
    'updatedAt': {
      'required': true,
      'type': 'timestamp',
    },
  };
  static const String firestorePermissionDenied = 'Permission denied. Please sign in again.';
  static const String firestoreUnavailable = 'Service temporarily unavailable. Please try again.';
  static const String firestoreQuotaExceeded = 'Quota exceeded. Please try again later.';
  static const String firestoreNotFound = 'Document not found.';
  static const String firestoreAlreadyExists = 'Document already exists.';
  static const String firestoreAborted = 'Operation aborted. Please try again.';
  static const String firestoreOutOfRange = 'Operation out of range.';
  static const String firestoreUnimplemented = 'Operation not implemented.';
  static const String firestoreInternal = 'Internal error occurred.';
  static const String firestoreDeadlineExceeded = 'Operation timeout. Please try again.';
  static const int maxBatchWrites = 500;
  static const int maxTransactionRetries = 5;
  static const Duration transactionTimeout = Duration(seconds: 30);
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const String paginationTokenField = 'paginationToken';
  static const int minSearchLength = 2;
  static const int maxSearchLength = 50;
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration defaultCacheExpiry = Duration(hours: 1);
  static const Duration shortCacheExpiry = Duration(minutes: 15);
  static const Duration longCacheExpiry = Duration(days: 1);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration readTimeout = Duration(seconds: 30);
  static const Duration writeTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
