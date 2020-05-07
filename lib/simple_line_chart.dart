import 'package:benchmark_framework_x/benchmark_framework_x.dart'
    show SecondTimeUnits;
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SimpleLineChart extends StatelessWidget {
  SimpleLineChart(String title, List<double> data, {this.animate})
      : seriesList = createBenchmarkChartData(title, data);

  final List<charts.Series<double, int>> seriesList;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final charts.BasicNumericTickFormatterSpec customTickFormatter =
        charts.BasicNumericTickFormatterSpec(
            (num value) => SecondTimeUnits.asString(value.toDouble(), decimalPlaces: 0));

    return charts.LineChart(
      seriesList,
      animate: animate,
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickFormatterSpec: customTickFormatter,

        tickProviderSpec: const charts
            .StaticNumericTickProviderSpec(<charts.TickSpec<double>>[
          charts.TickSpec<double>(2.0e-10),
          charts.TickSpec<double>(2.5e-10),
          charts.TickSpec<double>(3.0e-10),
          charts.TickSpec<double>(3.5e-10),
          charts.TickSpec<double>(4.0e-10),
        ]),

        //tickProviderSpec: const charts.BasicNumericTickProviderSpec(
        //  dataIsInWholeNumbers: false,
        //  desiredTickCount: 3,
        //  zeroBound: false,
        //),
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
