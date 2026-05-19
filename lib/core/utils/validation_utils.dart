import 'package:get/get.dart';

class ValidationUtils {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isPhoneNumber(value)) {
        return 'Please enter a valid phone number';
      }
      if (value.length < 10) {
        return 'Phone number must be at least 10 digits';
      }
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, String fieldName) {
    final numberError = validateNumber(value, fieldName);
    if (numberError != null) return numberError;
    
    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    final priceError = validatePositiveNumber(value, 'Price');
    if (priceError != null) return priceError;
    
    final price = double.parse(value!);
    if (price > 10000000) {
      return 'Price seems too high';
    }
    return null;
  }

  static String? validateDuration(String? value) {
    final durationError = validatePositiveNumber(value, 'Duration');
    if (durationError != null) return durationError;
    
    final duration = int.parse(value!);
    if (duration < 15) {
      return 'Duration must be at least 15 minutes';
    }
    if (duration > 480) {
      return 'Duration cannot exceed 8 hours';
    }
    return null;
  }

  static String? validateRating(String? value) {
    final ratingError = validateNumber(value, 'Rating');
    if (ratingError != null) return ratingError;
    
    final rating = double.parse(value!);
    if (rating < 0 || rating > 5) {
      return 'Rating must be between 0 and 5';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    if (value.length > 200) {
      return 'Address is too long';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 10) {
        return 'Description must be at least 10 characters';
      }
      if (value.length > 500) {
        return 'Description is too long';
      }
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
