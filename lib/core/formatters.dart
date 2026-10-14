import 'package:flutter/services.dart';

const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];
const _shortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// 1500000 -> "1.500.000"
String groupThousands(int value) {
  final s = value.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

/// 1500000 -> "Rp1.500.000"
String rupiah(int value) => '${value < 0 ? '-' : ''}Rp${groupThousands(value)}';

/// Dengan tanda + atau -
String signedRupiah(int value, {required bool income}) =>
    '${income ? '+' : '-'}Rp${groupThousands(value)}';

/// "Oktober 2026"
String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

/// "Okt 2026"
String shortMonthYear(DateTime d) => '${_shortMonths[d.month - 1]} ${d.year}';

/// "24 Oktober 2026"
String fullDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// "24 Okt 2026"
String shortDate(DateTime d) => '${d.day} ${_shortMonths[d.month - 1]} ${d.year}';

/// "12:30"
String hourMinute(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

/// "12:30 WIB"
String timeWib(DateTime d) => '${hourMinute(d)} WIB';

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "Hari ini", "Kemarin", atau "20 Okt"
String relativeDay(DateTime d) {
  final now = DateTime.now();
  if (sameDay(d, now)) return 'Hari ini';
  if (sameDay(d, now.subtract(const Duration(days: 1)))) return 'Kemarin';
  return '${d.day} ${_shortMonths[d.month - 1]}';
}

int parseAmount(String text) =>
    int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

/// Otomatis memberi titik ribuan saat mengetik nominal.
class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 12) digits = digits.substring(0, 12);
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final text = groupThousands(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
