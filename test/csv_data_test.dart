import 'dart:io';

import 'package:google_stock_elman/google_stock_elman.dart';
import 'package:test/test.dart';

void main() {
  test('reads columns by name and handles quoted thousands separators', () {
    final directory = Directory.systemTemp.createTempSync('stock_csv_test_');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File('${directory.path}/prices.csv')
      ..writeAsStringSync(
        'Date,Open,High,Low,Close,Volume\n1/3/2017,778.81,789.63,775.8,786.14,"1,657,300"\n',
      );
    final record = readStockCsv(file.path).single;
    expect(record.open, 778.81);
    expect(record.close, 786.14);
    expect(record.volume, 1657300);
  });
}
