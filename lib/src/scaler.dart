/// Per-column min-max normalization fitted on training observations.
class MinMaxScaler {
  MinMaxScaler._(this.minimums, this.maximums);

  factory MinMaxScaler.fit(List<List<double>> rows) {
    if (rows.isEmpty || rows.first.isEmpty) {
      throw ArgumentError('At least one non-empty row is required.');
    }
    final width = rows.first.length;
    if (rows.any((row) => row.length != width)) {
      throw ArgumentError('All rows must have the same number of columns.');
    }
    final minimums = List<double>.from(rows.first);
    final maximums = List<double>.from(rows.first);
    for (final row in rows.skip(1)) {
      for (var index = 0; index < width; index++) {
        if (row[index] < minimums[index]) minimums[index] = row[index];
        if (row[index] > maximums[index]) maximums[index] = row[index];
      }
    }
    return MinMaxScaler._(minimums, maximums);
  }

  final List<double> minimums;
  final List<double> maximums;

  List<double> transform(List<double> row) {
    _checkWidth(row);
    return List.generate(row.length, (index) {
      final range = maximums[index] - minimums[index];
      return range == 0 ? 0 : (row[index] - minimums[index]) / range;
    });
  }

  List<double> inverseTransform(List<double> row) {
    _checkWidth(row);
    return List.generate(
      row.length,
      (index) =>
          row[index] * (maximums[index] - minimums[index]) + minimums[index],
    );
  }

  void _checkWidth(List<double> row) {
    if (row.length != minimums.length) {
      throw ArgumentError(
        'Expected ${minimums.length} columns, got ${row.length}.',
      );
    }
  }
}
