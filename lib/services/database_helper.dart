import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../constants/app_assets.dart';
import '../models/food_item.dart';
import '../models/order_history_item.dart';

/// DatabaseHelper — Kelas inti untuk mengelola koneksi SQLite.
///
/// Menggunakan **Singleton Pattern** agar hanya ada 1 instance database
/// di seluruh aplikasi. Ini mencegah konflik jika beberapa halaman
/// mengakses database secara bersamaan.
///
/// Berisi:
/// - Inisialisasi database & pembuatan tabel
/// - CRUD untuk tabel `tb_menu` (Master)
/// - CRUD untuk tabel `tb_pesanan` (Transaksi)
/// - Seed data awal (menu default)
class DatabaseHelper {
  // ══════════════════════════════════════════════════════════
  // SINGLETON PATTERN
  // ══════════════════════════════════════════════════════════

  /// Instance tunggal — dipanggil: DatabaseHelper.instance
  static final DatabaseHelper instance = DatabaseHelper._init();

  /// Variabel private untuk menyimpan referensi database.
  /// Nullable (?) karena belum dibuat sampai pertama kali dipanggil.
  static Database? _database;

  /// Constructor private — tidak bisa di-new dari luar class.
  DatabaseHelper._init();

  // ══════════════════════════════════════════════════════════
  // INISIALISASI DATABASE
  // ══════════════════════════════════════════════════════════

