List<String> cleanStringList(List<String> items) {
  return items.map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
}

String formatBoolValue(bool? value) {
  if (value == null) return '–';
  return value ? 'Да' : 'Нет';
}

String formatPaymentDate(int? value) {
  if (value == null) return '–';
  if (value <= 31) return '$value число';
  final month = value ~/ 100;
  final day = value % 100;
  return '$day/$month';
}

String formatPaymentDates(List<int> values) {
  if (values.isEmpty) return '–';
  if (values.length == 1) return formatPaymentDate(values.first);

  final sorted = List<int>.from(values)..sort();
  return sorted.map(formatPaymentDate).join('; ');
}
