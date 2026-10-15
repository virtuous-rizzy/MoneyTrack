import 'models.dart';

/// Versi tanpa database: semua data ditulis langsung di kode ini (hardcode).
/// Hanya untuk dibaca: tidak ada tambah, ubah, atau hapus data.
class TransactionRepository {
  TransactionRepository._() {
    _seed();
  }
  static final TransactionRepository instance = TransactionRepository._();

  // ====== DATA HARDCODE (ubah sesukamu di sini) ======
  final Account _account = const Account(
    id: 1,
    name: 'Rekening Utama',
    bank: 'BRI',
    openingBalance: 625000,
  );

  final Map<String, String> _settings = {
    'user_name': 'Sasa',
    'monthly_budget': '3000000',
  };

  final List<String> _tips = const [
    'Batasi jajan kopi dan utamakan pos kos & tabungan darurat sebelum akhir semester.',
    'Catat pengeluaran kecil setiap hari, karena jajan receh sering jadi bocoran terbesar.',
    'Sisihkan 10% uang bulanan di awal bulan sebelum dipakai untuk hal lain.',
    'Bawa bekal dua kali seminggu bisa menghemat cukup banyak dalam sebulan.',
  ];

  final List<TxCategory> _categories = [];
  final List<TransactionItem> _items = [];
  int _nextId = 1;

  void _seed() {
    void cat(String name, String icon, String type) {
      _categories.add(TxCategory(
        id: _nextId++,
        name: name,
        iconKey: icon,
        type: type,
      ));
    }

    cat('Makanan', 'food', 'expense');
    cat('Transport', 'bus', 'expense');
    cat('Pendidikan', 'school', 'expense');
    cat('Kos', 'home', 'expense');
    cat('Hiburan', 'movie', 'expense');
    cat('Lainnya', 'other', 'expense');
    cat('Kiriman', 'bank', 'income');
    cat('Beasiswa', 'award', 'income');
    cat('Freelance', 'work', 'income');
    cat('Lainnya', 'other', 'income');

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1, 8);
    DateTime ago(Duration d) {
      final t = now.subtract(d);
      return t.isBefore(monthStart) ? monthStart.add(const Duration(hours: 2)) : t;
    }

    void tx(String title, int amount, String type, String category,
        String method, DateTime at) {
      final c = _categories.firstWhere((c) => c.name == category && c.type == type);
      _items.add(TransactionItem(
        id: _nextId++,
        title: title,
        amount: amount,
        type: type,
        categoryId: c.id,
        categoryName: c.name,
        iconKey: c.iconKey,
        method: method,
        createdAt: at,
      ));
    }

    // Pemasukan bulan ini (total Rp3.000.000)
    tx('Kiriman Ortu Bulanan', 1500000, 'income', 'Kiriman', 'Transfer Masuk', monthStart);
    tx('Beasiswa Prestasi', 1000000, 'income', 'Beasiswa', 'Transfer Masuk',
        monthStart.add(const Duration(hours: 1)));
    tx('Proyek Desain Logo', 500000, 'income', 'Freelance', 'Transfer Masuk',
        monthStart.add(const Duration(hours: 2)));

    // Pengeluaran bulan ini (total Rp550.000)
    tx('Ayam Geprek', 45000, 'expense', 'Makanan', 'QRIS BRI', ago(const Duration(hours: 1)));
    tx('Bensin', 25000, 'expense', 'Transport', 'Oopay', ago(const Duration(hours: 5)));
    tx('Fotokopi', 35000, 'expense', 'Pendidikan', 'Tunai', ago(const Duration(days: 1, hours: 2)));
    tx('Bayar Tagihan Listrik', 120000, 'expense', 'Kos', 'PLN Token',
        ago(const Duration(days: 2, hours: 1)));
    tx('Nonton Bioskop', 50000, 'expense', 'Hiburan', 'QRIS BRI',
        ago(const Duration(days: 3, hours: 3)));
    tx('Kuota Internet', 75000, 'expense', 'Lainnya', 'Oopay',
        ago(const Duration(days: 4, hours: 2)));
    tx('Bayar Kos', 175000, 'expense', 'Kos', 'Transfer',
        ago(const Duration(days: 5, hours: 1)));
    tx('Kantin Kampus', 25000, 'expense', 'Makanan', 'QRIS BRI',
        ago(const Duration(days: 6, hours: 4)));

    // Bulan lalu (supaya muncul label "hemat 12%" di History)
    tx('Bayar Kos Bulan Lalu', 625000, 'expense', 'Kos', 'Transfer',
        DateTime(now.year, now.month - 1, 15, 10));
  }

  // ---------- Pengaturan ----------
  Future<String> setting(String key, {String fallback = ''}) async =>
      _settings[key] ?? fallback;

  Future<String> tipOfTheWeek() async {
    if (_tips.isEmpty) return '';
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _tips[(dayOfYear ~/ 7) % _tips.length];
  }

  // ---------- Rekening ----------
  Future<Account> mainAccount() async => _account;

  Future<int> balanceOf(Account account) async {
    var sum = account.openingBalance;
    for (final t in _items) {
      sum += t.isIncome ? t.amount : -t.amount;
    }
    return sum;
  }

  // ---------- Kategori ----------
  Future<List<TxCategory>> categories(String type) async =>
      _categories.where((c) => c.type == type).toList();

  // ---------- Transaksi ----------
  List<TransactionItem> _sorted(Iterable<TransactionItem> src) {
    final list = src.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  bool _inMonth(DateTime d, DateTime month) =>
      d.year == month.year && d.month == month.month;

  Future<List<TransactionItem>> recent({int limit = 3}) async =>
      _sorted(_items).take(limit).toList();

  Future<List<TransactionItem>> history({
    String? type,
    DateTime? month,
    String query = '',
  }) async {
    final q = query.trim().toLowerCase();
    return _sorted(_items.where((t) {
      if (type != null && t.type != type) return false;
      if (month != null && !_inMonth(t.createdAt, month)) return false;
      if (q.isNotEmpty &&
          !t.title.toLowerCase().contains(q) &&
          !t.categoryName.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }));
  }

  /// Total pemasukan & pengeluaran. [month] kosong = semua waktu.
  Future<Totals> totals({DateTime? month}) async {
    var income = 0, expense = 0, incomeCount = 0, expenseCount = 0;
    for (final t in _items) {
      if (month != null && !_inMonth(t.createdAt, month)) continue;
      if (t.isIncome) {
        income += t.amount;
        incomeCount++;
      } else {
        expense += t.amount;
        expenseCount++;
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
