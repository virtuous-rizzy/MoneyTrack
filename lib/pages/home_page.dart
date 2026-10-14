import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../data/models.dart';
import '../data/transaction_repository.dart';
import '../widgets/app_header.dart';
import '../widgets/transaction_tile.dart';
import 'main_shell.dart';

class _HomeData {
  final Account account;
  final int balance;
  final Totals totals;
  final List<TransactionItem> recent;
  final String userName;
  final int budget;
  final String tip;

  const _HomeData({
    required this.account,
    required this.balance,
    required this.totals,
    required this.recent,
    required this.userName,
    required this.budget,
    required this.tip,
  });
}

class HomePage extends StatefulWidget {
  final VoidCallback onSeeAll;
  const HomePage({super.key, required this.onSeeAll});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo = TransactionRepository.instance;
  _HomeData? _data;
  bool _hidden = false;

  @override
  void initState() {
    super.initState();
    _repo.changes.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    _repo.changes.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    final account = await _repo.mainAccount();
    final data = _HomeData(
      account: account,
      balance: await _repo.balanceOf(account),
      totals: await _repo.totals(month: DateTime.now()),
      recent: await _repo.recent(limit: 3),
      userName: await _repo.setting('user_name', fallback: 'Teman'),
      budget: int.tryParse(await _repo.setting('monthly_budget')) ?? 0,
      tip: await _repo.tipOfTheWeek(),
    );
    if (!mounted) return;
    setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return SafeArea(
      child: d == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const AppHeader(title: 'Home'),
                const SizedBox(height: 18),
                _greeting(d),
                const SizedBox(height: 14),
                _balanceCard(d),
                const SizedBox(height: 12),
                _quickAddButton(),
                const SizedBox(height: 12),
                _summaryRow(d),
                const SizedBox(height: 12),
                _tipCard(d),
                const SizedBox(height: 20),
                _recentHeader(d),
                const SizedBox(height: 10),
                if (d.recent.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('Belum ada transaksi',
                          style: TextStyle(color: AppColors.muted)),
                    ),
                  ),
                for (final t in d.recent) ...[
                  TransactionTile(
                    item: t,
                    timeLabel:
                        '${relativeDay(t.createdAt)}, ${hourMinute(t.createdAt)}',
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }

  Widget _greeting(_HomeData d) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ringkasan Bulan',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text('Halo, ${d.userName}! 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 13),
              const SizedBox(width: 6),
              Text(monthYear(DateTime.now()),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _balanceCard(_HomeData d) {
    final amount = _hidden ? 'Rp ••••••' : rupiah(d.balance);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        color: AppColors.balanceCard,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                width: 170,
                height: 170,
                decoration: const BoxDecoration(
                  color: AppColors.balanceCircle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Saldo Aktif',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.muted)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: AppColors.income,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text('${d.account.name} • ${d.account.bank}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(amount,
                        style: const TextStyle(
                            fontSize: 34, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_user_outlined,
                              size: 14, color: AppColors.muted),
                          SizedBox(width: 5),
                          Text('FinTrack Sinkron Aman',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _hidden = !_hidden),
                        child: Row(
                          children: [
                            Icon(
                                _hidden
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 14,
                                color: AppColors.muted),
                            const SizedBox(width: 5),
                            Text(_hidden ? 'Tampilkan' : 'Sembunyikan',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAddButton() {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openAddTransaction(context),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 20),
              SizedBox(width: 8),
              Text('Catat Transaksi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(_HomeData d) {
    final pct =
        d.budget > 0 ? (d.totals.expense * 100 / d.budget).round() : 0;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            color: AppColors.beige,
            title: 'Pemasukan',
            amount: signedRupiah(d.totals.income, income: true),
            sub: 'Bulan ini',
            icon: Icons.arrow_downward,
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            color: AppColors.accentSoft,
            title: 'Pengeluaran',
            amount: signedRupiah(d.totals.expense, income: false),
            sub: '$pct% batas bulanan',
            icon: Icons.arrow_upward,
            iconColor: AppColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _tipCard(_HomeData d) {
    if (d.tip.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                color: AppColors.accentSoft, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_outline, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tips Hemat Minggu Ini',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('FinCare',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(d.tip,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentHeader(_HomeData d) {
    return Row(
      children: [
        const Text('Transaksi Terakhir',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        if (d.recent.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.beige,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${d.recent.length} baru',
                style: const TextStyle(fontSize: 10)),
          ),
        const Spacer(),
        GestureDetector(
          onTap: widget.onSeeAll,
          child: const Row(
            children: [
              Text('Lihat Semua', style: TextStyle(fontSize: 12)),
              Icon(Icons.chevron_right, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Color color;
  final String title;
  final String amount;
  final String sub;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.color,
    required this.title,
    required this.amount,
    required this.sub,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: iconColor, width: 0.8),
                ),
                child: Icon(icon, size: 12, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}
