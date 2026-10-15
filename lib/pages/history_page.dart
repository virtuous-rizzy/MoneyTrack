import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../data/models.dart';
import '../data/transaction_repository.dart';
import '../widgets/app_header.dart';
import '../widgets/transaction_tile.dart';

class _DayGroup {
  final DateTime date;
  final List<TransactionItem> items = [];
  _DayGroup(this.date);

  int get net =>
      items.fold(0, (sum, t) => sum + (t.isIncome ? t.amount : -t.amount));
}

class _HistoryData {
  final List<_DayGroup> groups;
  final Totals totals;
  final int? previousExpense; // null kalau tidak ada pembanding

  const _HistoryData(this.groups, this.totals, this.previousExpense);
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _repo = TransactionRepository.instance;
  final _searchCtrl = TextEditingController();

  String? _type; // null = semua
  DateTime? _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _searching = false;
  _HistoryData? _data;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final items = await _repo.history(
      type: _type,
      month: _month,
      query: _searchCtrl.text,
    );

    final groups = <_DayGroup>[];
    for (final t in items) {
      if (groups.isEmpty || !sameDay(groups.last.date, t.createdAt)) {
        groups.add(_DayGroup(t.createdAt));
      }
      groups.last.items.add(t);
    }

    final totals = await _repo.totals(month: _month);
    int? previous;
    if (_month != null) {
      final prev = await _repo.totals(
          month: DateTime(_month!.year, _month!.month - 1));
      previous = prev.expense;
    }

    if (!mounted) return;
    setState(() => _data = _HistoryData(groups, totals, previous));
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final options = List.generate(
        12, (i) => DateTime(now.year, now.month - i));

    final result = await showDialog<DateTime?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Pilih periode'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, DateTime(0)),
            child: const Text('Semua waktu'),
          ),
          for (final m in options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, m),
              child: Text(monthYear(m)),
            ),
        ],
      ),
    );

    if (result == null) return; // dialog ditutup tanpa memilih
    setState(() => _month = result.year == 0 ? null : result);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const AppHeader(title: 'History'),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text('Riwayat Transaksi',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searching = !_searching;
                    if (!_searching) _searchCtrl.clear();
                  });
                  if (!_searching) _reload();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      color: AppColors.beige, shape: BoxShape.circle),
                  child: Icon(_searching ? Icons.close : Icons.search, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Pantau seluruh arus kas masuk dan keluar secara terperinci.',
              style: TextStyle(fontSize: 13, color: AppColors.muted)),
          if (_searching) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (_) => _reload(),
              decoration: InputDecoration(
                hintText: 'Cari nama transaksi atau kategori',
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          _filters(),
          const SizedBox(height: 14),
          if (d == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _summaryCard(d),
            const SizedBox(height: 16),
            if (d.groups.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('Belum ada transaksi',
                      style: TextStyle(color: AppColors.muted)),
                ),
              ),
            for (final g in d.groups) ..._groupWidgets(g),
            if (d.groups.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    Icon(Icons.circle, size: 5, color: AppColors.border),
                    SizedBox(height: 6),
                    Text('Semua riwayat telah dimuat',
                        style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _filters() {
    Widget chip(String label, String? value) {
      final selected = _type == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () {
            setState(() => _type = value);
            _reload();
          },
          child: _chipBox(label, selected),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Semua', null),
          chip('Pemasukan', 'income'),
          chip('Pengeluaran', 'expense'),
          GestureDetector(
            onTap: _pickMonth,
            child: _chipBox(
              _month == null ? 'Semua waktu' : shortMonthYear(_month!),
              false,
              icon: Icons.calendar_today_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipBox(String label, bool selected, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.accent : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _summaryCard(_HistoryData d) {
    String? badge;
    final prev = d.previousExpense;
    if (prev != null && prev > 0) {
      final pct = ((prev - d.totals.expense).abs() * 100 / prev).round();
      badge = d.totals.expense <= prev ? 'hemat $pct%' : 'naik $pct%';
    }
    final saving = badge != null && badge.startsWith('hemat');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tagBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.trending_up, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_month == null ? 'Total Pengeluaran' : 'Pengeluaran Bulan ini',
                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(rupiah(d.totals.expense),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: saving ? AppColors.accentSoft : AppColors.beige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(badge,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  List<Widget> _groupWidgets(_DayGroup g) {
    final rel = relativeDay(g.date);
    final isRelative = rel == 'Hari ini' || rel == 'Kemarin';
    final net = g.net;

    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(
          children: [
            Text(isRelative ? rel : fullDate(g.date),
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            if (isRelative) ...[
              const SizedBox(width: 6),
              Text('• ${fullDate(g.date)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
            const Spacer(),
            Text(
              signedRupiah(net.abs(), income: net >= 0),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: net >= 0 ? AppColors.income : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
      for (final t in g.items) ...[
        TransactionTile(
          item: t,
          timeLabel: timeWib(t.createdAt),
        ),
        const SizedBox(height: 10),
      ],
      const SizedBox(height: 6),
    ];
  }
}
