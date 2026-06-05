import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../services/app_navigation.dart';
import '../constants/app_dimensions.dart';
import '../widgets/figma_page_body.dart';
import '../widgets/reusable_button.dart';
import '../widgets/reusable_image.dart';
import '../widgets/section_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Simulasi state user: false (kosong), true (terisi)
  // Anda bisa mengganti ini nanti saat menghubungkan dengan Auth betulan
  bool isProfileFilled = false;

  @override
  Widget build(BuildContext context) {
    return FigmaPageBody(
      child: Column(
        children: [
          Center(
            child: Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 22),
          
          if (!isProfileFilled)
            _buildEmptyProfile(context)
          else
            _buildFilledProfile(context),

          const SizedBox(height: 32),
          
          // Tombol Logout yang didesain ulang agar lebih elegan
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: const Text('Logout', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.authButtonRadius),
                  side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tombol simulasi (Hanya untuk keperluan demonstrasi ke mentor)
          TextButton.icon(
            onPressed: () {
              setState(() {
                isProfileFilled = !isProfileFilled;
              });
            },
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.grayText),
            label: Text(
              isProfileFilled ? 'Simulasikan Mode Kosong' : 'Simulasikan Mode Terisi',
              style: const TextStyle(color: AppColors.grayText),
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilan ketika data profil masih kosong
  Widget _buildEmptyProfile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_add_alt_1_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Profil Belum Diisi',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Silakan lengkapi data diri Anda untuk mempermudah proses pemesanan dan pengiriman makanan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.grayText,
                  fontSize: 14,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 28),
          ReusableButton(
            label: 'Lengkapi Profil Sekarang',
            onPressed: () {
              // Simulasi: Mengisi data
              setState(() {
                isProfileFilled = true;
              });
            },
            borderRadius: 12,
            height: 50,
          ),
        ],
      ),
    );
  }

  /// Tampilan ketika data profil sudah terisi
  Widget _buildFilledProfile(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 45),
          padding: const EdgeInsets.fromLTRB(0, 65, 0, 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'M. Fattah Syauqi',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Member Foodie',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.only(left: 22, right: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SectionHeader(title: 'Detail Personal'),
                    Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const _DetailRow(
                icon: Icons.alternate_email_rounded,
                label: 'Email',
                value: 'msyauqi559@gmail.com',
              ),
              const _DetailRow(
                icon: Icons.phone_android_rounded,
                label: 'Nomor Telp',
                value: '085-856-238-817',
              ),
              const _DetailRow(
                icon: Icons.male_rounded,
                label: 'Gender',
                value: 'Laki - laki',
              ),
              const _DetailRow(
                icon: Icons.location_on_rounded,
                label: 'Alamat Pengiriman',
                value: 'Jl. Imam Bonjol No. 19, Pasuruan, Jawa Timur',
                isLast: true,
              ),
            ],
          ),
        ),
        Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const ReusableImage(
            imagePath: AppAssets.user,
            fit: BoxFit.cover,
            borderRadius: 60,
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext parentContext) {
    return showModalBottomSheet<void>(
      context: parentContext,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 38),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 30),
              ),
              const SizedBox(height: 20),
              Text(
                'Keluar dari Foodie?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda harus login kembali untuk melakukan pesanan.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grayText,
                    ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ReusableButton(
                  label: 'Ya, Keluar',
                  onPressed: () {
                    Navigator.pop(context);
                    AppNavigation.onLogout(parentContext);
                  },
                  backgroundColor: AppColors.danger,
                  borderRadius: 12,
                  height: 50,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ReusableButton(
                  label: 'Batal',
                  onPressed: () => Navigator.pop(context),
                  borderRadius: 12,
                  height: 50,
                  isPrimary: false,
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.textPrimary,
                  borderColor: AppColors.borderMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.borderMedium),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grayText,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
