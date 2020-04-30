import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory SimpleLineChart.withSampleData(String title) {
    final List<double> mockData = <double>[
      2.2e-10,
      2.4e-10,
      4.0e-10,
      2.1e-10,
      2.3e-10,
    ];

    return SimpleLineChart(
      createBenchmarkChartData(title, mockData),
      // Disable animations for image tests.
      animate: false,
    );
  }

  final List<charts.Series<double, int>> seriesList;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final charts.BasicNumericTickFormatterSpec customTickFormatter =
        charts.BasicNumericTickFormatterSpec((num value) => value.toString());

    return charts.LineChart(
      seriesList,
      animate: animate,
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickFormatterSpec: customTickFormatter,

        tickProviderSpec: const charts.BasicNumericTickProviderSpec(
          dataIsInWholeNumbers: false,
          desiredTickCount: 3,
          zeroBound: false,
        ),
      ),
    );
  }

  /// Create a charts.Series from the benchmark data.
  static List<charts.Series<double, int>> createBenchmarkChartData(
    String title,
    List<double> data,
  ) {
    return <charts.Series<double, int>>[
      charts.Series<double, int>(
        id: title,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (_, int idx) => idx,
        measureFn: (double y, _) => y,
        data: data,
      )
    ];
  }
}

