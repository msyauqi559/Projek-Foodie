class AuthValidators {
  const AuthValidators._();

  static bool hasGmailDomain(String email) {
    return email.trim().toLowerCase().contains('@gmail.com');
  }

  static bool isPasswordLongEnough(String password) {
    return password.length >= 8;
  }

  static String? emailError(String email) {
    if (email.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    if (!hasGmailDomain(email)) {
      return 'Email harus mengandung @gmail.com';
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
