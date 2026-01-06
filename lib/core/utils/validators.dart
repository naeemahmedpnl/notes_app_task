class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }

    return null;
  }

  static String? validatePasswordConfirmation(
      String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateNoteTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }

    if (value.trim().length < 2) {
      return 'Title must be at least 2 characters long';
    }

    if (value.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }

    return null;
  }

  static String? validateNoteMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }

    if (value.trim().length < 5) {
      return 'Message must be at least 5 characters long';
    }

    if (value.trim().length > 1000) {
      return 'Message must be less than 1000 characters';
    }

    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }

    if (value.trim().length < 2) {
      return 'Display name must be at least 2 characters long';
    }

    if (value.trim().length > 50) {
      return 'Display name must be less than 50 characters';
    }
    final nameRegex = RegExp(r'^[a-zA-Z0-9\s\-_.]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Display name contains invalid characters';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMinLength(
      String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    return null;
  }

  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }

  static String? validateLengthRange(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    if (trimmedValue.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  String? validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');

    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value.trim());

    if (age == null) {
      return 'Age must be a valid number';
    }

    if (age < 1) {
      return 'Age must be greater than 0';
    }

    if (age > 150) {
      return 'Age must be less than 150';
    }

    return null;
  }

  static String? combineValidators(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
