import 'food_item.dart';

/// Model data pesanan — digunakan sebagai struktur data untuk tabel `tb_pesanan`.
///
/// [menuId] = Foreign Key yang merujuk ke `tb_menu.id`.
/// [food]   = Object FoodItem yang di-resolve dari JOIN query.
class OrderHistoryItem {
  const OrderHistoryItem({
    this.dbId,
    this.menuId,
    this.userId,
    this.userName,
    this.userPhotoPath,
    this.userAddress,
    this.userPhone,
    required this.id,
    required this.food,
    required this.quantity,
    required this.dateLabel,
    required this.statusLabel,
    required this.isSuccess,
    required this.total,
    required this.promoDiscount,
    required this.shippingCost,
    required this.tax,
    required this.promoCode,
  });

  /// ID dari SQLite (auto-increment). Null saat belum disimpan.
  final int? dbId;

  /// Foreign Key → tb_menu.id. Digunakan saat INSERT ke database.
  final int? menuId;

  /// Foreign Key → tb_user.id. Menyimpan user yang melakukan pesanan.
  final int? userId;

  /// Nama User. Di-resolve dari query JOIN.
  final String? userName;

  /// Path Foto User. Di-resolve dari query JOIN.
  final String? userPhotoPath;

  /// Alamat User. Di-resolve dari query JOIN.
  final String? userAddress;

  /// Nomor Telepon User. Di-resolve dari query JOIN.
  final String? userPhone;

  final String id;
  final FoodItem food;
  final int quantity;
  final String dateLabel;
  final String statusLabel;
  final bool isSuccess;
  final double total;
  final double promoDiscount;
  final double shippingCost;
  final double tax;
  final String promoCode;

  /// Konversi object → Map untuk INSERT ke database.
  ///
  /// [menu_id] mengambil dari [food.dbId] (ID menu di database).
  /// [is_success] disimpan sebagai INTEGER (1/0) karena SQLite tidak punya BOOLEAN.
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'menu_id': menuId ?? food.dbId,
      'quantity': quantity,
      'date_label': dateLabel,
      'status_label': statusLabel,
      'is_success': isSuccess ? 1 : 0,
      'total': total,
      'promo_discount': promoDiscount,
      'shipping_cost': shippingCost,
      'tax': tax,
      'promo_code': promoCode,
    };
  }

  /// Factory: konversi Map hasil JOIN query → OrderHistoryItem.
  ///
  /// [map] berisi kolom dari tb_pesanan + tb_menu (dengan prefix).
  /// Kolom tb_menu di-alias: m_id, m_name, m_category, dst.
  factory OrderHistoryItem.fromMap(Map<String, dynamic> map) {
    // Bangun FoodItem dari kolom JOIN (prefix 'm_' untuk menu)
    final food = FoodItem(
      dbId: map['menu_id'] as int,
      id: 'menu-${map['menu_id']}',
      name: map['m_name'] as String,
      category: map['m_category'] as String,
      address: map['m_address'] as String,
      description: map['m_description'] as String,
      imagePath: map['m_image_path'] as String,
      price: (map['m_price'] as num).toDouble(),
      rating: (map['m_rating'] as num).toDouble(),
      tags: (map['m_tags'] as String).split(','),
    );

    return OrderHistoryItem(
      dbId: map['id'] as int,
      menuId: map['menu_id'] as int,
      userId: map['user_id'] as int?,
      userName: map['u_name'] as String?,
      userPhotoPath: map['u_photo_path'] as String?,
      userAddress: map['u_address'] as String?,
      userPhone: map['u_phone'] as String?,
      id: 'history-${map['id']}',
      food: food,
      quantity: map['quantity'] as int,
      dateLabel: map['date_label'] as String,
      statusLabel: map['status_label'] as String,
      isSuccess: (map['is_success'] as int) == 1,
      total: (map['total'] as num).toDouble(),
      promoDiscount: (map['promo_discount'] as num).toDouble(),
      shippingCost: (map['shipping_cost'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      promoCode: map['promo_code'] as String,
    );
  }
}
