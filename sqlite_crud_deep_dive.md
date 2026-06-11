# 🗄️ Penjelasan Mendalam SQLite & Operasi CRUD di Flutter

Dokumen ini disusun untuk membantu Anda memahami secara mendalam cara kerja database **SQLite** pada Flutter, serta bagaimana mengimplementasikan operasi **CRUD (Create, Read, Update, Delete)** secara mandiri untuk persiapan *live coding*.

---

## 1. Konsep Utama SQLite

### Apa itu SQLite?
Berbeda dengan database server seperti MySQL atau PostgreSQL yang membutuhkan koneksi internet dan server aktif di latar belakang, **SQLite** adalah database bertipe **embedded (tertanam)**.
* **Satu Berkas Fisik**: Seluruh struktur tabel dan baris data disimpan dalam satu file berkas (contoh: `pelatihan.db`) di direktori privat penyimpanan HP.
* **Serverless**: Query dieksekusi secara lokal langsung di memori perangkat, sehingga proses membaca dan menulis data sangat cepat tanpa ada latensi jaringan.
* **Thread-safe**: SQLite menangani proses baca-tulis secara aman tanpa khawatir data rusak/korup.

---

## 2. Struktur Relasi Objek & Database (Mapping)

Dalam pemrograman berorientasi objek (OOP) di Flutter, data disimpan dalam bentuk objek kelas (contoh: `TargetModel`). Namun, database SQLite hanya memahami baris dan kolom. Oleh karena itu, kita membutuhkan jembatan berupa pemetaan (**Mapping**):

```
+--------------------------+                   +--------------------------+
|       Dart Object        |   -- toMap() -->  |  Map<String, dynamic>    |
| (TargetModel instances)  |   <-- fromMap()   | (SQLite readable data)   |
+--------------------------+                   +--------------------------+
```

### Penjelasan Baris Kode Konversi:
1. **`toMap()`**: Mengubah variabel-variabel di dalam objek kelas menjadi format pasangan `key: value` (Map) untuk dikirim ke SQLite.
2. **`fromMap()`**: Mengubah data mentah Map yang dihasilkan oleh query database kembali menjadi objek Dart agar bisa diakses variabelnya di UI (seperti `item.namaTarget`).

---

## 3. Bedah Detail Kode CRUD & Ekivalen SQL

Berikut adalah implementasi CRUD di Flutter menggunakan library `sqflite` beserta penjelasan perintah SQL mentahnya (*Raw SQL*):

### A. CREATE (Membuat/Menyimpan Data)
Fungsi ini menyisipkan baris data baru ke dalam tabel target.

* **Kode Dart (`sqflite`)**:
  ```dart
  Future<int> insertTarget(TargetModel target) async {
    final db = await database;
    return await db.insert('target_table', target.toMap());
  }
  ```
* **Ekivalen Perintah SQL**:
  ```sql
  INSERT INTO target_table (nama_target) VALUES ('Belajar Flutter');
  ```
* **Keterangan**: Method `insert()` mengembalikan nilai `int` berupa ID dari baris baru yang berhasil dibuat.

### B. READ (Membaca/Menampilkan Data)
Fungsi ini mengambil seluruh baris data dari database untuk ditampilkan di layar.

* **Kode Dart (`sqflite`)**:
  ```dart
  Future<List<TargetModel>> getTargets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('target_table');
    return maps.map((map) => TargetModel.fromMap(map)).toList();
  }
  ```
* **Ekivalen Perintah SQL**:
  ```sql
  SELECT * FROM target_table;
  ```
* **Keterangan**: `db.query()` mengembalikan data berupa `List<Map<String, dynamic>>`. Kita harus merubah list map tersebut menjadi list object menggunakan perulangan `.map()` dan konstruktor `fromMap()`.

### C. UPDATE (Memperbarui Data)
Fungsi ini mengubah kolom data tertentu berdasarkan ID baris yang dipilih.

* **Kode Dart (`sqflite`)**:
  ```dart
  Future<int> updateTarget(TargetModel target) async {
    final db = await database;
    return await db.update(
      'target_table',
      target.toMap(),
      where: 'id = ?',
      whereArgs: [target.id],
    );
  }
  ```
* **Ekivalen Perintah SQL**:
  ```sql
  UPDATE target_table SET nama_target = 'Nama Baru' WHERE id = 1;
  ```
* **PENTING (Keamanan)**: Penggunaan tanda tanya `?` di `where` dan pengisian nilai melalui `whereArgs` disebut **Parameterized Query**. Ini wajib digunakan untuk mencegah serangan **SQL Injection** yang bisa merusak database.

### D. DELETE (Menghapus Data)
Fungsi ini menghapus baris data permanen berdasarkan ID.

* **Kode Dart (`sqflite`)**:
  ```dart
  Future<int> deleteTarget(int id) async {
    final db = await database;
    return await db.delete(
      'target_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  ```
* **Ekivalen Perintah SQL**:
  ```sql
  DELETE FROM target_table WHERE id = 1;
  ```

---

## 💡 4. Checklist Kesiapan Ujian Live Coding

Sebelum memulai ujian *live coding*, pastikan Anda mempraktikkan hal berikut:
1. **Lakukan Reset Database (Uninstall & Install Ulang App)** jika Anda mengubah struktur tabel pada `onCreate` (menambah kolom baru dsb) agar perubahan struktur terbaca di database baru.
2. **Gunakan `await` untuk semua panggilan CRUD** di UI. Panggilan database memakan waktu milidetik, jika tidak menggunakan `await` variabel Anda akan bernilai kosong (*null*).
3. **Selalu panggil `refreshData()`** setiap kali selesai melakukan *Insert*, *Update*, atau *Delete* agar daftar data di layar langsung terupdate secara *real-time*.
