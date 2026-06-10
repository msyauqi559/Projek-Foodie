class AuthValidators {
  const AuthValidators._();

  static bool isValidEmailFormat(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  static bool isPasswordLongEnough(String password) {
    return password.length >= 8;
  }

  static String? emailError(String email) {
    if (email.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    if (!isValidEmailFormat(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? passwordError(String password) {
    if (password.isEmpty) {
      return 'Sandi wajib diisi';
    }
    if (!isPasswordLongEnough(password)) {
      return 'Sandi minimal 8 karakter';
    }
    return null;
  }
}
