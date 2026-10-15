import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../core/category_icons.dart';
import '../core/formatters.dart';
import '../data/models.dart';
import '../data/transaction_repository.dart';
import '../widgets/app_header.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _repo = TransactionRepository.instance;
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();

  String _type = 'expense';
  List<TxCategory> _categories = [];
  int? _categoryId;
  DateTime _date = DateTime.now();
  Account? _account;
  int _balance = 0;

  int get _amount => parseAmount(_amountCtrl.text);

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = '45.000';
    _titleCtrl.text = 'Makan Siang Kantin';
    _loadAccount();
    _loadCategories();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    final account = await _repo.mainAccount();
    final balance = await _repo.balanceOf(account);
    if (!mounted) return;
    setState(() {
      _account = account;
      _balance = balance;
    });
  }

  Future<void> _loadCategories() async {
    final list = await _repo.categories(_type);
    if (!mounted) return;
    setState(() {
      _categories = list;
      _categoryId = list.isEmpty ? null : list.first.id;
    });
  }

  void _setType(String type) {
    if (_type == type) return;
    setState(() => _type = type);
    _loadCategories();
  }

  void _addToAmount(int value) {
    final text = groupThousands(_amount + value);
    _amountCtrl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const LogoBox(),
                  const SizedBox(width: 10),
                  const Text('Add Transaction',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const UserAvatar(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  _typeToggle(),
                  const SizedBox(height: 14),
                  _amountCard(),
                  const SizedBox(height: 16),
                  const Text('Keterangan / Nama Transaksi',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  _titleField(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pilih Kategori',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted)),
                      GestureDetector(
                        child: const Text('Kelola Kategori',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _categoryGrid(),
                  const SizedBox(height: 16),
                  _infoRow(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.accent.withOpacity(0.6),
                    disabledForegroundColor: AppColors.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Simpan Transaksi',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeToggle() {
    Widget seg(String value, String label, IconData icon) {
      final selected = _type == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => _setType(value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          seg('expense', 'Pengeluaran', Icons.arrow_downward),
          seg('income', 'Pemasukan', Icons.arrow_upward),
        ],
      ),
    );
  }

  Widget _amountCard() {
    const quick = [10000, 20000, 50000];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('NOMINAL TRANSAKSI',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.muted, letterSpacing: 0.5)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tagBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('● IDR', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Rp',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsInputFormatter(),
                  ],
                  style: const TextStyle(
                      fontSize: 34, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.border),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final v in quick)
                ActionChip(
                  label: Text('+${groupThousands(v)}',
                      style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.tagBg,
                  side: BorderSide.none,
                  onPressed: () => _addToAmount(v),
                ),
              ActionChip(
                label: const Text('Pas', style: TextStyle(fontSize: 11)),
                backgroundColor: AppColors.tagBg,
                side: BorderSide.none,
                onPressed: () => _amountCtrl.clear(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _titleField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note, size: 20, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Contoh: Makan siang kantin',
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.mic_none, size: 18, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _categoryGrid() {
    if (_categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: [
        for (final c in _categories)
          GestureDetector(
            onTap: () => setState(() => _categoryId = c.id),
            child: Container(
              decoration: BoxDecoration(
                color: _categoryId == c.id ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(categoryIcon(c.iconKey), size: 22),
                  const SizedBox(height: 6),
                  Text(c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _infoRow() {
    final isToday = sameDay(_date, DateTime.now());
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: _InfoCard(
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal',
              value: isToday ? 'Hari ini' : relativeDay(_date),
              sub: shortDate(_date),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Sumber Dana',
            value: _account == null ? '-' : '${_account!.bank} Utama',
            sub: 'Saldo: ${rupiah(_balance)}',
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}
