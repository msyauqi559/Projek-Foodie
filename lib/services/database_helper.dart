import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/food_item.dart';
import '../models/order_history_item.dart';

/// Kelas untuk mengelola semua operasi database SQLite di aplikasi Foodie.

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('foodie.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 12, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
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
  }

  // Hanya menginisialisasi akun admin sistem agar admin bisa login untuk menginput data
  Future<void> _seedUserData(Database db) async {
    await db.insert('tb_user', {
      'id': 1,
      'name': 'Admin Foodie',
      'email': 'admin@gmail.com',
      'password': 'admin123',
      'phone': '081234567890',
      'gender': 'Waria',
      'address': 'Kantor Pusat Foodie',
      'photo_path': '',
    });
  }

  // -- CRUD tb_menu --

  Future<int> insertMenu(FoodItem food) async {
    final Database db = await database;
    return await db.insert('tb_menu', food.toMap());
  }

  Future<List<FoodItem>> getAllMenus() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tb_menu');
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<List<FoodItem>> getMenusByCategory(String category) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tb_menu',
      where: 'category = ?',
      whereArgs: [category],
    );
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<FoodItem?> getMenuById(int id) async {
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
    final Database db = await database;
    return await db.update(
      'tb_menu',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.dbId],
    );
  }

  Future<int> deleteMenu(int id) async {
    final Database db = await database;
    return await db.delete(
      'tb_menu',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -- CRUD tb_pesanan --

  Future<int> insertPesanan(OrderHistoryItem order) async {
    final Database db = await database;
    return await db.insert('tb_pesanan', order.toMap());
  }

  /// Membaca semua pesanan dari semua user (digunakan oleh ADMIN)
  Future<List<OrderHistoryItem>> getAllPesanan() async {
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

  // -- CRUD tb_user (Registrasi, Login, Profil) --

  Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    final String cleanEmail = email.trim().toLowerCase();
    final Database db = await database;

    // Pengecekan apakah email sudah terdaftar apa belum
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

    // Memasukkan data baru atau data si user ketika registrasi 
    try {
      final id = await db.insert('tb_user', {
        'name': name.trim(),
        'email': cleanEmail,
        'password': password, // Data dikemabangkan menggunakan hashing (SHA-256)
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

  // -- CRUD tb_cart --

  Future<int> addToCart(int userId, int menuId, int quantity) async {
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
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.id, c.user_id, c.menu_id, c.quantity,
             m.name AS m_name, m.category AS m_category, m.address AS m_address,
             m.description AS m_description, m.image_path AS m_image_path,
             m.price AS m_price, m.rating AS m_rating,
             m.tags AS m_tags
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
          'tags': map['m_tags'],
        }),
      };
    }).toList();
  }

  Future<int> updateCartQuantity(int cartId, int quantity) async {
    final Database db = await database;
    return await db.update(
      'tb_cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<int> removeFromCart(int cartId) async {
    final Database db = await database;
    return await db.delete(
      'tb_cart',
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<void> clearCart(int userId) async {
    final Database db = await database;
    await db.delete(
      'tb_cart',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // -- Utilities --

  Future<void> close() async {
    final Database db = await database;
    await db.close();
    _database = null;
  }

  Future<void> resetDatabase() async {
    final Database db = await database;
    await db.delete('tb_user');
    await db.delete('tb_pesanan');
    await db.delete('tb_menu');
    await db.delete('tb_cart');
    await _seedUserData(db);
  }
}
