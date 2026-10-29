import 'dart:math';

import 'package:google_stock_elman/google_stock_elman.dart';

void main(List<String> arguments) {
  final epochs = arguments.isEmpty ? 200 : int.tryParse(arguments.first);
  if (epochs == null || epochs <= 0) {
    throw ArgumentError('Epochs must be a positive integer.');
  }

  final records = readStockCsv('data/Google_Stock_Price_Train.csv');
  final examples = <({List<double> input, double target})>[
    for (var index = 0; index < records.length - 1; index++)
      (input: records[index].features, target: records[index + 1].close),
  ];
  final split = (examples.length * 0.8).floor();
  final training = examples.sublist(0, split);
  final validation = examples.sublist(split);
  final featureScaler = MinMaxScaler.fit([
    for (final item in training) item.input,
  ]);
  final targetScaler = MinMaxScaler.fit([
    for (final item in training) [item.target],
  ]);
  final network = ElmanNetwork(
    inputSize: 5,
    hiddenSize: 12,
    learningRate: 0.01,
    seed: 42,
  );

  for (var epoch = 1; epoch <= epochs; epoch++) {
    network.resetState();
    var loss = 0.0;
    for (final item in training) {
      loss += network.trainStep(
        featureScaler.transform(item.input),
        targetScaler.transform([item.target]),
      );
    }
    if (epoch == 1 || epoch % 20 == 0 || epoch == epochs) {
      final rmse = _evaluate(network, validation, featureScaler, targetScaler);
      print(
        'Epoch ${epoch.toString().padLeft(4)} | train MSE ${(loss / training.length).toStringAsFixed(6)} | validation RMSE ${rmse.toStringAsFixed(2)}',
      );
    }
  }
}

double _evaluate(
  ElmanNetwork network,
  List<({List<double> input, double target})> examples,
  MinMaxScaler featureScaler,
  MinMaxScaler targetScaler,
) {
  network.resetState();
  var squaredError = 0.0;
  for (final item in examples) {
    final scaled = network.predict(featureScaler.transform(item.input));
    final prediction = targetScaler.inverseTransform(scaled).single;
    squaredError += pow(prediction - item.target, 2).toDouble();
  }
  return sqrt(squaredError / examples.length);
}
