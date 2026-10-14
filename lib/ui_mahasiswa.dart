import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ProfilMahasiswaPage(),
    ),
  );
}

class ProfilMahasiswaPage extends StatelessWidget {
  const ProfilMahasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 340,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. STACK -> Header profil (foto + nama + program studi)
                  const _HeaderProfil(
                    nama: 'Muhammad Rizky Akbar',
                    prodi: 'Ilmu Komputer',
                  ),

                  // 2. ROW + EXPANDED -> Menu (Mata Kuliah & Nilai)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MenuItem(
                            icon: Icons.menu_book_rounded,
                            label: 'Mata Kuliah',
                            iconColor: Colors.orange,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _MenuItem(
                            icon: Icons.bar_chart_rounded,
                            label: 'Nilai',
                            iconColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. COLUMN -> Daftar informasi
                  const _InfoTile(
                    icon: Icons.email_rounded,
                    iconColor: Colors.orange,
                    label: 'Email',
                    value: 'r.akbar0077@gmail.com',
                  ),
                  const _InfoTile(
                    icon: Icons.badge_rounded,
                    iconColor: Colors.deepPurple,
                    label: 'NIM',
                    value: '2411016310005',
                  ),
                  const _InfoTile(
                    icon: Icons.school_rounded,
                    iconColor: Colors.teal,
                    label: 'Program Studi',
                    value: 'Ilmu Komputer',
                    showDivider: false,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// STACK: foto profil ditumpuk di atas background oren + nama + prodi
class _HeaderProfil extends StatelessWidget {
  const _HeaderProfil({required this.nama, required this.prodi});

  final String nama;
  final String prodi;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background oren
          Container(
            height: 190,
            width: double.infinity,
            color: const Color(0xFFF97316),
          ),
          // Isi: foto, nama, prodi
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/Akbar.jpeg'),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  prodi,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak menu tunggal, dipakai di dalam ROW + EXPANDED
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withValues(alpha: 0.15),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Satu baris informasi, dipakai berulang di dalam COLUMN
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: iconColor.withValues(alpha: 0.15),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
