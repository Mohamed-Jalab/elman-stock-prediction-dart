import 'dart:io';
import 'dart:math';

import 'dataset_manager.dart';
import 'neuron.dart';

List<List<Object>> trainingSetFeatures = [];
List<List<Object>> testSetFeatures = [];
List<Object> trainingSetOutput = [], testSetOutput = [];
double accuracy = 0;
double accuracy1 = 0;
List<List<double>> weightsAndBias = [];
void main() {
  List<String> csvFile = File("heart.csv").readAsStringSync().split("\n");
  print(csvFile.length);
  print("remove : ${csvFile.removeAt(0)}"); //? remove the headers
  csvFile.shuffle();
  // csvFile.shuffle();
  // csvFile.shuffle();
  print(csvFile.length);
  List<List<Object>> csvProcessed =
      DatasetManager.createDataset(csvFile, logProcess: true);
  // csvProcessed.shuffle();
  // csvProcessed[0] = DatasetManager.normalize(csvProcessed[0] as List<int>);
  // print(csvProcessed[0]);
  //? create dataset
  //? ---------------------
  //? includes output in last element of each row

  //? each row means single feature
  trainingSetFeatures = [];
  testSetFeatures = [];
  for (final List<Object> row in csvProcessed) {
    print(row.sublist(0, 20));
    trainingSetFeatures.add(row.sublist(0, 730));
    testSetFeatures.add(row.sublist(730));
  }
  trainingSetOutput = trainingSetFeatures.removeAt(11);
  testSetOutput = testSetFeatures.removeAt(11);

  print(csvFile.length);
  print(trainingSetFeatures.first.length + testSetFeatures.first.length);
  print(trainingSetOutput.length);

  List<double> inputs = [];
  for (final List<Object> sample in trainingSetFeatures)
    inputs.add(double.parse(sample.first.toString()));
  print(inputs);
  double output = double.parse(trainingSetOutput.first.toString());
  NeuralNetwork network = NeuralNetwork(
      learningRate: .6,
      inputValues: inputs,
      outputValue: output,
      neuronsOfEachLayer: const [11, 1],
      activations: const ["sigmoid", "sigmoid"]);
  trainNetwork(network: network, epoch: 30000);
  // mytest(network);
}

void trainNetwork(
    {int epoch = 10,
    required NeuralNetwork network,
    double changingLearningRate = .9}) {
  int trainAccuracy = 0;
  double trainMeanSquareError = 0;
  int testAccuracy = 0;
  double testMeanSquareError = 0;

  //! training
  // number of epoch
  for (int i = 0; i < epoch; i++) {
    trainAccuracy = 0;
    testAccuracy = 0;
    trainMeanSquareError = 0;
    testMeanSquareError = 0;
    // number of samples
    for (int j = 0; j < trainingSetFeatures.first.length; j++) {
      // number of features
      for (int k = 0; k < trainingSetFeatures.length; k++)
        network.inputs[k] = InputNeuron(
            value: double.parse(trainingSetFeatures[k][j].toString()));
      network.desiredOutput = double.parse(trainingSetOutput[j].toString());
      // print(network.inputs);
      // print(network.desiredOutput);
      // print(" should be ==> ${network.desiredOutput}");

      double actualOutput = network.feedForward as double;

      if (actualOutput.round().toDouble() == network.desiredOutput)
        trainAccuracy++;
      trainMeanSquareError +=
          pow((network.desiredOutput - actualOutput), 2).toDouble();

      network.backPropagation;
    }
    if (i == (trainingSetFeatures[0].length * .1).toInt()) {
      network.learningRate *= changingLearningRate;
    }
    //! testing
    for (int j = 0; j < testSetFeatures.first.length; j++) {
      // number of features
      for (int k = 0; k < testSetFeatures.length; k++)
        network.inputs[k] =
            InputNeuron(value: double.parse(testSetFeatures[k][j].toString()));
      network.desiredOutput = double.parse(testSetOutput[j].toString());

      // print("${network.feedForward} should be ==> ${network.desiredOutput}");

      double actualOutput = network.feedForward as double;

      if (actualOutput.round().toDouble() == network.desiredOutput)
        testAccuracy++;
      testMeanSquareError +=
          pow((network.desiredOutput - actualOutput), 2).toDouble();
    }
    // print(testAccuracy);
    // print(testAccuracy / testSetFeatures.first.length > accuracy);
    if (trainAccuracy / trainingSetFeatures.first.length > accuracy &&
        testAccuracy / testSetFeatures.first.length > accuracy1) {
      saveWeights(network);
      accuracy = trainAccuracy / trainingSetFeatures.first.length;
      accuracy1 = testAccuracy / testSetFeatures.first.length;
      // weightsAndBias.clear();
      // for (final Layer layer in network.layers) {
      //   weightsAndBias.add([]);
      //   for (final Neuron neuron in layer.neurons) {
      //     for (final double weight in neuron.weights)
      //       weightsAndBias.last.add(weight);
      //     weightsAndBias.last.add(neuron.bias);
      //   }
      // }
    }
    print(
        "Epoch $i Training => accuracy: ${trainAccuracy / trainingSetFeatures.first.length}  loss: ${trainMeanSquareError / trainingSetFeatures.first.length}   |   Test => accuracy: ${testAccuracy / testSetFeatures.first.length}  loss: ${testMeanSquareError / testSetFeatures.first.length}");
  }
}

