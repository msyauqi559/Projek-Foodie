import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../models/food_item.dart';
import '../services/database_helper.dart';

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
  
  String _selectedImage = AppAssets.salad; // Default fallback
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final f = widget.foodToEdit;
    _nameCtrl = TextEditingController(text: f?.name ?? '');
    _catCtrl = TextEditingController(text: f?.category ?? 'Nusantara');
    _addrCtrl = TextEditingController(text: f?.address ?? 'Jl. Diponegoro Kota Pasuruan');
    _descCtrl = TextEditingController(text: f?.description ?? '');
    _priceCtrl = TextEditingController(text: f?.price.toStringAsFixed(0) ?? '');
    _tagsCtrl = TextEditingController(text: f?.tags.join(',') ?? 'Favorite,Gurih');
    if (f != null) {
      _selectedImage = f.imagePath;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _catCtrl.dispose();
    _addrCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final food = FoodItem(
      dbId: widget.foodToEdit?.dbId,
      id: widget.foodToEdit?.id ?? 'menu-baru',
      name: _nameCtrl.text,
      category: _catCtrl.text,
      address: _addrCtrl.text,
      description: _descCtrl.text,
      imagePath: _selectedImage,
      price: double.parse(_priceCtrl.text),
      rating: widget.foodToEdit?.rating ?? 5.0, // Default rating untuk menu baru
      deliveryTime: widget.foodToEdit?.deliveryTime ?? '15 min',
      distance: widget.foodToEdit?.distance ?? '1.2 km',
      calories: widget.foodToEdit?.calories ?? 250,
      tags: _tagsCtrl.text.split(',').map((e) => e.trim()).toList(),
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
        title: Text(isEdit ? 'Edit Menu' : 'Tambah Menu Baru', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                  const Text('Detail Makanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  
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
                    value: ['Nusantara', 'Sehat', 'Fastfood'].contains(_catCtrl.text) ? _catCtrl.text : 'Nusantara',
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

                  // Tags
                  TextFormField(
                    controller: _tagsCtrl,
                    decoration: InputDecoration(
                      labelText: 'Tags (Pisahkan dengan Koma)',
                      hintText: 'Cth: Pedas,Best Seller',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Lengkap',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 32),

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
                ],
              ),
            ),
    );
  }
}
