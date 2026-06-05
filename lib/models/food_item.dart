/// Model data menu makanan — digunakan sebagai struktur data untuk tabel `tb_menu`.
///
/// [dbId] = ID dari database SQLite (nullable karena auto-increment).
/// [id]   = ID string untuk keperluan UI (hero tag, routing).
class FoodItem {
  const FoodItem({
    this.dbId,
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.rating,
    required this.deliveryTime,
    required this.distance,
    required this.calories,
    required this.tags,
  });

  /// ID dari SQLite (auto-increment). Null saat belum disimpan ke DB.
  final int? dbId;
  final String id;
  final String name;
  final String category;
  final String address;
  final String description;
  final String imagePath;
  final double price;
  final double rating;
  final String deliveryTime;
  final String distance;
  final int calories;
  final List<String> tags;

  /// Konversi object FoodItem → Map untuk operasi INSERT/UPDATE SQLite.
  ///
  /// Catatan: [id] (String) tidak disimpan ke DB karena kita pakai
  /// auto-increment [dbId] sebagai primary key.
  /// [tags] disimpan sebagai String dipisah koma ('Favorite,Gurih,Fresh').
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'description': description,
      'image_path': imagePath,
      'price': price,
      'rating': rating,
      'delivery_time': deliveryTime,
      'distance': distance,
      'calories': calories,
      'tags': tags.join(','),
    };
  }

  /// Factory: konversi Map dari SQLite → FoodItem object.
  ///
  /// [map['id']] = integer dari kolom `id` SQLite.
  /// [map['tags']] = string koma-separated, dipecah jadi List<String>.
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      dbId: map['id'] as int,
      id: 'menu-${map['id']}',
      name: map['name'] as String,
      category: map['category'] as String,
      address: map['address'] as String,
      description: map['description'] as String,
      imagePath: map['image_path'] as String,
      price: (map['price'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble(),
      deliveryTime: map['delivery_time'] as String,
      distance: map['distance'] as String,
      calories: map['calories'] as int,
      tags: (map['tags'] as String).split(','),
    );
  }

  /// Buat salinan FoodItem dengan field tertentu diubah.
  FoodItem copyWith({
    int? dbId,
    String? id,
    String? name,
    String? category,
    String? address,
    String? description,
    String? imagePath,
    double? price,
    double? rating,
    String? deliveryTime,
    String? distance,
    int? calories,
    List<String>? tags,
  }) {
    return FoodItem(
      dbId: dbId ?? this.dbId,
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      tags: tags ?? this.tags,
    );
  }
}
