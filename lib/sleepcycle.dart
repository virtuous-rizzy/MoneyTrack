import 'package:flutter/material.dart';

void main() => runApp(const SleepCycleApp());

/// ================== MODEL ==================
/// Satu siklus tidur = 90 menit, + 14 menit rata-rata waktu buat mulai tidur.
const int menitPerSiklus = 90;
const int menitUntukTidur = 14;

class HasilSiklus {
  const HasilSiklus({
    required this.jumlahSiklus,
    required this.waktu,
    required this.label,
  });

  final int jumlahSiklus;
  final TimeOfDay waktu;
  final String label; // "Tidur jam" atau "Bangun jam"
}

/// ================== APP + ROUTING (named routes) ==================
class SleepCycleApp extends StatelessWidget {
  const SleepCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sleep Cycle Calculator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
      ),
      initialRoute: '/',
      // named routes via onGenerateRoute supaya bisa kirim argumen antar halaman
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomePage());
          case '/hasil':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => HasilPage(
                mode: args['mode'] as String,
                patokan: args['patokan'] as TimeOfDay,
              ),
            );
          case '/detail':
            final hasil = settings.arguments as HasilSiklus;
            return MaterialPageRoute(
              builder: (_) => DetailPage(hasil: hasil),
            );
          default:
            return MaterialPageRoute(builder: (_) => const HomePage());
        }
      },
    );
  }
}

/// ================== HALAMAN 1: INPUT ==================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String mode = 'tidur'; // 'tidur' = tidur sekarang, 'bangun' = pilih jam bangun
  TimeOfDay jamDipilih = TimeOfDay.now();

  Future<void> pilihJam() async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: jamDipilih,
    );
    if (hasil != null) {
      setState(() => jamDipilih = hasil);
    }
  }

  void hitung() {
    // push() dengan named route + kirim argumen
    Navigator.pushNamed(
      context,
      '/hasil',
      arguments: {'mode': mode, 'patokan': jamDipilih},
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Cycle Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.bedtime_rounded, size: 64, color: scheme.primary),
            const SizedBox(height: 12),
            const Text(
              'Hitung waktu tidur & bangun terbaikmu berdasarkan siklus tidur 90 menit.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Pilihan mode
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'tidur',
                  label: Text('Tidur Sekarang'),
                  icon: Icon(Icons.nightlight_round),
                ),
                ButtonSegment(
                  value: 'bangun',
                  label: Text('Pilih Jam Bangun'),
                  icon: Icon(Icons.alarm),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (s) => setState(() => mode = s.first),
            ),
            const SizedBox(height: 20),

            if (mode == 'bangun') ...[
              Text(
                'Jam bangun: ${jamDipilih.format(context)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: pilihJam,
                icon: const Icon(Icons.access_time),
                label: const Text('Pilih Jam'),
              ),
              const SizedBox(height: 20),
            ],

            FilledButton(
              onPressed: hitung,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Hitung'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================== HALAMAN 2: HASIL (ListView + GridView) ==================
class HasilPage extends StatelessWidget {
  const HasilPage({super.key, required this.mode, required this.patokan});

  final String mode;
  final TimeOfDay patokan;

  List<HasilSiklus> _hitungSiklus() {
    final sekarang = DateTime.now();
    final patokanDateTime = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day,
      patokan.hour,
      patokan.minute,
    );

    final List<HasilSiklus> daftar = [];
    for (int siklus = 6; siklus >= 3; siklus--) {
      final totalMenit = siklus * menitPerSiklus + menitUntukTidur;
      final waktuHasil = mode == 'tidur'
          ? patokanDateTime.add(Duration(minutes: totalMenit))
          : patokanDateTime.subtract(Duration(minutes: totalMenit));

      daftar.add(
        HasilSiklus(
          jumlahSiklus: siklus,
          waktu: TimeOfDay.fromDateTime(waktuHasil),
          label: mode == 'tidur' ? 'Bangun jam' : 'Tidur jam',
        ),
      );
    }
    return daftar;
  }

  @override
  Widget build(BuildContext context) {
    final daftarHasil = _hitungSiklus();

    const tips = [
      ('Hindari Kafein', Icons.local_cafe_outlined),
      ('Redupkan Lampu', Icons.lightbulb_outline),
      ('Jauhkan HP', Icons.phonelink_off_outlined),
      ('Suhu Sejuk', Icons.ac_unit_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Rekomendasi Waktu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            mode == 'tidur'
                ? 'Kalau kamu tidur sekarang, bangunlah di salah satu jam ini:'
                : 'Supaya bangun jam ${patokan.format(context)}, tidurlah di salah satu jam ini:',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 12),

          // ---- ListView (scrollable list daftar siklus) ----
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daftarHasil.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = daftarHasil[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${item.jumlahSiklus}'),
                  ),
                  title: Text('${item.label} ${item.waktu.format(context)}'),
                  subtitle: Text('${item.jumlahSiklus} siklus tidur'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // push() ke halaman detail
                    Navigator.pushNamed(context, '/detail', arguments: item);
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 28),
          const Text(
            'Tips Tidur Lebih Nyenyak',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // ---- GridView (daftar tips) ----
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tips.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final (judul, ikon) = tips[index];
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(ikon, size: 28),
                    const SizedBox(height: 8),
                    Text(judul, textAlign: TextAlign.center),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ================== HALAMAN 3: DETAIL ==================
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.hasil});

  final HasilSiklus hasil;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalJam = (hasil.jumlahSiklus * menitPerSiklus) / 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Siklus')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.nights_stay_rounded, size: 72, color: scheme.primary),
              const SizedBox(height: 16),
              Text(
                '${hasil.label} ${hasil.waktu.format(context)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('${hasil.jumlahSiklus} siklus tidur (±${totalJam.toStringAsFixed(1)} jam)'),
              const SizedBox(height: 28),
              FilledButton(
                // pop() kembali ke halaman hasil
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}