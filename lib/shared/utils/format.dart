/// Format angka ke Rupiah sederhana, mis. 12500000 → "Rp 12.500.000".
String formatRupiah(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
  }
  return '${value < 0 ? '-' : ''}Rp $buffer';
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Jam saja, mis. "08.42".
String formatTime(DateTime dt) => '${_two(dt.hour)}.${_two(dt.minute)}';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu',
  'Sep', 'Okt', 'Nov', 'Des'];

/// Tanggal pendek, mis. "31 Des 2026".
String formatDate(DateTime dt) => '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

/// Tanggal & jam, mis. "12/10/2026 08.42".
String formatDateTime(DateTime dt) =>
    '${_two(dt.day)}/${_two(dt.month)}/${dt.year} ${formatTime(dt)}';

/// Jarak, mis. "18 m" atau "1,2 km". null (GPS belum ada) → "– m".
String formatDistance(double? meters) {
  if (meters == null) return '– m';
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}
