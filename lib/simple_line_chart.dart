import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory SimpleLineChart.withSampleData() {
    return SimpleLineChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  final List<charts.Series<LinearSales, int>> seriesList;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(seriesList, animate: animate);
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final List<LinearSales> data = <LinearSales>[
      LinearSales(0, 5),
      LinearSales(1, 25),
      LinearSales(2, 100),
      LinearSales(3, 75),
    ];

    return <charts.Series<LinearSales, int>>[
      charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  LinearSales(this.year, this.sales);

  final int year;
  final int sales;
}
