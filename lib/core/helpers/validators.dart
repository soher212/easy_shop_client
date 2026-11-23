class Validators {
  Validators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(text)) return 'Enter a valid email';
    return null;
  }

  static String? fullName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Full name is required';
    final words = text.split(RegExp(r'\s+'));
    if (words.length < 2) return 'Enter your full name (first and last name)';
    return null;
  }

  static String normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[\s\-]'), '');
  }

  static String? phone(String? value) {
    final text = normalizePhone(value ?? '');
    if (text.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\+20\d{10}$').hasMatch(text)) {
      return 'Phone must start with +20 followed by 10 digits';
    }
    return null;
  }

  static String? nationalId(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'National ID is required';
    if (!RegExp(r'^[23]\d{13}$').hasMatch(text)) {
      return 'National ID must be 14 digits starting with 2 or 3';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if ((value ?? '').isEmpty) return 'Please confirm your password';
      if (value != original()) return 'Passwords do not match';
      return null;
    };
  }

  static String? required(String? value, String fieldName) {
    if ((value?.trim() ?? '').isEmpty) return '$fieldName is required';
    return null;
  }

  static String? price(String? value) {
    final number = double.tryParse((value ?? '').trim());
    if (number == null) return 'Enter a valid price';
    if (number <= 0) return 'Price must be greater than 0';
    return null;
  }

  static String? quantity(String? value) {
    final number = int.tryParse((value ?? '').trim());
    if (number == null) return 'Enter a whole number';
    if (number < 0) return 'Quantity cannot be negative';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
