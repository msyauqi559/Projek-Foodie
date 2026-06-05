import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_spacing.dart';
import '../services/app_navigation.dart';
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
  bool isLogin = true;
  bool isPasswordHidden = true;
  bool rememberMe = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  void _submit() {
    final email = emailController.text;
    final password = passwordController.text;

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

    if (!isLogin && nameController.text.trim().isEmpty) {
      _showMessage('Masukkan username');
      return;
    }

    if (email == 'admin@gmail.com' && password == 'admin123') {
      AppNavigation.openAdmin(context);
      return;
    }

    if (isLogin) {
      AppNavigation.onLoginSuccess(context);
      return;
    }

    setState(() {
      isLogin = true;
      nameController.clear();
      passwordController.clear();
    });
    _showMessage('Registrasi berhasil. Silakan login.');
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
                  const SizedBox(height: 20),
                  const ReusableImage(
                    imagePath: AppAssets.logo,
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    borderRadius: 0,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    isLogin ? 'Login!' : 'Registrasi!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
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
                        ),
                  ),
                  const SizedBox(height: 40),
                  _AuthSwitcher(
                    isLogin: isLogin,
                    onLoginTap: () => setState(() => isLogin = true),
                    onRegisterTap: () => setState(() => isLogin = false),
                  ),
                  const SizedBox(height: 46),
                  if (!isLogin) ...[
                    AppTextField(
                      controller: nameController,
                      hintText: 'Masukkan Username',
                      prefixIcon: Icons.person_outline_rounded,
                      borderColor: AppColors.divider,
                      borderRadius: AppDimensions.authFieldRadius,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppTextField(
                    controller: emailController,
                    hintText: 'Masukkan Email',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    borderColor: AppColors.divider,
                    borderRadius: AppDimensions.authFieldRadius,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                    borderColor: AppColors.divider,
                    borderRadius: AppDimensions.authFieldRadius,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                  const SizedBox(height: 26),
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
                              color: rememberMe ? AppColors.primary : AppColors.card,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: AppColors.checkboxBorder),
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
                              ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
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
              border: Border.all(color: AppColors.divider),
            ),
            child: Stack(
              children: [
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
