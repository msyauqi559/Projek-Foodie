// Model data menu makanan untuk tabel tb_menu.
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
    required this.tags,
  });

  // ID auto-increment SQLite.
  final int? dbId;
  final String id;
  final String name;
  final String category;
  final String address;
  final String description;
  final String imagePath;
  final double price;
  final double rating;
  final List<String> tags;

  // Konversi objek ke Map untuk SQLite.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'description': description,
      'image_path': imagePath,
      'price': price,
      'rating': rating,
      'tags': tags.join(','),
    };
  }
  // Konversi Map SQLite ke objek FoodItem.
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
      tags: (map['tags'] as String).split(','),
    );
  }

  // Salin objek dengan beberapa perubahan field.
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
      tags: tags ?? this.tags,
    );
  }
}
