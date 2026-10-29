import 'dart:io';

class StockRecord {
  const StockRecord({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  List<double> get features => [open, high, low, close, volume];
}

/// Reads both bundled Google stock CSV layouts by header name.
List<StockRecord> readStockCsv(String path) {
  final lines = File(
    path,
  ).readAsLinesSync().where((line) => line.trim().isNotEmpty).toList();
  if (lines.length < 2) {
    throw FormatException('CSV contains no data rows: $path');
  }
  final headers = _splitCsvLine(
    lines.first,
  ).map((value) => value.toLowerCase()).toList();
  int column(String name) {
    final index = headers.indexOf(name);
    if (index < 0) {
      throw FormatException('Missing "$name" column in $path');
    }
    return index;
  }

  final indices = [
    'open',
    'high',
    'low',
    'close',
    'volume',
  ].map(column).toList();
  return [
    for (var index = 1; index < lines.length; index++)
      _record(lines[index], index + 1, path, indices),
  ];
}

StockRecord _record(
  String line,
  int lineNumber,
  String path,
  List<int> indices,
) {
  final fields = _splitCsvLine(line);
  double number(int index) {
    if (index >= fields.length) {
      throw FormatException('Missing field at $path:$lineNumber');
    }
    final parsed = double.tryParse(fields[index].replaceAll(',', '').trim());
    if (parsed == null) {
      throw FormatException(
        'Invalid number "${fields[index]}" at $path:$lineNumber',
      );
    }
    return parsed;
  }

  return StockRecord(
    open: number(indices[0]),
    high: number(indices[1]),
    low: number(indices[2]),
    close: number(indices[3]),
    volume: number(indices[4]),
  );
}

List<String> _splitCsvLine(String line) {
  final fields = <String>[];
  final buffer = StringBuffer();
  var quoted = false;
  for (var index = 0; index < line.length; index++) {
    final character = line[index];
    if (character == '"') {
      if (quoted && index + 1 < line.length && line[index + 1] == '"') {
        buffer.write('"');
        index++;
      } else {
        quoted = !quoted;
      }
    } else if (character == ',' && !quoted) {
      fields.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(character);
    }
  }
  if (quoted) throw FormatException('Unterminated quoted CSV field.');
  fields.add(buffer.toString());
  return fields;
}