void mytest(NeuralNetwork network) {
  //! training
  // number of epoch
  for (int i = 0; i < 10000; i++) {
    int accucary = 0;
    double loss = 0;
    // number of samples
    for (int j = 0; j < trainingSetFeatures[0].length; j++) {
      // number of features
      for (int k = 0; k < trainingSetFeatures.length; k++)
        network.inputs[k] = InputNeuron(
            value: double.parse(trainingSetFeatures[k][j].toString()));
      network.desiredOutput = double.parse(trainingSetOutput[j].toString());
      // print(network.inputs);
      // print(network.desiredOutput);
      double actualOutput = network.feedForward as double;
      if (j % 100 == 0)
        print("${actualOutput} should be ==> ${network.desiredOutput}");
      if (network.desiredOutput == actualOutput.round().toDouble()) accucary++;
      loss += pow((network.desiredOutput - actualOutput), 2);
      // if(double.parse(network.feedForward.toString()).round() > )
      network.backPropagation;
      // print(network.backPropagation);
    }

    print("train accucary : ${accucary / trainingSetFeatures.first.length}");
    print("train loss : ${loss / trainingSetFeatures.first.length}");
    accucary = 0;
    loss = 0;
    //! testing
    for (int j = 0; j < 100; j++) {
      // number of features
      for (int k = 0; k < trainingSetFeatures.length; k++)
        network.inputs[k] =
            InputNeuron(value: double.parse(testSetFeatures[k][j].toString()));
      network.desiredOutput = double.parse(testSetOutput[j].toString());

      double actualOutput = network.feedForward as double;
      if (j % 100 == 0)
        print("${actualOutput} should be ==> ${network.desiredOutput}");
      if (network.desiredOutput == actualOutput.round().toDouble()) accucary++;
      loss += pow((network.desiredOutput - actualOutput), 2);
      // print("${network.feedForward} should be ==> ${network.desiredOutput}");
    }
    print("test accucary : ${accucary / 100}");
    print("test loss : ${loss / 100}");
    print("Epoch $i");
  }
}

void saveWeights(NeuralNetwork network) {
  File file = File(
      "weights_${network.layers.first.neurons.length}_${network.layers.last.neurons.length}.mohammed");
  IOSink sink = file.openWrite();
  for (int i = 0; i < network.layers.length; i++) {
    for (int j = 0; j < network.layers[i].neurons.length; j++) {
      for (final double weight in network.layers[i].neurons[j].weights)
        sink.write("$weight ");
      sink.write(network.layers[i].neurons[j].bias.toString());
      sink.write("||");
    }
    if (i != network.layers.length - 1) sink.write("\n");
  }
  sink.close();
}













// List<double> inputs = [1, 1];
  // double output = 0;
  // NeuralNetwork network = NeuralNetwork(
  //     inputValues: inputs,
  //     outputValue: output,
  //     neuronsOfEachLayer: [2, 1],
  //     activations: ["sigmoid", "sigmoid"]);
  // network.layers[0].neurons[0].weights[0] = 0.5;
  // network.layers[0].neurons[0].weights[1] = 0.4;
  // network.layers[0].neurons[0].weights[2] = 0.8;
  // network.layers[0].neurons[0].bias = -1.0;

  // network.layers[0].neurons[1].weights[0] = 0.9;
  // network.layers[0].neurons[1].weights[1] = 1.0;
  // network.layers[0].neurons[1].weights[2] = -0.1;
  // network.layers[0].neurons[1].bias = -1.0;

  // network.layers[1].neurons[0].weights[0] = -1.2;
  // network.layers[1].neurons[0].weights[1] = 1.1;
  // network.layers[1].neurons[0].weights[2] = 0.3;
  // network.layers[1].neurons[0].bias = -1.0;

  // print(network.feedForward);
  // network.backPropagation;

  // for (var i = 0; i < 100000; i++) {
  //   network.inputs[0] = InputNeuron(value: 1);
  //   network.inputs[1] = InputNeuron(value: 0);
  //   network.desiredOutput = 1;

  //   print(network.feedForward);
  //   network.backPropagation;

  //   network.inputs[0] = InputNeuron(value: 0);
  //   network.inputs[1] = InputNeuron(value: 1);
  //   network.desiredOutput = 1;

  //   print(network.feedForward);
  //   network.backPropagation;

  //   network.inputs[0] = InputNeuron(value: 1);
  //   network.inputs[1] = InputNeuron(value: 1);
  //   network.desiredOutput = 0;

  //   print(network.feedForward);
  //   network.backPropagation;

  //   network.inputs[0] = InputNeuron(value: 0);
  //   network.inputs[1] = InputNeuron(value: 0);
  //   network.desiredOutput = 0;

  //   print(network.feedForward);
  //   network.backPropagation;
  // }