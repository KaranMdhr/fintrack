final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final String email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address.';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address.';
  return null;
}

String? validatePassword(
  String? value, {
  String emptyMessage = 'Enter your password.',
}) {
  final String password = value ?? '';
  if (password.isEmpty) return emptyMessage;
  if (password.length < 6) return 'Use at least 6 characters.';
  return null;
}

String? validateRequired(String? value, {String field = 'This field'}) {
  if (value == null || value.trim().isEmpty) return '$field is required.';
  return null;
}
