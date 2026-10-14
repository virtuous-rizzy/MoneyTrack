import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 70, 181, 229)),
      ),
      home: const DataMahasiswaPage(),
    ),
  );
}

class DataMahasiswaPage extends StatefulWidget {
  const DataMahasiswaPage({super.key});

  @override
  State<DataMahasiswaPage> createState() => _DataMahasiswaPageState();
}

class _DataMahasiswaPageState extends State<DataMahasiswaPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nimController = TextEditingController();

  String namaMahasiswa = '';
  String nimMahasiswa = '';

  void simpanData() {
    setState(() {
      namaMahasiswa = namaController.text;
      nimMahasiswa = nimController.text;
    });
  }

  @override
  void dispose() {
    namaController.dispose();
    nimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: warna.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
        backgroundColor: warna.primary,
        foregroundColor: warna.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: 'Nama Mahasiswa',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: warna.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nimController,
              decoration: InputDecoration(
                labelText: 'NIM',
                prefixIcon: const Icon(Icons.badge_outlined),
                filled: true,
                fillColor: warna.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: simpanData,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Simpan Data'),
            ),
            const SizedBox(height: 28),
            Card(
              color: warna.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Tersimpan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Nama: $namaMahasiswa'),
                    const SizedBox(height: 4),
                    Text('NIM: $nimMahasiswa'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}