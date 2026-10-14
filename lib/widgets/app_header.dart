import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.primary,
      child: Icon(Icons.person_outline, size: 18, color: Colors.white),
    );
  }
}

class LogoBox extends StatelessWidget {
  const LogoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.account_balance_wallet_outlined,
          size: 18, color: AppColors.primary),
    );
  }
}

/// Header atas yang dipakai Home dan History.
class AppHeader extends StatelessWidget {
  final String title;
  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const LogoBox(),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        const Icon(Icons.notifications_none, size: 22),
        const SizedBox(width: 14),
        const UserAvatar(),
      ],
    );
  }
}
