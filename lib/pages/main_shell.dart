import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'add_transaction_page.dart';
import 'history_page.dart';
import 'home_page.dart';

void openAddTransaction(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const AddTransactionPage()),
  );
}

/// Kerangka utama: Home + History dengan menu bawah dan tombol (+) di tengah.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(onSeeAll: () => setState(() => _index = 1)),
          const HistoryPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Home',
                    active: _index == 0,
                    onTap: () => setState(() => _index = 0),
                  ),
                ),
                GestureDetector(
                  onTap: () => openAddTransaction(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: AppColors.primary),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'History',
                    active: _index == 1,
                    onTap: () => setState(() => _index = 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.muted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
