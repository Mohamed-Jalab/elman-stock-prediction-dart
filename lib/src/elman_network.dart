import 'dart:math';

enum Activation {
  tanh,
  sigmoid,
  relu,
  linear;

  double apply(double value) => switch (this) {
        Activation.tanh => _tanh(value),
        Activation.sigmoid => 1 / (1 + exp(-value)),
        Activation.relu => max(0, value),
        Activation.linear => value,
      };

  double derivativeFromOutput(double output) => switch (this) {
        Activation.tanh => 1 - output * output,
        Activation.sigmoid => output * (1 - output),
        Activation.relu => output > 0 ? 1 : 0,
        Activation.linear => 1,
      };
}

double _tanh(double value) {
  if (value > 20) return 1;
  if (value < -20) return -1;
  final exponent = exp(2 * value);
  return (exponent - 1) / (exponent + 1);
}

/// A single-hidden-layer Elman recurrent neural network.
///
/// [trainStep] uses one-step truncated backpropagation through time. This is a
/// deliberate educational compromise: recurrent weights learn from the prior
/// state without retaining an unbounded history.
class ElmanNetwork {
  ElmanNetwork({
    required this.inputSize,
    required this.hiddenSize,
    this.outputSize = 1,
    this.learningRate = 0.01,
    this.hiddenActivation = Activation.tanh,
    this.outputActivation = Activation.linear,
    int seed = 42,
  })  : assert(inputSize > 0),
        assert(hiddenSize > 0),
        assert(outputSize > 0),
        assert(learningRate > 0),
        _random = Random(seed) {
    inputWeights = _matrix(hiddenSize, inputSize, inputSize);
    recurrentWeights = _matrix(hiddenSize, hiddenSize, hiddenSize);
    outputWeights = _matrix(outputSize, hiddenSize, hiddenSize);
    hiddenBias = List.filled(hiddenSize, 0);
    outputBias = List.filled(outputSize, 0);
    _state = List.filled(hiddenSize, 0);
  }

  final int inputSize;
  final int hiddenSize;
  final int outputSize;
  double learningRate;
  final Activation hiddenActivation;
  final Activation outputActivation;
  final Random _random;

  late final List<List<double>> inputWeights;
  late final List<List<double>> recurrentWeights;
  late final List<List<double>> outputWeights;
  late final List<double> hiddenBias;
  late final List<double> outputBias;
  late List<double> _state;

  List<double> get state => List.unmodifiable(_state);

  List<List<double>> _matrix(int rows, int columns, int fanIn) {
    final limit = sqrt(6 / (fanIn + rows));
    return List.generate(
      rows,
      (_) =>
          List.generate(columns, (_) => (_random.nextDouble() * 2 - 1) * limit),
    );
  }

  void resetState() => _state = List.filled(hiddenSize, 0);

  List<double> predict(List<double> input) {
    _validateLength('input', input, inputSize);
    final hidden = _hidden(input, _state);
    final output = _output(hidden);
    _state = hidden;
    return output;
  }

  /// Trains on one observation and returns its mean squared error.
  double trainStep(List<double> input, List<double> target) {
    _validateLength('input', input, inputSize);
    _validateLength('target', target, outputSize);
    final previousState = List<double>.from(_state);
    final hidden = _hidden(input, previousState);
    final output = _output(hidden);
    final outputDelta = List<double>.generate(outputSize, (index) {
      return (output[index] - target[index]) *
          outputActivation.derivativeFromOutput(output[index]);
    });
    final hiddenDelta = List<double>.generate(hiddenSize, (hiddenIndex) {
      var error = 0.0;
      for (var outputIndex = 0; outputIndex < outputSize; outputIndex++) {
        error +=
            outputWeights[outputIndex][hiddenIndex] * outputDelta[outputIndex];
      }
      return error * hiddenActivation.derivativeFromOutput(hidden[hiddenIndex]);
    });

    for (var outputIndex = 0; outputIndex < outputSize; outputIndex++) {
      for (var hiddenIndex = 0; hiddenIndex < hiddenSize; hiddenIndex++) {
        outputWeights[outputIndex][hiddenIndex] -=
            learningRate * outputDelta[outputIndex] * hidden[hiddenIndex];
      }
      outputBias[outputIndex] -= learningRate * outputDelta[outputIndex];
    }
    for (var hiddenIndex = 0; hiddenIndex < hiddenSize; hiddenIndex++) {
      for (var inputIndex = 0; inputIndex < inputSize; inputIndex++) {
        inputWeights[hiddenIndex][inputIndex] -=
            learningRate * hiddenDelta[hiddenIndex] * input[inputIndex];
      }
      for (var stateIndex = 0; stateIndex < hiddenSize; stateIndex++) {
        recurrentWeights[hiddenIndex][stateIndex] -=
            learningRate * hiddenDelta[hiddenIndex] * previousState[stateIndex];
      }
      hiddenBias[hiddenIndex] -= learningRate * hiddenDelta[hiddenIndex];
    }

    _state = hidden;
    var squaredError = 0.0;
    for (var index = 0; index < outputSize; index++) {
      squaredError += pow(output[index] - target[index], 2).toDouble();
    }
    return squaredError / outputSize;
  }

  List<double> _hidden(List<double> input, List<double> previousState) {
    return List.generate(hiddenSize, (row) {
      var sum = hiddenBias[row];
      for (var column = 0; column < inputSize; column++) {
        sum += inputWeights[row][column] * input[column];
      }
      for (var column = 0; column < hiddenSize; column++) {
        sum += recurrentWeights[row][column] * previousState[column];
      }
      return hiddenActivation.apply(sum);
    });
  }

  List<double> _output(List<double> hidden) {
    return List.generate(outputSize, (row) {
      var sum = outputBias[row];
      for (var column = 0; column < hiddenSize; column++) {
        sum += outputWeights[row][column] * hidden[column];
      }
      return outputActivation.apply(sum);
    });
  }

  void _validateLength(String name, List<double> values, int expected) {
    if (values.length != expected) {
      throw ArgumentError.value(
        values.length,
        '$name.length',
        'Expected $expected values',
      );
    }
    if (values.any((value) => !value.isFinite)) {
      throw ArgumentError.value(values, name, 'Values must be finite');
    }
  }
}
