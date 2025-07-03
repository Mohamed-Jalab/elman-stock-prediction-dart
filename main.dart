import 'dart:io';
import 'dart:math';

import 'dataset_manager.dart';
import 'neuron.dart';

List<List<Object>> trainingSetFeatures = [];
List<List<Object>> testSetFeatures = [];
List<Object> trainingSetOutput = [], testSetOutput = [];
void main() {
  int accuracy = 0;

  List<String> csvFile =
      File("Google_Stock_Price_Train.csv").readAsStringSync().split("\n");
  print(csvFile.length);
  print("remove : ${csvFile.removeAt(0)}"); //? remove the headers
  print(
      "remove : ${csvFile.removeAt(csvFile.length - 1)}"); //? remove the headers
  // csvFile.shuffle();
  print(csvFile.length);
  List<List<Object>> csvProcessed =
      DatasetManager.createDataset(csvFile, logProcess: true);

  //? create dataset
  //? ---------------------
  //? includes output in last element of each row
  //? each row means single feature
  trainingSetFeatures = [];
  testSetFeatures = [];
  for (final List<Object> row in csvProcessed) {
    // print(row.sublist(0, 20));
    trainingSetFeatures.add(row.sublist(0, 1000));
    testSetFeatures.add(row.sublist(1000));
  }

  trainingSetOutput = trainingSetFeatures.last.toList();
  trainingSetOutput.removeAt(0);
  for (final feature in trainingSetFeatures)
    feature.removeAt(feature.length - 1);
  testSetOutput = testSetFeatures.last.toList();
  testSetOutput.removeAt(0);
  for (final feature in testSetFeatures) feature.removeAt(feature.length - 1);

  print("training samples:");
  for (final List<Object> row in trainingSetFeatures) print(row.sublist(0, 5));
  print("testing samples:");
  print(trainingSetOutput.sublist(0, 5));

  print(csvFile.length);
  print(trainingSetFeatures.first.length + testSetFeatures.first.length);
  print("${trainingSetFeatures.first.length} == ${trainingSetOutput.length}");
  print(trainingSetOutput.length);
  print("\x1B[2J\x1B[0;0H");
  List<double> inputs = [];

  for (final List<Object> sample in trainingSetFeatures)
    inputs.add(double.parse(sample.first.toString()));
  print(inputs);
  double output = double.parse(trainingSetOutput.first.toString());
  print(output);
  RecurrentNeuralNetwork network = RecurrentNeuralNetwork(
      learningRate: .01,
      inputValues: inputs,
      outputValue: output,
      neuronsOfEachLayer: [20, 1],
      activations: ["sigmoid", "sigmoid"]);

  print(network.inputs.length);
  print(network.layers.first.neurons.length);
  print(network.layers.last.neurons.length);
  // print("\x1B[2J\x1B[0;0H");
  // print("first");
  // for (final Neuron neuron in network.layers.first.neurons)
  //   print(neuron.output);
  // print("second");
  // for (final Neuron neuron in network.layers.first.neurons)
  //   print(neuron.output);

  trainNetwork(network: network, epoch: 30000);
  // mytest(network);
}

void trainNetwork(
    {int epoch = 10,
    required RecurrentNeuralNetwork network,
    double changingLearningRate = .9}) {
  double trainLoss = 0;
  double testLoss = 0;

  //! training
  // number of epoch
  for (int i = 0; i < epoch; i++) {
    trainLoss = 0;
    testLoss = 0;
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

      /// save outputs into context [Layer]
      List<double> temp = [];
      for (var neuron in network.layers.first.neurons) temp.add(neuron.output);

      for (int i = 0; i < network.layers.first.neurons.length; i++)
        network.contextNeurons[i].value = temp[i];

      /// calculate Loss training
      // trainLoss +=
      //     pow(((network.desiredOutput * 1216.83) - (actualOutput * 1216.83)), 2)
      //         .toDouble();
      trainLoss +=
          pow(((network.desiredOutput ) - (actualOutput)), 2)
              .toDouble();

      network.backPropagation;
      // print(network.backPropagation);
    }
    if (i == (trainingSetFeatures[0].length * .1).toInt()) {
      print("==change learning rate==");
      network.learningRate *= changingLearningRate;
    }

    //! testing
    for (int j = 0; j < testSetFeatures.first.length; j++) {
      // number of features
      for (int k = 0; k < testSetFeatures.length; k++)
        network.inputs[k] =
            InputNeuron(value: double.parse(testSetFeatures[k][j].toString()));
      network.desiredOutput = double.parse(testSetOutput[j].toString());

      // print(
      //     "${(network.feedForward as double) * 1216.83} should be ==> ${network.desiredOutput * 1216.83}");

      double actualOutput = network.feedForward as double;

      testLoss +=
          pow(((network.desiredOutput) - (actualOutput)), 2)
              .toDouble();
    }

    print(
        "Epoch $i Training => loss: ${trainLoss / trainingSetFeatures.first.length}   |   Test => loss: ${testLoss / testSetFeatures.first.length}");
  }
  print("Test predication: ");
  for (int j = 0; j < testSetFeatures.first.length; j++) {
    // number of features
    for (int k = 0; k < testSetFeatures.length; k++)
      network.inputs[k] =
          InputNeuron(value: double.parse(testSetFeatures[k][j].toString()));
    network.desiredOutput = double.parse(testSetOutput[j].toString());

    print(
        "${(network.feedForward as double) * 1216.83} should be ==> ${network.desiredOutput * 1216.83}");

    double actualOutput = network.feedForward as double;
  }
}

void mytest(RecurrentNeuralNetwork network) {
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
