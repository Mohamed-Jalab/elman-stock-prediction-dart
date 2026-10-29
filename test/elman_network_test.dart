import 'package:google_stock_elman/google_stock_elman.dart';
import 'package:test/test.dart';

void main() {
  group('ElmanNetwork', () {
    test('is deterministic for a fixed seed', () {
      final first = ElmanNetwork(inputSize: 2, hiddenSize: 3, seed: 7);
      final second = ElmanNetwork(inputSize: 2, hiddenSize: 3, seed: 7);
      expect(first.predict([0.2, 0.8]), second.predict([0.2, 0.8]));
    });

    test('recurrent state affects the next prediction', () {
      final network = ElmanNetwork(inputSize: 1, hiddenSize: 2, seed: 3);
      final first = network.predict([0.5]);
      expect(network.predict([0.5]), isNot(equals(first)));
      network.resetState();
      expect(network.predict([0.5]), first);
    });

    test('training reduces error on a small sequence', () {
      final network = ElmanNetwork(
        inputSize: 1,
        hiddenSize: 4,
        learningRate: 0.05,
        seed: 11,
      );
      const inputs = [0.0, 0.25, 0.5, 0.75, 1.0];
      double loss() {
        network.resetState();
        var total = 0.0;
        for (final value in inputs) {
          final error = network.predict([value]).single - value;
          total += error * error;
        }
        return total / inputs.length;
      }

      final before = loss();
      for (var epoch = 0; epoch < 400; epoch++) {
        network.resetState();
        for (final value in inputs) {
          network.trainStep([value], [value]);
        }
      }
      expect(loss(), lessThan(before * 0.2));
    });

    test('rejects input with the wrong width', () {
      final network = ElmanNetwork(inputSize: 2, hiddenSize: 2);
      expect(() => network.predict([1]), throwsArgumentError);
    });
  });
}
