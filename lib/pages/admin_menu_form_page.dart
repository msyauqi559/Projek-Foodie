import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../models/food_item.dart';
import '../services/database_helper.dart';
import '../widgets/reusable_image.dart';

class AdminMenuFormPage extends StatefulWidget {
  final FoodItem? foodToEdit;

  const AdminMenuFormPage({super.key, this.foodToEdit});

  @override
  State<AdminMenuFormPage> createState() => _AdminMenuFormPageState();
}

class _AdminMenuFormPageState extends State<AdminMenuFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _catCtrl;
  late TextEditingController _addrCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _tagsCtrl;
  late TextEditingController _imageCtrl;
  
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  final List<String> _availableTags = [
    'Pedas',
    'Manis',
    'Gurih',
    'Asin',
    'Hangat',
    'Dingin',
    'Sehat',
    'Populer',
    'Favorit',
    'Crispy',
    'Daging',
    'Mie',
    'Rempah',
  ];
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    final f = widget.foodToEdit;
    _nameCtrl = TextEditingController(text: f?.name ?? '');
    _catCtrl = TextEditingController(text: f?.category ?? 'Nusantara');
    _addrCtrl = TextEditingController(text: f?.address ?? 'Jl. Diponegoro Kota Pasuruan');
    _descCtrl = TextEditingController(text: f?.description ?? '');
    _priceCtrl = TextEditingController(text: f?.price.toStringAsFixed(0) ?? '');
    
    _selectedTags = f?.tags.map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? ['Favorit', 'Gurih'];
    for (final tag in _selectedTags) {
      if (!_availableTags.contains(tag)) {
        _availableTags.add(tag);
      }
    }
    _tagsCtrl = TextEditingController(text: _selectedTags.join(', '));
    _imageCtrl = TextEditingController(text: f?.imagePath ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _catCtrl.dispose();
    _addrCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _tagsCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Menjaga ukuran gambar agar database tetap ringan
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Str = base64Encode(bytes);
        setState(() {
          _imageCtrl.text = 'data:image/png;base64,$base64Str';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  // Fungsi untuk menampilkan pop-up multi-select dialog pemilihan tags makanan
  Future<void> _showTagsDialog() async {
    // Membuat list temporer agar pilihan di dialog tidak langsung merubah state utama sebelum diklik 'Pilih'
    final List<String> tempSelected = List.from(_selectedTags);
    await showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder digunakan agar state di dalam dialog (seperti checklist) dapat di-update secara responsif
        // tanpa memicu rebuild seluruh halaman AdminMenuFormPage di belakangnya
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pilih Tags Makanan', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true, // Membuat list menyesuaikan tinggi konten di dalamnya
                  children: _availableTags.map((tag) {
                    final isChecked = tempSelected.contains(tag);
                    return CheckboxListTile(
                      activeColor: AppColors.primary,
                      value: isChecked,
                      title: Text(tag),
                      controlAffinity: ListTileControlAffinity.leading, // Checklist di sebelah kiri teks
                      onChanged: (bool? checked) {
                        // Memperbarui checklist secara lokal di dalam dialog menggunakan setDialogState
                        setDialogState(() {
                          if (checked == true) {
                            if (!tempSelected.contains(tag)) {
                              tempSelected.add(tag);
                            }
                          } else {
                            tempSelected.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                // Tombol Batal untuk membatalkan semua pilihan temporer
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                // Tombol Pilih untuk menyimpan pilihan temporer ke state utama dan menutup dialog
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedTags = List.from(tempSelected);
                      // Menggabungkan tag terpilih menjadi teks koma (contoh: "Pedas, Nusantara") untuk ditampilkan di form
                      _tagsCtrl.text = _selectedTags.join(', ');
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Pilih'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar makanan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final food = FoodItem(
      dbId: widget.foodToEdit?.dbId,
      id: widget.foodToEdit?.id ?? 'menu-baru',
      name: _nameCtrl.text,
      category: _catCtrl.text,
      address: _addrCtrl.text,
      description: _descCtrl.text,
      imagePath: _imageCtrl.text.trim(),
      price: double.parse(_priceCtrl.text),
      rating: widget.foodToEdit?.rating ?? 5.0,
      deliveryTime: widget.foodToEdit?.deliveryTime ?? '15 min',
      distance: widget.foodToEdit?.distance ?? '1.2 km',
      calories: widget.foodToEdit?.calories ?? 250,
      tags: _selectedTags,
    );

    if (widget.foodToEdit == null) {
      await DatabaseHelper.instance.insertMenu(food);
    } else {
      await DatabaseHelper.instance.updateMenu(food);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.foodToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Menu' : 'Tambah Menu Baru',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Detail Makanan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nama
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Menu',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Kategori
                  DropdownButtonFormField<String>(
                    initialValue: ['Nusantara', 'Sehat', 'Fastfood'].contains(_catCtrl.text) ? _catCtrl.text : 'Nusantara',
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: ['Nusantara', 'Sehat', 'Fastfood'].map((String category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _catCtrl.text = val;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Harga
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Harga (Rupiah)',
                      prefixText: 'Rp. ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Harga wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: _addrCtrl,
                    decoration: InputDecoration(
                      labelText: 'Alamat Resto/Penjual',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags Multi-Select Dropdown
                  GestureDetector(
                    onTap: _showTagsDialog,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _tagsCtrl,
                        decoration: InputDecoration(
                          labelText: 'Tags Makanan (Bisa Pilih Lebih dari Satu)',
                          suffixIcon: const Icon(Icons.arrow_drop_down_rounded, size: 28),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => _selectedTags.isEmpty ? 'Pilih minimal satu tag' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Lengkap',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bagian Gambar Custom
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Gambar Makanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  
                  // Live image preview
                  Center(
                    child: Container(
                      width: 180,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _imageCtrl,
                        builder: (context, value, child) {
                          final path = value.text.trim();
                          if (path.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_rounded, size: 40, color: Colors.grey),
                                  SizedBox(height: 4),
                                  Text(
                                    'Belum ada gambar',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ReusableImage(
                            imagePath: path,
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: 12,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tombol Pilih Gambar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                      label: const Text(
                        'Pilih Gambar dari Galeri',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Tombol Simpan
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambahkan Menu',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
