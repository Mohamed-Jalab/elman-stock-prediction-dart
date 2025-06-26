import 'dart:math';

abstract class DatasetManager {
  /// converting a [List] of [String] that are nums to [List] of [num]
  static List<num>? parseToNums(List<String> strs) {
    bool isNumeric = num.tryParse(strs.first) != null;
    if (isNumeric) {
      try {
        List<int> nums = [];
        for (final String str in strs) nums.add(int.parse(str));
        return nums;
      } catch (_) {
        List<double> nums = [];
        for (final String str in strs) nums.add(double.parse(str));
        return nums;
      }
    }
  }

  static List<int> encode(List<String> strs) {
    List<int> encodedList = [];
    Set<String> units = strs.toSet();
    print(units);
    for (int i = 0; i < strs.length; i++)
      for (int j = 0; j < units.length; j++)
        if (strs[i] == units.elementAt(j)) encodedList.add(j);
    return encodedList;
  }

  static List<double> normalize(List<int> integers) {
    int maxValue = integers.reduce((value, element) => max(value, element));
    print(maxValue);
    List<double> normalizedList = [];
    for (final int integer in integers) normalizedList.add(integer / maxValue);
    return normalizedList;
  }

  static List<List<Object>> createDataset(List<String> csvFile,
      {bool logProcess = true}) {
    List<List<Object>> csvProcessed = [];
    for (int i = 0; i < csvFile[0].split(',').length; i++)
      csvProcessed.add(<String>[]);
    for (final String row in csvFile) {
      List<String> temp = row.split(',');
      for (int i = 0; i < csvFile[0].split(',').length; i++)
        csvProcessed[i].add(temp[i]);
    }
    // print 10 element of each row in csvProcessed for ensuring
    if (logProcess) {
      print("Before: ");
      for (final List<Object> row in csvProcessed)
        print("${row.runtimeType} ==> ${row.sublist(0, 10)}");
    }

    for (int i = 0; i < csvProcessed.length; i++) {
      List<num>? temp =
          DatasetManager.parseToNums(csvProcessed[i] as List<String>);
      if (temp != null) csvProcessed[i] = temp;
    }
    for (int i = 0; i < csvProcessed.length; i++)
      if (csvProcessed[i] is List<String>)
        csvProcessed[i] =
            DatasetManager.encode(csvProcessed[i] as List<String>);

    // print 10 element of each row in csvProcessed for ensuring
    if (logProcess) {
      print("Before Normalizing: ");
      for (final List<Object> row in csvProcessed)
        print("${row.runtimeType} ==> ${row.sublist(0, 10)}");
    }

    // Normalizing CSV file
    for (int i = 0; i < csvProcessed.length; i++)
      if (csvProcessed[i] is List<int>)
        csvProcessed[i] = normalize(csvProcessed[i] as List<int>);

    // print 10 element of each row in csvProcessed for ensuring
    if (logProcess) {
      print("After Normalizing: ");
      for (final List<Object> row in csvProcessed)
        print("${row.runtimeType} ==> ${row.sublist(0, 10)}");
    }
    return csvProcessed;
  }
}
