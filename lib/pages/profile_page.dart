import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../services/app_navigation.dart';
import '../constants/app_dimensions.dart';
import '../widgets/figma_page_body.dart';
import '../widgets/reusable_button.dart';
import '../widgets/reusable_image.dart';
import '../widgets/section_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 38),
                padding: const EdgeInsets.fromLTRB(0, 62, 0, 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 18,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Fattah',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'msyauqi559@gmail.com',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.grayText,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(left: 22),
                      child: SectionHeader(title: 'Personal Details'),
                    ),
                    const SizedBox(height: 4),
                    const _DetailRow(
                      label: 'Nama lengkap :',
                      value: 'M. Fattah Syauqi',
                    ),
                    const _DetailRow(
                      label: 'Username',
                      value: 'Fattah',
                    ),
                    const _DetailRow(
                      label: 'Jenis Kelamin :',
                      value: 'Laki - laki',
                    ),
                    const _DetailRow(
                      label: 'Negara :',
                      value: 'Indonesia',
                    ),
                    const _DetailRow(
                      label: 'Nomor Telp. :',
                      value: '085-856-238-817',
                    ),
                    const _DetailRow(
                      label: 'Email :',
                      value: 'msyauqi559@gmail.com',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              Container(
                width: 106,
                height: 106,
                padding: const EdgeInsets.all(9),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const ReusableImage(
                  imagePath: AppAssets.user,
                  fit: BoxFit.cover,
                  borderRadius: 48,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ReusableButton(
            label: 'Logout',
            onPressed: () => _showLogoutDialog(context),
            icon: Icons.logout_rounded,
            borderRadius: AppDimensions.authButtonRadius,
            height: 50,
          ),
        ],
      ),
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
              Text(
                'Apakah anda yakin ingin keluar dari aplikasi?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 42),
              SizedBox(
                width: 250,
                child: ReusableButton(
                  label: 'Ya, Keluar',
                  onPressed: () {
                    Navigator.pop(context);
                    AppNavigation.onLogout(parentContext);
                  },
                  borderRadius: 4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 250,
                child: ReusableButton(
                  label: 'Batal',
                  onPressed: () => Navigator.pop(context),
                  borderRadius: 4,
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
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(color: AppColors.borderMedium),
          bottom: isLast
              ? const BorderSide(color: AppColors.borderMedium)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.grayText,
                    fontSize: 14,
                  ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
