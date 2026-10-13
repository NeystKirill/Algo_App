/// Validates password strength for registration. Returns an error message
/// in Russian, or null if the password satisfies all rules.
String? validatePasswordStrength(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введите пароль';
  }
  if (value.length < 8) {
    return 'Минимум 8 символов';
  }
  if (!RegExp(r'[A-ZА-Я]').hasMatch(value)) {
    return 'Добавьте хотя бы одну заглавную букву';
  }
  if (!RegExp(r'[a-zа-я]').hasMatch(value)) {
    return 'Добавьте хотя бы одну строчную букву';
  }
  if (!RegExp(r'\d').hasMatch(value)) {
    return 'Добавьте хотя бы одну цифру';
  }
  if (!RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-\[\]~`+=/\\;'’]''').hasMatch(value)) {
    return 'Добавьте хотя бы один специальный символ';
  }
  return null;
}
