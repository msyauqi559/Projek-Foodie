import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/food_item.dart';
import '../models/order_history_item.dart';

/// ============================================================================
/// DATABASE HELPER (SQLITE) — VERSI 6 (DENGAN DUKUNGAN PLATFORM FALLBACK & CART)
/// ============================================================================
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Helper untuk mendeteksi apakah platform saat ini membutuhkan fallback memori.
  // Digunakan untuk Web/Chrome dan platform Desktop (Linux/macOS/Windows) agar tidak crash.
  bool get _useMemoryFallback {
    if (kIsWeb) return true;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  // ── PLATFORM FALLBACK DATA MEMORY ──
  static final List<Map<String, dynamic>> _webUsers = [
    {
      'id': 1,
      'name': 'Admin Foodie',
      'email': 'admin@gmail.com',
      'password': 'admin123',
      'phone': '081234567890',
      'gender': 'Laki - laki',
      'address': 'Kantor Pusat Foodie',
      'photo_path': '',
    },
    {
      'id': 2,
      'name': 'M. Fattah Syauqi',
      'email': 'msyauqi559@gmail.com',
      'password': 'user123',
      'phone': '085856238817',
      'gender': 'Laki - laki',
      'address': 'Jl. Imam Bonjol No. 19, Pasuruan, Jawa Timur',
      'photo_path': '',
    }
  ];
  static final List<Map<String, dynamic>> _initialMenus = [
    {
      'id': 1,
      'name': 'Lontong Balap Kraton',
      'category': 'Nusantara',
      'address': 'Jl. Kranggan No.60, Surabaya',
      'description': 'Makanan khas Surabaya yang terdiri dari lontong, tauge, lentho, tahu goreng, bawang goreng, kecap, dan sambal petis lezat.',
      'image_path': 'assets/images/lontong_balap.jpg',
      'price': 15000.0,
      'rating': 4.8,
      'delivery_time': '15-20 min',
      'distance': '2.5 km',
      'calories': 350,
      'tags': 'Gurih,Khas Surabaya,Populer',
    },
    {
      'id': 2,
      'name': 'Mie Ayam Pangsit Special',
      'category': 'Nusantara',
      'address': 'Jl. Gajah Mada No.12, Jakarta',
      'description': 'Mie ayam lezat dengan potongan ayam kecap melimpah, disajikan dengan sawi segar, pangsit basah, dan kuah kaldu hangat yang gurih.',
      'image_path': 'assets/images/mie_ayam.jpg',
      'price': 18000.0,
      'rating': 4.7,
      'delivery_time': '10-15 min',
      'distance': '1.2 km',
      'calories': 420,
      'tags': 'Gurih,Mie,Favorit',
    },
    {
      'id': 3,
      'name': 'Rendang Daging Sapi Minang',
      'category': 'Nusantara',
      'address': 'RM Sederhana, Jl. Jend. Sudirman',
      'description': 'Daging sapi pilihan yang dimasak perlahan dengan santan dan bumbu rempah khas Minang selama berjam-jam hingga meresap sempurna.',
      'image_path': 'assets/images/rendang.jpg',
      'price': 25000.0,
      'rating': 4.9,
      'delivery_time': '20-30 min',
      'distance': '3.1 km',
      'calories': 480,
      'tags': 'Rempah,Pedas,Juara',
    },
    {
      'id': 4,
      'name': 'Rawon Daging Sapi Surabaya',
      'category': 'Nusantara',
      'address': 'Rawon Setan, Jl. Embong Malang',
      'description': 'Sup daging sapi kuah hitam khas Jawa Timur menggunakan kluwek berkualitas tinggi, disajikan dengan tauge pendek, telur asin, dan sambal.',
      'image_path': 'assets/images/rawon.jpg',
      'price': 22000.0,
      'rating': 4.6,
      'delivery_time': '15-25 min',
      'distance': '2.8 km',
      'calories': 410,
      'tags': 'Kuah,Hangat,Kluwek',
    },
    {
      'id': 5,
      'name': 'Bakso Sapi Urat Solo',
      'category': 'Nusantara',
      'address': 'Bakso Solo Baru, Pasuruan',
      'description': 'Bakso urat sapi asli dengan kuah kaldu bening gurih yang segar, ditambah mie kuning, bihun, tahu bakso, dan taburan seledri bawang goreng.',
      'image_path': 'assets/images/bakso.jpg',
      'price': 16000.0,
      'rating': 4.8,
      'delivery_time': '10-20 min',
      'distance': '1.5 km',
      'calories': 380,
      'tags': 'Bakso,Kuah,Hangat',
    },
    {
      'id': 6,
      'name': 'Salad Sayur Saus Wijen Sangrai',
      'category': 'Sehat',
      'address': 'Healthy Corner, Gading Serpong',
      'description': 'Kombinasi selada romaine segar, tomat ceri, mentimun, wortel iris, jagung manis, dan dada ayam panggang dengan dressing wijen sangrai yang wangi.',
      'image_path': 'assets/images/salad.png',
      'price': 28000.0,
      'rating': 4.9,
      'delivery_time': '10-15 min',
      'distance': '0.8 km',
      'calories': 240,
      'tags': 'Fresh,Rendah Kalori,Dada Ayam',
    },
    {
      'id': 7,
      'name': 'Fruit Box Segar Campur',
      'category': 'Sehat',
      'address': 'Fresh Market, Kav 10',
      'description': 'Potongan buah-buahan segar pilihan seperti melon, semangka, mangga, nanas, dan anggur, disajikan dingin dalam kotak higienis.',
      'image_path': 'assets/images/buah_kemasan.jpg',
      'price': 12000.0,
      'rating': 4.5,
      'delivery_time': '5-10 min',
      'distance': '0.5 km',
      'calories': 120,
      'tags': 'Dingin,Manis,Vitamin',
    },
    {
      'id': 8,
      'name': 'Kebab Daging Sapi Jumbo',
      'category': 'Fastfood',
      'address': 'Kebab Baba Rafi, Jl. Soekarno Hatta',
      'description': 'Kulit tortilla panggang renyah berisi irisan daging sapi kebab berbumbu gurih, selada segar, bawang bombay, saus tomat, sambal, dan mayones.',
      'image_path': 'assets/images/kebab.jpg',
      'price': 20000.0,
      'rating': 4.7,
      'delivery_time': '10-15 min',
      'distance': '1.8 km',
      'calories': 450,
      'tags': 'Daging,Keju,Jumbo',
    }
  ];
  static final List<Map<String, dynamic>> _webMenus = List.from(_initialMenus);
  static final List<Map<String, dynamic>> _webOrders = [];
  static final List<Map<String, dynamic>> _webCart = [];
  static int _webUserIdCounter = 3;
  static int _webMenuIdCounter = 9;
  static int _webOrderIdCounter = 1;
  static int _webCartIdCounter = 1;

  Future<Database> get database async {
    if (_useMemoryFallback) {
      throw UnsupportedError('SQLite tidak didukung di platform ini. Gunakan fallback memory.');
    }
    if (_database != null) return _database!;
    _database = await _initDB('foodie.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 7, // Naik ke versi 7 untuk mendukung seeder menu awal
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Fungsi Pembaruan Skema Database (`onUpgrade`).
  /// Menghapus dan membuat ulang seluruh tabel untuk menjaga konsistensi skema.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 7) {
      await db.execute('DROP TABLE IF EXISTS tb_cart');
      await db.execute('DROP TABLE IF EXISTS tb_user');
      await db.execute('DROP TABLE IF EXISTS tb_pesanan');
      await db.execute('DROP TABLE IF EXISTS tb_menu');
      await _createDB(db, newVersion);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // ── TABEL USER (Auth + Profil Dinamis) ──
    await db.execute('''
      CREATE TABLE tb_user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT,
        gender TEXT,
        address TEXT,
        photo_path TEXT
      )
    ''');

    // ── TABEL MASTER: tb_menu (Katalog Menu) ──
    await db.execute('''
      CREATE TABLE tb_menu (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        name          TEXT    NOT NULL,
        category      TEXT    NOT NULL,
        address       TEXT    NOT NULL,
        description   TEXT    NOT NULL,
        image_path    TEXT    NOT NULL,
        price         REAL    NOT NULL,
        rating        REAL    NOT NULL,
        delivery_time TEXT    NOT NULL,
        distance      TEXT    NOT NULL,
        calories      INTEGER NOT NULL,
        tags          TEXT    NOT NULL
      )
    ''');

    // ── TABEL TRANSAKSI: tb_pesanan (Riwayat Order) ──
    await db.execute('''
      CREATE TABLE tb_pesanan (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id        INTEGER NOT NULL,
        menu_id        INTEGER NOT NULL,
        quantity       INTEGER NOT NULL,
        date_label     TEXT    NOT NULL,
        status_label   TEXT    NOT NULL,
        is_success     INTEGER NOT NULL,
        total          REAL    NOT NULL,
        promo_discount REAL    NOT NULL,
        shipping_cost  REAL    NOT NULL,
        tax            REAL    NOT NULL,
        promo_code     TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES tb_user (id)
          ON DELETE CASCADE,
        FOREIGN KEY (menu_id) REFERENCES tb_menu (id)
          ON DELETE CASCADE
      )
    ''');

    // ── TABEL KERANJANG: tb_cart (Keranjang Belanja) ──
    await db.execute('''
      CREATE TABLE tb_cart (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id  INTEGER NOT NULL,
        menu_id  INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES tb_user (id)
          ON DELETE CASCADE,
        FOREIGN KEY (menu_id) REFERENCES tb_menu (id)
          ON DELETE CASCADE
      )
    ''');

    await _seedUserData(db);
    await _seedMenuData(db);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SEEDERS (Pengisi Data Awal Native)
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _seedUserData(Database db) async {
    // 1. Akun Admin
    await db.insert('tb_user', {
      'id': 1,
      'name': 'Admin Foodie',
      'email': 'admin@gmail.com',
      'password': 'admin123',
      'phone': '081234567890',
      'gender': 'Laki - laki',
      'address': 'Kantor Pusat Foodie',
      'photo_path': '',
    });

    // 2. Akun User Biasa (Fattah Syauqi)
    await db.insert('tb_user', {
      'id': 2,
      'name': 'M. Fattah Syauqi',
      'email': 'msyauqi559@gmail.com',
      'password': 'user123',
      'phone': '085856238817',
      'gender': 'Laki - laki',
      'address': 'Jl. Imam Bonjol No. 19, Pasuruan, Jawa Timur',
      'photo_path': '',
    });
  }

  Future<void> _seedMenuData(Database db) async {
    for (final menu in _initialMenus) {
      await db.insert('tb_menu', {
        'id': menu['id'],
        'name': menu['name'],
        'category': menu['category'],
        'address': menu['address'],
        'description': menu['description'],
        'image_path': menu['image_path'],
        'price': menu['price'],
        'rating': menu['rating'],
        'delivery_time': menu['delivery_time'],
        'distance': menu['distance'],
        'calories': menu['calories'],
        'tags': menu['tags'],
      });
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CRUD — tb_menu
  // ════════════════════════════════════════════════════════════════════════════

  Future<int> insertMenu(FoodItem food) async {
    if (_useMemoryFallback) {
      final id = _webMenuIdCounter++;
      final map = food.toMap();
      map['id'] = id;
      _webMenus.add(map);
      return id;
    }
    final Database db = await database;
    return await db.insert('tb_menu', food.toMap());
  }

  Future<List<FoodItem>> getAllMenus() async {
    if (_useMemoryFallback) {
      return _webMenus.map((map) => FoodItem.fromMap(map)).toList();
    }
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tb_menu');
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<List<FoodItem>> getMenusByCategory(String category) async {
    if (_useMemoryFallback) {
      final filtered = _webMenus.where((m) => m['category'] == category).toList();
      return filtered.map((map) => FoodItem.fromMap(map)).toList();
    }
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tb_menu',
      where: 'category = ?',
      whereArgs: [category],
    );
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<FoodItem?> getMenuById(int id) async {
    if (_useMemoryFallback) {
      final match = _webMenus.where((m) => m['id'] == id).firstOrNull;
      if (match == null) return null;
      return FoodItem.fromMap(match);
    }
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tb_menu',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FoodItem.fromMap(maps.first);
  }

  Future<int> updateMenu(FoodItem food) async {
    if (_useMemoryFallback) {
      final index = _webMenus.indexWhere((m) => m['id'] == food.dbId);
      if (index != -1) {
        final map = food.toMap();
        map['id'] = food.dbId;
        _webMenus[index] = map;
        return 1;
      }
      return 0;
    }
    final Database db = await database;
    return await db.update(
      'tb_menu',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.dbId],
    );
  }

  Future<int> deleteMenu(int id) async {
    if (_useMemoryFallback) {
      final countBefore = _webMenus.length;
      _webMenus.removeWhere((m) => m['id'] == id);
      _webOrders.removeWhere((o) => o['menu_id'] == id);
      return countBefore - _webMenus.length;
    }
    final Database db = await database;
    return await db.delete(
      'tb_menu',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CRUD — tb_pesanan (Dengan Info User)
  // ════════════════════════════════════════════════════════════════════════════

  Future<int> insertPesanan(OrderHistoryItem order) async {
    if (_useMemoryFallback) {
      final id = _webOrderIdCounter++;
      final map = order.toMap();
      map['id'] = id;
      _webOrders.add(map);
      return id;
    }
    final Database db = await database;
    return await db.insert('tb_pesanan', order.toMap());
  }

  /// Membaca semua pesanan dari semua user (digunakan oleh ADMIN)
  Future<List<OrderHistoryItem>> getAllPesanan() async {
    if (_useMemoryFallback) {
      final List<OrderHistoryItem> list = [];
      for (final orderMap in _webOrders) {
        final user = _webUsers.where((u) => u['id'] == orderMap['user_id']).firstOrNull;
        final menu = _webMenus.where((m) => m['id'] == orderMap['menu_id']).firstOrNull;
        if (menu != null) {
          final joinedMap = Map<String, dynamic>.from(orderMap);
          joinedMap['u_name'] = user?['name'] ?? 'User Umum';
          joinedMap['u_photo_path'] = user?['photo_path'] ?? '';
          joinedMap['u_address'] = user?['address'] ?? '';
          joinedMap['u_phone'] = user?['phone'] ?? '';
          joinedMap['m_name'] = menu['name'];
          joinedMap['m_category'] = menu['category'];
          joinedMap['m_address'] = menu['address'];
          joinedMap['m_description'] = menu['description'];
          joinedMap['m_image_path'] = menu['image_path'];
          joinedMap['m_price'] = menu['price'];
          joinedMap['m_rating'] = menu['rating'];
          joinedMap['m_delivery_time'] = menu['delivery_time'];
          joinedMap['m_distance'] = menu['distance'];
          joinedMap['m_calories'] = menu['calories'];
          joinedMap['m_tags'] = menu['tags'];
          list.add(OrderHistoryItem.fromMap(joinedMap));
        }
      }
      return list.reversed.toList();
    }
    
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        p.id,
        p.user_id,
        p.menu_id,
        p.quantity,
        p.date_label,
        p.status_label,
        p.is_success,
        p.total,
        p.promo_discount,
        p.shipping_cost,
        p.tax,
        p.promo_code,
        u.name          AS u_name,
        u.photo_path    AS u_photo_path,
        u.address       AS u_address,
        u.phone         AS u_phone,
        m.name          AS m_name,
        m.category      AS m_category,
        m.address       AS m_address,
        m.description   AS m_description,
        m.image_path    AS m_image_path,
        m.price         AS m_price,
        m.rating        AS m_rating,
        m.delivery_time AS m_delivery_time,
        m.distance      AS m_distance,
        m.calories      AS m_calories,
        m.tags          AS m_tags
      FROM tb_pesanan p
      INNER JOIN tb_menu m ON p.menu_id = m.id
      LEFT JOIN tb_user u ON p.user_id = u.id
      ORDER BY p.id DESC
    ''');

    return maps.map((map) => OrderHistoryItem.fromMap(map)).toList();
  }

  /// Membaca pesanan milik user tertentu (digunakan oleh USER pada HistoryPage)
  Future<List<OrderHistoryItem>> getPesananByUserId(int userId) async {
    if (_useMemoryFallback) {
      final all = await getAllPesanan();
      return all.where((o) => o.userId == userId).toList();
    }
    
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        p.id,
        p.user_id,
        p.menu_id,
        p.quantity,
        p.date_label,
        p.status_label,
        p.is_success,
        p.total,
        p.promo_discount,
        p.shipping_cost,
        p.tax,
        p.promo_code,
        u.name          AS u_name,
        u.photo_path    AS u_photo_path,
        u.address       AS u_address,
        u.phone         AS u_phone,
        m.name          AS m_name,
        m.category      AS m_category,
        m.address       AS m_address,
        m.description   AS m_description,
        m.image_path    AS m_image_path,
        m.price         AS m_price,
        m.rating        AS m_rating,
        m.delivery_time AS m_delivery_time,
        m.distance      AS m_distance,
        m.calories      AS m_calories,
        m.tags          AS m_tags
      FROM tb_pesanan p
      INNER JOIN tb_menu m ON p.menu_id = m.id
      LEFT JOIN tb_user u ON p.user_id = u.id
      WHERE p.user_id = ?
      ORDER BY p.id DESC
    ''', [userId]);

    return maps.map((map) => OrderHistoryItem.fromMap(map)).toList();
  }

  Future<int> deletePesanan(int id) async {
    if (_useMemoryFallback) {
      final countBefore = _webOrders.length;
      _webOrders.removeWhere((o) => o['id'] == id);
      return countBefore - _webOrders.length;
    }
    final Database db = await database;
    return await db.delete(
      'tb_pesanan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Memperbarui status transaksi pesanan user (Berhasil / Gagal / Belum Membayar)
  Future<int> updatePesananStatus(int id, String statusLabel) async {
    final int isSuccessVal = (statusLabel == 'Berhasil') ? 1 : 0;
    if (_useMemoryFallback) {
      final idx = _webOrders.indexWhere((o) => o['id'] == id);
      if (idx != -1) {
        _webOrders[idx]['is_success'] = isSuccessVal;
        _webOrders[idx]['status_label'] = statusLabel;
        return 1;
      }
      return 0;
    }
    final Database db = await database;
    return await db.update(
      'tb_pesanan',
      {
        'is_success': isSuccessVal,
        'status_label': statusLabel,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CRUD — tb_user (Registrasi, Login, Profil Dinamis)
  // ════════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    final String cleanEmail = email.trim().toLowerCase();

    if (_useMemoryFallback) {
      final exists = _webUsers.any((u) => u['email'] == cleanEmail);
      if (exists) {
        return {
          'success': false,
          'message': 'Email sudah terdaftar. Silakan gunakan email lain.'
        };
      }
      final id = _webUserIdCounter++;
      _webUsers.add({
        'id': id,
        'name': name.trim(),
        'email': cleanEmail,
        'password': password,
        'phone': '',
        'gender': 'Laki - laki',
        'address': '',
        'photo_path': '',
      });
      return {
        'success': true,
        'id': id,
        'message': 'Registrasi berhasil. Silakan masuk.'
      };
    }

    final Database db = await database;
    final List<Map<String, dynamic>> existingUser = await db.query(
      'tb_user',
      where: 'email = ?',
      whereArgs: [cleanEmail],
    );

    if (existingUser.isNotEmpty) {
      return {
        'success': false,
        'message': 'Email sudah terdaftar. Silakan gunakan email lain.'
      };
    }

    try {
      final id = await db.insert('tb_user', {
        'name': name.trim(),
        'email': cleanEmail,
        'password': password,
        'phone': '',
        'gender': 'Laki - laki',
        'address': '',
        'photo_path': '',
      });
      return {
        'success': true,
        'id': id,
        'message': 'Registrasi berhasil. Silakan masuk.'
      };
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        return {
          'success': false,
          'message': 'Email sudah terdaftar.'
        };
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan sistem: $e'
      };
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final String cleanEmail = email.trim().toLowerCase();

    if (_useMemoryFallback) {
      final match = _webUsers.where((u) => u['email'] == cleanEmail && u['password'] == password).firstOrNull;
      if (match == null) {
        return {
          'success': false,
          'message': 'Email atau password salah.'
        };
      }
      return {
        'success': true,
        'user': match,
        'message': 'Login berhasil.'
      };
    }

    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tb_user',
      where: 'email = ? AND password = ?',
      whereArgs: [cleanEmail, password],
    );

    if (maps.isEmpty) {
      return {
        'success': false,
        'message': 'Email atau password salah.'
      };
    }

    return {
      'success': true,
      'user': maps.first,
      'message': 'Login berhasil.'
    };
  }

  /// Mendapatkan data profil user berdasarkan ID
  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    if (_useMemoryFallback) {
      return _webUsers.where((u) => u['id'] == userId).firstOrNull;
    }

    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tb_user',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Memperbarui detail profil user
  Future<int> updateUserProfile({
    required int userId,
    required String name,
    required String phone,
    required String gender,
    required String address,
    required String? photoPath,
  }) async {
    if (_useMemoryFallback) {
      final index = _webUsers.indexWhere((u) => u['id'] == userId);
      if (index != -1) {
        _webUsers[index] = {
          'id': userId,
          'name': name.trim(),
          'email': _webUsers[index]['email'],
          'password': _webUsers[index]['password'],
          'phone': phone.trim(),
          'gender': gender,
          'address': address.trim(),
          'photo_path': photoPath,
        };
        return 1;
      }
      return 0;
    }

    final Database db = await database;
    return await db.update(
      'tb_user',
      {
        'name': name.trim(),
        'phone': phone.trim(),
        'gender': gender,
        'address': address.trim(),
        'photo_path': photoPath,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CRUD — tb_cart (Keranjang Belanja)
  // ════════════════════════════════════════════════════════════════════════════

  Future<int> addToCart(int userId, int menuId, int quantity) async {
    if (_useMemoryFallback) {
      final match = _webCart.where((item) => item['user_id'] == userId && item['menu_id'] == menuId).firstOrNull;
      if (match != null) {
        match['quantity'] = (match['quantity'] as int) + quantity;
        return match['id'] as int;
      }
      final id = _webCartIdCounter++;
      _webCart.add({
        'id': id,
        'user_id': userId,
        'menu_id': menuId,
        'quantity': quantity,
      });
      return id;
    }
    final Database db = await database;
    final List<Map<String, dynamic>> existing = await db.query(
      'tb_cart',
      where: 'user_id = ? AND menu_id = ?',
      whereArgs: [userId, menuId],
    );
    if (existing.isNotEmpty) {
      final currentQty = existing.first['quantity'] as int;
      final newQty = currentQty + quantity;
      return await db.update(
        'tb_cart',
        {'quantity': newQty},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
    return await db.insert('tb_cart', {
      'user_id': userId,
      'menu_id': menuId,
      'quantity': quantity,
    });
  }

  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    if (_useMemoryFallback) {
      final List<Map<String, dynamic>> results = [];
      for (final item in _webCart.where((c) => c['user_id'] == userId)) {
        final menu = _webMenus.where((m) => m['id'] == item['menu_id']).firstOrNull;
        if (menu != null) {
          results.add({
            'id': item['id'],
            'user_id': item['user_id'],
            'menu_id': item['menu_id'],
            'quantity': item['quantity'],
            'food': FoodItem.fromMap(menu),
          });
        }
      }
      return results;
    }
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.id, c.user_id, c.menu_id, c.quantity,
             m.name AS m_name, m.category AS m_category, m.address AS m_address,
             m.description AS m_description, m.image_path AS m_image_path,
             m.price AS m_price, m.rating AS m_rating, m.delivery_time AS m_delivery_time,
             m.distance AS m_distance, m.calories AS m_calories, m.tags AS m_tags
      FROM tb_cart c
      INNER JOIN tb_menu m ON c.menu_id = m.id
      WHERE c.user_id = ?
    ''', [userId]);

    return maps.map((map) {
      return {
        'id': map['id'],
        'user_id': map['user_id'],
        'menu_id': map['menu_id'],
        'quantity': map['quantity'],
        'food': FoodItem.fromMap({
          'id': map['menu_id'],
          'name': map['m_name'],
          'category': map['m_category'],
          'address': map['m_address'],
          'description': map['m_description'],
          'image_path': map['m_image_path'],
          'price': map['m_price'],
          'rating': map['m_rating'],
          'delivery_time': map['m_delivery_time'],
          'distance': map['m_distance'],
          'calories': map['m_calories'],
          'tags': map['m_tags'],
        }),
      };
    }).toList();
  }

  Future<int> updateCartQuantity(int cartId, int quantity) async {
    if (_useMemoryFallback) {
      final idx = _webCart.indexWhere((c) => c['id'] == cartId);
      if (idx != -1) {
        _webCart[idx]['quantity'] = quantity;
        return 1;
      }
      return 0;
    }
    final Database db = await database;
    return await db.update(
      'tb_cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<int> removeFromCart(int cartId) async {
    if (_useMemoryFallback) {
      final len = _webCart.length;
      _webCart.removeWhere((c) => c['id'] == cartId);
      return len - _webCart.length;
    }
    final Database db = await database;
    return await db.delete(
      'tb_cart',
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<void> clearCart(int userId) async {
    if (_useMemoryFallback) {
      _webCart.removeWhere((c) => c['user_id'] == userId);
      return;
    }
    final Database db = await database;
    await db.delete(
      'tb_cart',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // UTILITIES
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> close() async {
    if (_useMemoryFallback) return;
    final Database db = await database;
    await db.close();
    _database = null;
  }

  Future<void> resetDatabase() async {
    if (_useMemoryFallback) {
      _webUsers.clear();
      _webMenus.clear();
      _webOrders.clear();
      _webCart.clear();
      _webUsers.addAll([
        {
          'id': 1,
          'name': 'Admin Foodie',
          'email': 'admin@gmail.com',
          'password': 'admin123',
          'phone': '081234567890',
          'gender': 'Laki - laki',
          'address': 'Kantor Pusat Foodie',
          'photo_path': '',
        },
        {
          'id': 2,
          'name': 'M. Fattah Syauqi',
          'email': 'msyauqi559@gmail.com',
          'password': 'user123',
          'phone': '085856238817',
          'gender': 'Laki - laki',
          'address': 'Jl. Imam Bonjol No. 19, Pasuruan, Jawa Timur',
          'photo_path': '',
        }
      ]);
      return;
    }
    final Database db = await database;
    await db.delete('tb_user');
    await db.delete('tb_pesanan');
    await db.delete('tb_menu');
    await db.delete('tb_cart');
    await _seedUserData(db);
    await _seedMenuData(db);
  }
}