  /// Getter database dengan lazy initialization.
  ///
  /// Cara kerja:
  /// 1. Cek apakah [_database] sudah ada → jika ya, langsung return.
  /// 2. Jika belum → panggil [_initDB] untuk membuat database baru.
  /// 3. Simpan hasilnya ke [_database] agar tidak perlu buat ulang.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('foodie.db');
    return _database!;
  }

  /// Membuat/membuka file database di lokasi default device.
  ///
  /// [getDatabasesPath()] → mendapatkan path folder database device
  ///   - Android: /data/data/<package>/databases/
  ///   - iOS: Documents directory
  /// [join()] → menggabungkan path folder + nama file → full path
  /// [openDatabase()] → membuka DB jika ada, atau buat baru jika belum
  ///   - [version: 1] → versi skema database
  ///   - [onCreate] → callback yang dipanggil HANYA saat DB pertama kali dibuat
  Future<Database> _initDB(String fileName) async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Callback pembuatan tabel — dipanggil sekali saat database baru dibuat.
  ///
  /// Membuat 2 tabel:
  /// 1. [tb_menu] — Tabel Master: menyimpan data menu makanan
  /// 2. [tb_pesanan] — Tabel Transaksi: menyimpan data pesanan
  ///
  /// Setelah tabel dibuat, langsung isi data awal (seed) agar app tidak kosong.
  Future<void> _createDB(Database db, int version) async {
    // ── Tabel Master: tb_menu ──
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

    // ── Tabel Transaksi: tb_pesanan ──
    // FOREIGN KEY: menu_id merujuk ke tb_menu.id
    // Artinya setiap pesanan HARUS punya menu yang valid di tb_menu
    await db.execute('''
      CREATE TABLE tb_pesanan (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        menu_id        INTEGER NOT NULL,
        quantity        INTEGER NOT NULL,
        date_label     TEXT    NOT NULL,
        status_label   TEXT    NOT NULL,
        is_success     INTEGER NOT NULL,
        total          REAL    NOT NULL,
        promo_discount REAL    NOT NULL,
        shipping_cost  REAL    NOT NULL,
        tax            REAL    NOT NULL,
        promo_code     TEXT    NOT NULL,
        FOREIGN KEY (menu_id) REFERENCES tb_menu (id)
          ON DELETE CASCADE
      )
    ''');

    // ── Seed data awal ──
    await _seedMenuData(db);
    await _seedPesananData(db);
  }

  // ══════════════════════════════════════════════════════════
  // SEED DATA (Data Awal)
  // ══════════════════════════════════════════════════════════

  /// Mengisi tb_menu dengan data default menu Foodie.
  /// Data ini sama dengan yang sebelumnya ada di DummyDataService.
  Future<void> _seedMenuData(Database db) async {
    final List<Map<String, dynamic>> menus = [
      {
        'name': 'Mie Ayam Tunggal Rasa',
        'category': 'Nusantara',
        'address': 'Jl. Imam Bonjol, No.19 Pasuruan',
        'description':
            'Masakan Indonesia yang terbuat dari mi kuning direbus mendidih kemudian ditaburi saus kecap khusus beserta daging ayam dan sayuran.',
        'image_path': AppAssets.mieAyam,
        'price': 15000.0,
        'rating': 4.9,
        'delivery_time': '12 min',
        'distance': '900 m',
        'calories': 340,
        'tags': 'Favorite,Gurih,Fresh',
      },
      {
        'name': 'Rendang Daging',
        'category': 'Nusantara',
        'address': 'Jl. Imam Bonjol, No.19 Pasuruan',
        'description':
            'Rendang dengan bumbu rempah kaya rasa, daging empuk, dan plating khas Nusantara yang menggugah selera.',
        'image_path': AppAssets.rendang,
        'price': 45000.0,
        'rating': 4.9,
        'delivery_time': '20 min',
        'distance': '1.8 km',
        'calories': 420,
        'tags': 'Best Seller,Pedas,Bumbu Pekat',
      },
      {
        'name': 'Rawon',
        'category': 'Nusantara',
        'address': 'Jl. Imam Bonjol, No.19 Pasuruan',
        'description':
            'Rawon khas Jawa Timur dengan kuah hitam pekat, daging empuk, dan pelengkap telur serta sambal.',
        'image_path': AppAssets.rawon,
        'price': 20000.0,
        'rating': 4.9,
        'delivery_time': '18 min',
        'distance': '1.1 km',
        'calories': 390,
        'tags': 'Kuah Gurih,Lokal,Hangat',
      },
      {
        'name': 'Bakso solo',
        'category': 'Nusantara',
        'address': 'Jl. Diponegoro Kota pasuruan',
        'description':
            'Bakso solo dengan kuah kaldu gurih, mie, dan potongan bakso sapi yang lembut.',
        'image_path': AppAssets.bakso,
        'price': 15000.0,
        'rating': 4.8,
        'delivery_time': '15 min',
        'distance': '1.2 km',
        'calories': 360,
        'tags': 'Hangat,Laris,Comfort Food',
      },
      {
        'name': 'Salad',
        'category': 'Sehat',
        'address': 'Jl. Imam Bonjol, No.19 Pasuruan',
        'description':
            'Salad sayur segar dengan telur, tomat, timun, dan dressing ringan yang cocok untuk makanan sehat.',
        'image_path': AppAssets.salad,
        'price': 25000.0,
        'rating': 4.9,
        'delivery_time': '10 min',
        'distance': '700 m',
        'calories': 190,
        'tags': 'Low Calorie,Fresh,Diet Friendly',
      },
      {
        'name': 'Gado - gado',
        'category': 'Sehat',
        'address': 'Jl. Imam Bonjol, No.19 Pasuruan',
        'description':
            'Gado-gado dengan sayuran rebus, telur, tahu, dan saus kacang gurih yang autentik.',
        'image_path': AppAssets.lontongBalap,
        'price': 12000.0,
        'rating': 4.9,
        'delivery_time': '13 min',
        'distance': '850 m',
        'calories': 280,
        'tags': 'Sehat,Murah,Sayur Lengkap',
      },
      {
        'name': 'Buah buahan kemasan (bebas request)',
        'category': 'Sehat',
        'address': 'bebas request',
        'description':
            'Buah segar dalam kemasan praktis. Isi bisa disesuaikan sesuai request selama stok tersedia.',
        'image_path': AppAssets.packagedFruit,
        'price': 15000.0,
        'rating': 4.9,
        'delivery_time': '9 min',
        'distance': '600 m',
        'calories': 150,
        'tags': 'Fresh,Praktis,Bebas Request',
      },
      {
        'name': 'Lontong Balap',
        'category': 'Fastfood',
        'address': 'Jl. Imam Bonjol, No.19 Pasuruan',
        'description':
            'Lontong balap dengan tahu, lentho, tauge, dan kuah gurih khas Surabaya.',
        'image_path': AppAssets.lontongBalap,
        'price': 15000.0,
        'rating': 4.9,
        'delivery_time': '14 min',
        'distance': '1.0 km',
        'calories': 310,
        'tags': 'Cepat Saji,Gurih,Lokal',
      },
      {
        'name': 'Fastfood Special',
        'category': 'Fastfood',
        'address': 'Jl. Imam Bonjol, No.19 Pasuruan',
        'description':
            'Menu cepat saji dengan rasa gurih dan penyajian cepat untuk makan praktis.',
        'image_path': AppAssets.kebab,
        'price': 18000.0,
        'rating': 4.8,
        'delivery_time': '11 min',
        'distance': '950 m',
        'calories': 280,
        'tags': 'Cepat,Praktis,Camilan',
      },
      {
        'name': 'Buah buahan kemasan',
        'category': 'Fastfood',
        'address': 'bebas request',
        'description':
            'Buah segar praktis siap santap untuk camilan cepat saat beraktivitas.',
        'image_path': AppAssets.packagedFruit,
        'price': 15000.0,
        'rating': 4.9,
        'delivery_time': '9 min',
        'distance': '600 m',
        'calories': 150,
        'tags': 'Fresh,Cepat,Praktis',
      },
    ];

    // Batch insert → lebih cepat daripada insert satu-satu
    final Batch batch = db.batch();
    for (final menu in menus) {
      batch.insert('tb_menu', menu);
    }
    await batch.commit(noResult: true);
  }

  /// Mengisi tb_pesanan dengan beberapa data riwayat pesanan awal.
  Future<void> _seedPesananData(Database db) async {
    final List<Map<String, dynamic>> pesanan = [
      {
        'menu_id': 1, // Mie Ayam (id=1 di tb_menu)
        'quantity': 1,
        'date_label': 'Yesterday',
        'status_label': 'Berhasil',
        'is_success': 1,
        'total': 19500.0,
        'promo_discount': 2000.0,
        'shipping_cost': 5000.0,
        'tax': 1500.0,
        'promo_code': '872008',
      },
      {
        'menu_id': 2, // Rendang (id=2 di tb_menu)
        'quantity': 2,
        'date_label': '4 Day Ago',
        'status_label': 'GAGAL',
        'is_success': 0,
        'total': 90000.0,
        'promo_discount': 0.0,
        'shipping_cost': 5000.0,
        'tax': 3000.0,
        'promo_code': '872008',
      },
      {
        'menu_id': 6, // Gado-gado (id=6 di tb_menu)
        'quantity': 5,
        'date_label': 'Today',
        'status_label': 'GAGAL',
        'is_success': 0,
        'total': 60000.0,
        'promo_discount': 0.0,
        'shipping_cost': 5000.0,
        'tax': 6000.0,
        'promo_code': '872008',
      },
      {
        'menu_id': 6, // Gado-gado (id=6 di tb_menu)
        'quantity': 1,
        'date_label': 'Today',
        'status_label': 'Berhasil',
        'is_success': 1,
        'total': 12000.0,
        'promo_discount': 0.0,
        'shipping_cost': 5000.0,
        'tax': 1200.0,
        'promo_code': '872008',
      },
    ];

    final Batch batch = db.batch();
    for (final p in pesanan) {
      batch.insert('tb_pesanan', p);
    }
    await batch.commit(noResult: true);
  }

  // ══════════════════════════════════════════════════════════
  // CRUD — TABEL MASTER: tb_menu
  // ══════════════════════════════════════════════════════════

  /// **CREATE** — Menambahkan menu baru ke tb_menu.
  ///
  /// [food.toMap()] mengkonversi FoodItem → Map sesuai kolom tabel.
  /// Mengembalikan ID baris yang baru di-insert.
  Future<int> insertMenu(FoodItem food) async {
    final Database db = await database;
    return await db.insert('tb_menu', food.toMap());
  }

  /// **READ ALL** — Mengambil semua data dari tb_menu.
  ///
  /// [db.query('tb_menu')] = SELECT * FROM tb_menu
  /// Setiap row (Map) dikonversi ke FoodItem dengan [fromMap()].
  Future<List<FoodItem>> getAllMenus() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tb_menu');
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  /// **READ BY CATEGORY** — Mengambil menu berdasarkan kategori.
  ///
  /// [where: 'category = ?'] → filter berdasarkan kolom category
  /// [whereArgs: [category]] → nilai parameter (mencegah SQL injection)
  Future<List<FoodItem>> getMenusByCategory(String category) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tb_menu',
      where: 'category = ?',
      whereArgs: [category],
    );
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  /// **READ BY ID** — Mengambil 1 menu berdasarkan ID.
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

  /// **UPDATE** — Mengubah data menu yang sudah ada.
  ///
  /// [where: 'id = ?'] → hanya ubah baris dengan ID tertentu
  /// Mengembalikan jumlah baris yang terpengaruh (seharusnya 1).
  Future<int> updateMenu(FoodItem food) async {
    final Database db = await database;
    return await db.update(
      'tb_menu',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.dbId],
    );
  }

  /// **DELETE** — Menghapus menu berdasarkan ID.
  ///
  /// Pesanan terkait di tb_pesanan juga ikut terhapus (ON DELETE CASCADE).
  Future<int> deleteMenu(int id) async {
    final Database db = await database;
    return await db.delete(
      'tb_menu',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ══════════════════════════════════════════════════════════
  // CRUD — TABEL TRANSAKSI: tb_pesanan
  // ══════════════════════════════════════════════════════════

  /// **CREATE PESANAN** — Menyimpan pesanan baru ke tb_pesanan.
  Future<int> insertPesanan(OrderHistoryItem order) async {
    final Database db = await database;
    return await db.insert('tb_pesanan', order.toMap());
  }

  /// **READ ALL PESANAN** — Mengambil semua pesanan beserta data menu-nya.
  ///
  /// Menggunakan JOIN antara tb_pesanan dan tb_menu:
  /// - `p.*` = semua kolom pesanan
  /// - `m.name AS m_name` dst = kolom menu dengan alias prefix 'm_'
  ///
  /// Alias diperlukan agar tidak bentrok dengan kolom pesanan (misal: `id`).
  /// Hasilnya di-sort berdasarkan ID pesanan terbaru (DESC).
  Future<List<OrderHistoryItem>> getAllPesanan() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        p.id,
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
      ORDER BY p.id DESC
    ''');

    return maps.map((map) => OrderHistoryItem.fromMap(map)).toList();
  }

  /// **DELETE PESANAN** — Menghapus pesanan berdasarkan ID.
  Future<int> deletePesanan(int id) async {
    final Database db = await database;
    return await db.delete(
      'tb_pesanan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ══════════════════════════════════════════════════════════
  // UTILITY
  // ══════════════════════════════════════════════════════════

  /// Menutup koneksi database. Dipanggil saat app dimatikan.
  Future<void> close() async {
    final Database db = await database;
    await db.close();
    _database = null;
  }

  /// Menghapus semua data dan membuat ulang (untuk reset/debug).
  Future<void> resetDatabase() async {
    final Database db = await database;
    await db.delete('tb_pesanan');
    await db.delete('tb_menu');
    await _seedMenuData(db);
    await _seedPesananData(db);
  }
}
