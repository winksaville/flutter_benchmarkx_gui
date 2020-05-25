import 'package:benchmark_framework_x/benchmark_framework_x.dart'
    show SecondTimeUnits;
import 'package:flutter/material.dart';
import 'package:charts_flutter_cf/charts_flutter_cf.dart' as charts;

class SimpleLineChart extends StatelessWidget {
  SimpleLineChart(String title, List<double> data,
      {this.animate, this.onSelectCallback})
      : seriesList = createBenchmarkChartData(title, data);

  final List<charts.Series<double, int>> seriesList;
  final bool animate;
  final void Function(int index, double value) onSelectCallback;

  void _onSelectionChanged(charts.SelectionModel<num> model) {
    if (onSelectCallback != null) {
      final int index = model.selectedDatum.first.index;
      final double value = model.selectedDatum.first.datum as double;
      onSelectCallback(index, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final charts.BasicNumericTickFormatterSpec customTickFormatter =
        charts.BasicNumericTickFormatterSpec((num value) =>
            SecondTimeUnits.asString(value.toDouble(), decimalPlaces: 0));

    return charts.LineChart(
      seriesList,
      animate: animate,
      selectionModels: <charts.SelectionModelConfig<int>>[
        charts.SelectionModelConfig<int>(
          type: charts.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        ),
      ],
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickFormatterSpec: customTickFormatter,

        // This is nice when we guess range correctly, but we could still
        // use "minor ticks", i.e. ticks without labels.
        //tickProviderSpec: const charts
        //    .StaticNumericTickProviderSpec(<charts.TickSpec<double>>[
        //  charts.TickSpec<double>(2.0e-10),
        //  charts.TickSpec<double>(2.5e-10),
        //  charts.TickSpec<double>(3.0e-10),
        //  charts.TickSpec<double>(3.5e-10),
        //  charts.TickSpec<double>(4.0e-10),
        //]),

        // TODO(wink): The above static doesn't work because we can't
        // know what the range is going to be. At the moment it doesn't
        // look like there is enough control over the adding ticks in
        // the package as it is currently. We'll probably have to do our
        // own so we can get more detail and implent "minor ticks".
        tickProviderSpec: const charts.BasicNumericTickProviderSpec(
          dataIsInWholeNumbers: false,
          desiredTickCount: 5,
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
