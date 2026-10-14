import 'package:flutter/foundation.dart';

import 'app_database.dart';
import 'models.dart';

/// Satu pintu untuk semua urusan data. Halaman tidak perlu tahu soal SQL.
class TransactionRepository {
  TransactionRepository._();
  static final TransactionRepository instance = TransactionRepository._();

  /// Angkanya naik setiap kali data berubah. Halaman mendengarkan ini untuk refresh.
  final ValueNotifier<int> changes = ValueNotifier<int>(0);


  void _notify() => changes.value++;

  // ---------- Pengaturan ----------
  Future<String> setting(String key, {String fallback = ''}) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return fallback;
    return rows.first['value'] as String;
  }

  Future<String> tipOfTheWeek() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('tips', orderBy: 'id ASC');
    if (rows.isEmpty) return '';
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return rows[(dayOfYear ~/ 7) % rows.length]['text'] as String;
  }

  // ---------- Rekening ----------
  Future<Account> mainAccount() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('accounts', orderBy: 'id ASC', limit: 1);
    return Account.fromMap(rows.first);
  }

  Future<int> balanceOf(Account account) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.rawQuery(
      "SELECT COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END), 0) AS v "
      'FROM transactions WHERE account_id = ?',
      [account.id],
    );
    return account.openingBalance + (rows.first['v'] as num).toInt();
  }

  // ---------- Kategori ----------
  Future<List<TxCategory>> categories(String type) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('categories',
        where: 'type = ?', whereArgs: [type], orderBy: 'id ASC');
    return rows.map(TxCategory.fromMap).toList();
  }

  Future<int> addCategory(String name, String type, {String iconKey = 'tag'}) async {
    final db = await AppDatabase.instance.db;
    return db.insert('categories', {
      'name': name,
      'icon_key': iconKey,
      'type': type,
    });
  }

  // ---------- Transaksi ----------
  Future<int> addTransaction({
    required String title,
    required int amount,
    required String type,
    required int categoryId,
    required int accountId,
    required String method,
    required DateTime createdAt,
  }) async {
    final db = await AppDatabase.instance.db;
    final id = await db.insert('transactions', {
      'title': title,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'account_id': accountId,
      'method': method,
      'created_at': createdAt.millisecondsSinceEpoch,
    });
    _notify();
    return id;
  }

  Future<void> deleteTransaction(int id) async {
    final db = await AppDatabase.instance.db;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    _notify();
  }

  static const _selectJoin =
      'SELECT t.*, c.name AS category_name, c.icon_key AS icon_key '
      'FROM transactions t JOIN categories c ON c.id = t.category_id';

  Future<List<TransactionItem>> recent({int limit = 3}) async {
    final db = await AppDatabase.instance.db;
    final rows =
        await db.rawQuery('$_selectJoin ORDER BY t.created_at DESC LIMIT ?', [limit]);
    return rows.map(TransactionItem.fromMap).toList();
  }

  Future<List<TransactionItem>> history({
    String? type,
    DateTime? month,
    String query = '',
  }) async {
    final db = await AppDatabase.instance.db;
    final where = <String>[];
    final args = <Object>[];

    if (type != null) {
      where.add('t.type = ?');
      args.add(type);
    }
    if (month != null) {
      where.add('t.created_at >= ? AND t.created_at < ?');
      args.add(DateTime(month.year, month.month).millisecondsSinceEpoch);
      args.add(DateTime(month.year, month.month + 1).millisecondsSinceEpoch);
    }
    final q = query.trim();
    if (q.isNotEmpty) {
      where.add('(t.title LIKE ? OR c.name LIKE ?)');
      args.add('%$q%');
      args.add('%$q%');
    }

    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final rows = await db
        .rawQuery('$_selectJoin $whereSql ORDER BY t.created_at DESC', args);
    return rows.map(TransactionItem.fromMap).toList();
  }

  /// Total pemasukan & pengeluaran. [month] kosong = semua waktu.
  Future<Totals> totals({DateTime? month}) async {
    final db = await AppDatabase.instance.db;
    var whereSql = '';
    final args = <Object>[];
    if (month != null) {
      whereSql = 'WHERE created_at >= ? AND created_at < ?';
      args.add(DateTime(month.year, month.month).millisecondsSinceEpoch);
      args.add(DateTime(month.year, month.month + 1).millisecondsSinceEpoch);
    }
    final rows = await db.rawQuery(
      'SELECT type, COALESCE(SUM(amount), 0) AS total, COUNT(*) AS cnt '
      'FROM transactions $whereSql GROUP BY type',
      args,
    );

    var income = 0, expense = 0, incomeCount = 0, expenseCount = 0;
    for (final r in rows) {
      final total = (r['total'] as num).toInt();
      final cnt = (r['cnt'] as num).toInt();
      if (r['type'] == 'income') {
        income = total;
        incomeCount = cnt;
      } else {
        expense = total;
        expenseCount = cnt;
      }
    }
    return Totals(
      income: income,
      expense: expense,
      incomeCount: incomeCount,
      expenseCount: expenseCount,
    );
  }
}
