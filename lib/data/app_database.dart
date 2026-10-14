import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Ubah ke false kalau tidak mau data contoh saat database pertama kali dibuat.
const bool kSeedDemoData = false;

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'fintrack.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bank TEXT NOT NULL,
        opening_balance INTEGER NOT NULL DEFAULT 0
      )''');
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        type TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        method TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY(category_id) REFERENCES categories(id),
        FOREIGN KEY(account_id) REFERENCES accounts(id)
      )''');
    await db.execute(
        'CREATE INDEX idx_transactions_created ON transactions(created_at DESC)');
    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE tips(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL
      )''');
    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final accountId = await db.insert('accounts', {
      'name': 'Rekening Utama',
      'bank': 'BRI',
      'opening_balance': 0,
    });

    final catIds = <String, int>{};
    Future<void> cat(String name, String icon, String type) async {
      catIds['$type:$name'] = await db.insert('categories', {
        'name': name,
        'icon_key': icon,
        'type': type,
      });
    }

    await cat('Makanan', 'food', 'expense');
    await cat('Transport', 'bus', 'expense');
    await cat('Pendidikan', 'school', 'expense');
    await cat('Kos', 'home', 'expense');
    await cat('Hiburan', 'movie', 'expense');
    await cat('Lainnya', 'other', 'expense');
    await cat('Kiriman', 'bank', 'income');
    await cat('Beasiswa', 'award', 'income');
    await cat('Freelance', 'work', 'income');
    await cat('Lainnya', 'other', 'income');

    await db.insert('settings', {'key': 'user_name', 'value': 'Rabka'});
    await db.insert('settings', {'key': 'monthly_budget', 'value': '3000000'});

    const tips = [
      'Batasi jajan kopi dan utamakan pos kos & tabungan darurat sebelum akhir semester.',
      'Catat pengeluaran kecil setiap hari, karena jajan receh sering jadi bocoran terbesar.',
      'Sisihkan 10% uang bulanan di awal bulan sebelum dipakai untuk hal lain.',
      'Bawa bekal dua kali seminggu bisa menghemat cukup banyak dalam sebulan.',
    ];
    for (final t in tips) {
      await db.insert('tips', {'text': t});
    }

    if (!kSeedDemoData) return;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1, 8);
    DateTime ago(Duration d) {
      final t = now.subtract(d);
      return t.isBefore(monthStart) ? monthStart.add(const Duration(hours: 2)) : t;
    }

    Future<void> tx(String title, int amount, String type, String category,
        String method, DateTime at) async {
      await db.insert('transactions', {
        'title': title,
        'amount': amount,
        'type': type,
        'category_id': catIds['$type:$category'],
        'account_id': accountId,
        'method': method,
        'created_at': at.millisecondsSinceEpoch,
      });
    }

    await tx('Kiriman Ortu Bulanan', 1500000, 'income', 'Kiriman',
        'Transfer Masuk', monthStart);
    await tx('Beasiswa Prestasi', 1000000, 'income', 'Beasiswa',
        'Transfer Masuk', monthStart.add(const Duration(hours: 1)));
    await tx('Proyek Desain Logo', 500000, 'income', 'Freelance',
        'Transfer Masuk', monthStart.add(const Duration(hours: 2)));
    await tx('Ayam Geprek', 45000, 'expense', 'Makanan', 'QRIS BRI',
        ago(const Duration(hours: 1)));
    await tx('Bensin', 25000, 'expense', 'Transport', 'Oopay',
        ago(const Duration(hours: 5)));
    await tx('Fotokopi', 35000, 'expense', 'Pendidikan', 'Tunai',
        ago(const Duration(days: 1, hours: 2)));
    await tx('Bayar Tagihan Listrik', 120000, 'expense', 'Kos', 'PLN Token',
        ago(const Duration(days: 2, hours: 1)));
  }
}
