import 'package:google_stock_elman/google_stock_elman.dart';
import 'package:test/test.dart';

void main() {
  test('scales and restores each column independently', () {
    final scaler = MinMaxScaler.fit([
      [10, 100],
      [20, 300],
    ]);
    expect(scaler.transform([15, 200]), [0.5, 0.5]);
    expect(scaler.inverseTransform([0.5, 0.5]), [15, 200]);
  });

  test('maps a constant column to zero', () {
    final scaler = MinMaxScaler.fit([
      [4],
      [4],
    ]);
    expect(scaler.transform([4]), [0]);
    expect(scaler.inverseTransform([0]), [4]);
  });
}
