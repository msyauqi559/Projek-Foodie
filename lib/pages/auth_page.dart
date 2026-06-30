import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_spacing.dart';
import '../services/app_navigation.dart';
import '../services/database_helper.dart';
import '../utils/auth_validators.dart';
import '../utils/responsive.dart';
import '../widgets/app_text_field.dart';
import '../widgets/reusable_button.dart';
import '../widgets/reusable_image.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // 1. Variabel State untuk mengelola tampilan halaman atau penampung status (State)
  bool isLogin = true;
  bool isPasswordHidden = true;
  bool rememberMe = false;

  // 2. Controller untuk mengambil input form dari user
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Membaca email & password yang tersimpan di HP
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final savedRememberMe = prefs.getBool('remember_me') ?? false;

    if (savedRememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        rememberMe = true;
      });
    }
  }

  // Menyimpan email & password ke memori HP
  Future<void> _savedCredential() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('saved_email', emailController.text.trim());
      await prefs.setString('saved_password', passwordController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  // Menampilkan pesan pop-up singkat di bawah layar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // 1. Validasi input email dan password
    final emailErr = AuthValidators.emailError(email);
    if (emailErr != null) {
      _showMessage(emailErr);
      return;
    }

    final passwordErr = AuthValidators.passwordError(password);
    if (passwordErr != null) {
      _showMessage(passwordErr);
      return;
    }

    // 2. Login Khusu Admin
    if (email == 'admin@gmail.com' && password == 'admin123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', -1);
      await prefs.setString('user_name', 'Admin Foodie');
      await prefs.setString('user_email', 'admin@gmail.com');
      if (rememberMe) {
        await _savedCredential();
      }
      if (!mounted) return;
      AppNavigation.openAdmin(context);
      return;
    }

    // 3. Proses Login atau Register User
    if (isLogin) {
      // Proses Login SQLite (Menggunakan 'await' karena mengakses DB lokal)

      final result = await DatabaseHelper.instance.loginUser(email, password);
      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final user = result['user'] as Map<String, dynamic>;

        // Simpan data login user saat ini
        await prefs.setInt('user_id', user['id'] as int);
        await prefs.setString('user_name', user['name'] as String);
        await prefs.setString('user_email', user['email'] as String);

        if (rememberMe) {
          await _savedCredential();
        }
        if (!mounted) return;
        AppNavigation.onLoginSuccess(context);
      } else {
        _showMessage(result['message']);
      }
    } else {
      //Proses Register
      final name = nameController.text.trim();
      if (name.isEmpty) {
        _showMessage('Masukkan username');
        return;
      }

      final result = await DatabaseHelper.instance.registerUser(
        name,
        email,
        password,
      );

      if (result['success'] == true) {
        setState(() {
          isLogin = true;
          nameController.clear();
          passwordController.clear();
        });
        _showMessage('Register berhasil. Silahkan login.');
      } else {
        _showMessage(result['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isTablet(context) ? 460 : 412,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const ReusableImage(
                    imagePath: AppAssets.logo,
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    borderRadius: 0,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isLogin ? 'Login!' : 'Registrasi!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLogin
                        ? 'Tolong masukkan akun anda di sini'
                        : 'Daftarkan akun anda sekarang',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Tab Switcher Login / Registrasi
                  _AuthSwitcher(
                    isLogin: isLogin,
                    onLoginTap: () => setState(() => isLogin = true),
                    onRegisterTap: () => setState(() => isLogin = false),
                  ),
                  const SizedBox(height: 46),

                  // Form Input Username (Hanya muncul jika di tab Register/Registrasi)
                  if (!isLogin) ...[
                    AppTextField(
                      controller: nameController,
                      hintText: 'Masukkan Username',
                      prefixIcon: Icons.person_outline_rounded,
                      borderColor: AppColors.borderLight,
                      borderRadius: AppDimensions.authFieldRadius,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  // Form Input Email
                  AppTextField(
                    controller: emailController,
                    hintText: 'Masukkan Email',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    borderColor: AppColors.borderLight,
                    borderRadius: AppDimensions.authFieldRadius,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Form Input Password
                  AppTextField(
                    controller: passwordController,
                    hintText: 'Masukkan Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: isPasswordHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixTap: () {
                      setState(() => isPasswordHidden = !isPasswordHidden);
                    },
                    obscureText: isPasswordHidden,
                    borderColor: AppColors.borderLight,
                    borderRadius: AppDimensions.authFieldRadius,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Pilihan Remember Me (Login) / Sudah Punya Akun (Register)
                  if (isLogin)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => rememberMe = !rememberMe);
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: rememberMe
                                  ? AppColors.primary
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: AppColors.checkboxBorder,
                                width: 1.5,
                              ),
                            ),
                            child: rememberMe
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 17,
                                    color: AppColors.card,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ingat saya',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ],
                    )
                  else
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => setState(() => isLogin = true),
                        child: Text(
                          'Sudah punya akun?',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),

                  // Tombol Login / Registrasi Utama
                  ReusableButton(
                    label: isLogin ? 'Login' : 'Registrasi',
                    onPressed: _submit,
                    borderRadius: AppDimensions.authButtonRadius,
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthSwitcher extends StatelessWidget {
  const _AuthSwitcher({
    required this.isLogin,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  static const double _height = 42;
  static const double _inset = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tabWidth = constraints.maxWidth / 2;

        return SizedBox(
          height: _height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.authTrack,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Stack(
              children: [
                // Animasi background pill geser
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  left: isLogin ? _inset : tabWidth + _inset,
                  top: _inset,
                  bottom: _inset,
                  width: tabWidth - (_inset * 2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                // Teks Tab (Login & Registrasi)
                Row(
                  children: [
                    Expanded(
                      child: _AuthTabLabel(
                        label: 'Login',
                        isActive: isLogin,
                        onTap: onLoginTap,
                      ),
                    ),
                    Expanded(
                      child: _AuthTabLabel(
                        label: 'Registrasi',
                        isActive: !isLogin,
                        onTap: onRegisterTap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AuthTabLabel extends StatelessWidget {
  const _AuthTabLabel({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isActive ? AppColors.card : AppColors.dark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
