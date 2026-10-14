import 'package:flutter/material.dart';

/// Database hanya menyimpan nama ikon (teks). Di sini nama itu diubah jadi ikon.
const Map<String, IconData> _icons = {
  'food': Icons.restaurant,
  'bus': Icons.directions_bus_outlined,
  'school': Icons.school_outlined,
  'home': Icons.home_outlined,
  'movie': Icons.movie_outlined,
  'other': Icons.grid_view_rounded,
  'bank': Icons.account_balance_outlined,
  'award': Icons.workspace_premium_outlined,
  'work': Icons.work_outline,
  'tag': Icons.label_outline,
};

IconData categoryIcon(String key) => _icons[key] ?? Icons.label_outline;
