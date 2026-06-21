import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../services/app_navigation.dart';
import '../constants/app_dimensions.dart';
import '../widgets/figma_page_body.dart';
import '../widgets/reusable_button.dart';
import '../widgets/reusable_image.dart';
import '../widgets/section_header.dart';
import '../widgets/app_text_field.dart';
import '../services/database_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? loggedInUserId;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  int orderCount = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _pickProfilePhoto(StateSetter setModalState, Function(String) onPhotoPicked) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Str = base64Encode(bytes);
        onPhotoPicked('data:image/png;base64,$base64Str');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e')),
        );
      }
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    // Default ke ID 2 jika session kosong (kredensial M. Fattah Syauqi di seeder)
    final userId = prefs.getInt('user_id') ?? 2;
    final profile = await DatabaseHelper.instance.getUserProfile(userId);
    final pesananList = await DatabaseHelper.instance.getPesananByUserId(userId);
    setState(() {
      loggedInUserId = userId;
      userProfile = profile;
      orderCount = pesananList.length;
      isLoading = false;
    });
  }

  bool get isProfileFilled {
    if (userProfile == null) return false;
    final phone = userProfile!['phone'] as String?;
    final address = userProfile!['address'] as String?;
    return phone != null && phone.isNotEmpty && address != null && address.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const FigmaPageBody(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return FigmaPageBody(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Text(
                'Profil Saya',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 22),
            
            _buildFilledProfile(context),

            const SizedBox(height: 32),
            
            // Tombol Logout
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
          ],
        ),
      ),
    );
  }
  /// Tampilan ketika data profil sudah terisi
  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.grayText),
        ),
      ],
    );
  }

  /// Tampilan ketika data profil sudah terisi
  Widget _buildFilledProfile(BuildContext context) {
    final name = userProfile?['name'] ?? 'Pengguna Foodie';
    final email = userProfile?['email'] ?? '';
    final rawPhone = userProfile?['phone'] as String?;
    final rawGender = userProfile?['gender'] as String?;
    final rawAddress = userProfile?['address'] as String?;
    final photo = userProfile?['photo_path'] as String?;

    final phone = (rawPhone != null && rawPhone.trim().isNotEmpty) ? rawPhone : 'Belum diisi';
    final gender = (rawGender != null && rawGender.trim().isNotEmpty) ? rawGender : 'Belum diisi';
    final address = (rawAddress != null && rawAddress.trim().isNotEmpty) ? rawAddress : 'Belum diisi';
    final hasMissingInfo = phone == 'Belum diisi' || address == 'Belum diisi';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 55),
          padding: const EdgeInsets.fromLTRB(0, 75, 0, 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              if (hasMissingInfo)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Lengkapi nomor telepon & alamat Anda agar pengiriman pesanan lebih lancar.',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: _showEditProfileSheet,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.orange.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Isi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                name,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'Member Foodie Premium',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Statistics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(context, Icons.receipt_long_rounded, 'Pesanan', '$orderCount Kali'),
                  Container(height: 28, width: 1, color: Colors.grey.shade200),
                  _buildStatItem(context, Icons.workspace_premium_rounded, 'Loyalitas', 'Premium'),
                  Container(height: 28, width: 1, color: Colors.grey.shade200),
                  _buildStatItem(context, Icons.calendar_month_rounded, 'Gabung', '2026'),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.borderLight, height: 1),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionHeader(title: 'Detail Personal'),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                      onPressed: _showEditProfileSheet,
                    ),
                  ],
                ),
              ),
              _DetailRow(
                icon: Icons.alternate_email_rounded,
                label: 'Email',
                value: email,
              ),
              _DetailRow(
                icon: Icons.phone_android_rounded,
                label: 'Nomor Telp',
                value: phone,
              ),
              _DetailRow(
                icon: Icons.male_rounded,
                label: 'Gender',
                value: gender,
              ),
              _DetailRow(
                icon: Icons.location_on_rounded,
                label: 'Alamat Pengiriman',
                value: address,
                isLast: true,
              ),
            ],
          ),
        ),
        
        // Premium Avatar Ring decoration
        Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFFFF9800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: (photo == null || photo.isEmpty)
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 55,
                      color: AppColors.primary,
                    ),
                  )
                : ReusableImage(
                    imagePath: photo,
                    fit: BoxFit.cover,
                    borderRadius: 55,
                  ),
          ),
        ),
      ],
    );
  }

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: userProfile?['name'] ?? '');
    final phoneController = TextEditingController(text: userProfile?['phone'] ?? '');
    final addressController = TextEditingController(text: userProfile?['address'] ?? '');
    String selectedGender = userProfile?['gender'] ?? 'Laki - laki';
    String selectedPhoto = userProfile?['photo_path'] ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20, 
                20, 
                20, 
                MediaQuery.of(context).viewInsets.bottom + 20
              ),
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lengkapi / Edit Profil',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Foto Profil
                    const Text(
                      'Foto Profil',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                            ),
                            child: selectedPhoto.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : ReusableImage(
                                    imagePath: selectedPhoto,
                                    fit: BoxFit.cover,
                                    borderRadius: 45,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  _pickProfilePhoto(setModalState, (newPhoto) {
                                    setModalState(() {
                                      selectedPhoto = newPhoto;
                                    });
                                  });
                                },
                                icon: const Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 18),
                                label: const Text(
                                  'Pilih dari Galeri',
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (selectedPhoto.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    setModalState(() {
                                      selectedPhoto = '';
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                                  label: const Text(
                                    'Hapus Foto',
                                    style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Name Field
                    const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: nameController,
                      hintText: 'Nama Anda',
                      borderColor: AppColors.primary,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    const Text('Nomor Telepon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: phoneController,
                      hintText: 'Contoh: 085856238817',
                      keyboardType: TextInputType.phone,
                      borderColor: AppColors.primary,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 16),

                    // Gender Selection
                    const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => selectedGender = 'Laki - laki'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedGender == 'Laki - laki'
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedGender == 'Laki - laki'
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.male_rounded,
                                    color: selectedGender == 'Laki - laki' ? AppColors.primary : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Laki-laki',
                                    style: TextStyle(
                                      color: selectedGender == 'Laki - laki' ? AppColors.primary : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => selectedGender = 'Perempuan'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedGender == 'Perempuan'
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedGender == 'Perempuan'
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.female_rounded,
                                    color: selectedGender == 'Perempuan' ? AppColors.primary : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Perempuan',
                                    style: TextStyle(
                                      color: selectedGender == 'Perempuan' ? AppColors.primary : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address Field
                    const Text('Alamat Lengkap Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: addressController,
                      hintText: 'Alamat pengiriman makanan Anda...',
                      borderColor: AppColors.primary,
                      maxLines: 2,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ReusableButton(
                        label: 'Simpan Perubahan',
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty ||
                              phoneController.text.trim().isEmpty ||
                              addressController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Semua field wajib diisi!'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                            return;
                          }
                          await DatabaseHelper.instance.updateUserProfile(
                            userId: loggedInUserId!,
                            name: nameController.text,
                            phone: phoneController.text,
                            gender: selectedGender,
                            address: addressController.text,
                            photoPath: selectedPhoto,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          _loadProfile();
                        },
                        borderRadius: 12,
                        height: 50,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: AppColors.primary, size: 30),
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
                  backgroundColor: AppColors.primary,
                  borderColor: AppColors.primary,
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
    final isPlaceholder = value == 'Belum diisi';

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
          Icon(icon, size: 20, color: isPlaceholder ? Colors.orange.shade700 : AppColors.primary),
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
                        color: isPlaceholder ? Colors.orange.shade700 : AppColors.textPrimary,
                        fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
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
