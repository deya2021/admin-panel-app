/// Form validation utilities
class Validators {
  Validators._();

  /// Email regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone regex pattern (international format)
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName مطلوب' // Required
          : 'هذا الحقل مطلوب'; // This field is required
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب'; // Email is required
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح'; // Invalid email
    }
    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب'; // Phone number is required
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'رقم الهاتف غير صحيح'; // Invalid phone number
    }
    return null;
  }

  /// Validate password
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة'; // Password is required
    }
    if (value.length < minLength) {
      return 'كلمة المرور يجب أن تكون $minLength أحرف على الأقل'; // Password must be at least X characters
    }
    return null;
  }

  /// Validate number
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName مطلوب'
          : 'هذا الحقل مطلوب';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'يجب أن يكون رقماً'; // Must be a number
    }
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, {String? fieldName}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final numValue = double.parse(value!.trim());
    if (numValue <= 0) {
      return 'يجب أن يكون رقماً موجباً'; // Must be a positive number
    }
    return null;
  }

  /// Validate integer
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName مطلوب'
          : 'هذا الحقل مطلوب';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'يجب أن يكون رقماً صحيحاً'; // Must be an integer
    }
    return null;
  }

  /// Validate positive integer
  static String? positiveInteger(String? value, {String? fieldName}) {
    final intError = integer(value, fieldName: fieldName);
    if (intError != null) return intError;

    final intValue = int.parse(value!.trim());
    if (intValue <= 0) {
      return 'يجب أن يكون رقماً صحيحاً موجباً'; // Must be a positive integer
    }
    return null;
  }

  /// Validate min length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName مطلوب'
          : 'هذا الحقل مطلوب';
    }
    if (value.length < min) {
      return fieldName != null
          ? '$fieldName يجب أن يكون $min أحرف على الأقل'
          : 'يجب أن يكون $min أحرف على الأقل';
    }
    return null;
  }

  /// Validate max length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return fieldName != null
          ? '$fieldName يجب أن يكون $max أحرف كحد أقصى'
          : 'يجب أن يكون $max أحرف كحد أقصى';
    }
    return null;
  }

  /// Validate range
  static String? range(String? value, double min, double max, {String? fieldName}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final numValue = double.parse(value!.trim());
    if (numValue < min || numValue > max) {
      return fieldName != null
          ? '$fieldName يجب أن يكون بين $min و $max'
          : 'يجب أن يكون بين $min و $max';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

