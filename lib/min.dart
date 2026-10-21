import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DaftarMahasiswaPage(),
    );
  }
}

class Mahasiswa {
  final String nama;
  final String nim;
  final String jurusan;

  const Mahasiswa({
    required this.nama,
    required this.nim,
    required this.jurusan,
  });
}

class DaftarMahasiswaPage extends StatelessWidget {
  const DaftarMahasiswaPage({super.key});

  final List<Mahasiswa> daftarMahasiswa = const [
    Mahasiswa(nama: 'Ahmad Fauzi', nim: '220101001', jurusan: 'Teknik Informatika'),
    Mahasiswa(nama: 'Budi Santoso', nim: '220101002', jurusan: 'Sistem Informasi'),
    Mahasiswa(nama: 'Citra Dewi', nim: '220101003', jurusan: 'Teknik Informatika'),
    Mahasiswa(nama: 'Dinda Lestari', nim: '220101004', jurusan: 'Rekayasa Perangkat Lunak'),
    Mahasiswa(nama: 'Eko Prasetyo', nim: '220101005', jurusan: 'Teknik Komputer'),
    Mahasiswa(nama: 'Farhan Kurniawan', nim: '220101006', jurusan: 'Sistem Informasi'),
    Mahasiswa(nama: 'Gita Permata', nim: '220101007', jurusan: 'Teknik Informatika'),
    Mahasiswa(nama: 'Hendra Saputra', nim: '220101008', jurusan: 'Rekayasa Perangkat Lunak'),
    Mahasiswa(nama: 'Indah Cahyani', nim: '220101009', jurusan: 'Sistem Informasi'),
    Mahasiswa(nama: 'Joko Wicaksono', nim: '220101010', jurusan: 'Teknik Informatika'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 160.0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Daftar Mahasiswa',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade800,
                      Colors.indigo.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${daftarMahasiswa.length} Mahasiswa',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Chip(
                    avatar: Icon(Icons.group, size: 16),
                    label: Text('Kelas TI-2022'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final mhs = daftarMahasiswa[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(
                        mhs.nama,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${mhs.nim} • ${mhs.jurusan}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${mhs.nama} (${mhs.nim}) dipilih'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: daftarMahasiswa.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}