import 'dart:async';
import 'dart:isolate';

import 'package:benchmark_framework_x/benchmark_framework_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stats/stats.dart' show Stats;
import 'fields.dart';
import 'labeled.dart';
import 'simple_line_chart.dart';

// Main entry point of the application
void main() {
  runApp(MyApp());
}

// The root widget for the applicaiton
class MyApp extends StatelessWidget {
  static const String name = 'Benchmark GUI';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: name,
      theme: ThemeData(
        // Color of the toolbar
        primarySwatch: Colors.blue,

        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BenchmarkForm(title: name),
    );
  }
}

class BenchmarkForm extends StatefulWidget {
  const BenchmarkForm({Key key, this.title}) : super(key: key);

  final String title;

  @override
  BenchmarkFormState createState() => BenchmarkFormState();
}

class BenchmarkParams {
  BenchmarkParams({this.sendPort, this.sampleCount, this.minExerciseInMillis});

  SendPort sendPort;
  final int sampleCount;
  final int minExerciseInMillis;
}

void runBenchmark(BenchmarkParams params) {
  const BenchmarkBaseX bm = BenchmarkBaseX('Data');
  final List<double> samples = bm.measureSamples(
      sampleCount: params.sampleCount,
      minExerciseInMillis: params.minExerciseInMillis);
  params.sendPort.send(samples);
}

class SampleCountField extends BaseIntField {
  SampleCountField(String label, int initialValue) : super(label, initialValue);
}

class MinExerciseInMillisField extends BaseIntField {
  MinExerciseInMillisField(String label, int initialValue)
      : super(label, initialValue);
}

Widget statsRow(Stats<double> stats, int selectedIndex, double selectedValue) {
  const double width = 150;
  const double height = 75;

  return Wrap(
    alignment: WrapAlignment.spaceEvenly,
    direction: Axis.horizontal,
    children: <Widget>[
      SizedBox(
        width: width,
        height: height,
        child: Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: LabeledSecond(
            label: selectedIndex == null ? 'v[?]' : 'v[$selectedIndex]',
            value: selectedValue,
          ),
        ),
      ),
      SizedBox(
        width: width,
        height: height,
        child: Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: LabeledSecond(
            label: 'avg',
            value: stats?.average?.toDouble(),
          ),
        ),
      ),
      SizedBox(
        width: width,
        height: height,
        child: Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: LabeledSecond(label: 'min', value: stats?.min?.toDouble()),
        ),
      ),
      SizedBox(
        width: width,
        height: height,
        child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: LabeledSecond(label: 'max', value: stats?.max?.toDouble()),
      ),
        ),
      SizedBox(
        width: width,
        height: height,
        child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: LabeledSecond(label: 'median', value: stats?.median?.toDouble()),
      ),
        ),
      SizedBox(
        width: width,
        height: height,
        child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: LabeledSecond(
            label: 'SD', value: stats?.standardDeviation?.toDouble()),
      ),
        ),
    ],
  );
}

class BenchmarkFormState extends State<BenchmarkForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<double> _samples = <double>[];
  Stats<double> _stats;
  int _selectedIndex;
  double _selectedValue;

  @override
  void initState() {
    super.initState();

    sampleCountField.addListener();
    minExerciseInMillisField.addListener();
  }

  @override
  void dispose() {
    print('BenchmarkFormState.dispose: sampleCountController.dispose()');
    sampleCountField.dispose();
    minExerciseInMillisField.dispose();
    super.dispose();
  }

  // BenchmarkForm fields
  SampleCountField sampleCountField = SampleCountField('Sample count', 100);
  MinExerciseInMillisField minExerciseInMillisField =
      MinExerciseInMillisField('minExercise ms', 1000);

  Future<void> runBm() async {
    print(
        'runBm:+ ${sampleCountField.value} ${minExerciseInMillisField.value}');
    // Run the benchmark
    final ReceivePort receivePort = ReceivePort();
    _selectedIndex = null;
    _selectedValue = null;

    final Isolate isolate = await Isolate.spawn(
        runBenchmark,
        BenchmarkParams(
            sendPort: receivePort.sendPort,
            sampleCount: sampleCountField.value,
            minExerciseInMillis: minExerciseInMillisField.value));

    List<double> samples;
    await receivePort.first.then((dynamic value) {
      if (value is List<double>) {
        samples = value;
      }
    });
    isolate.kill();

    // Use setState to update state variables so build gets called.
    setState(() {
      print(
          'runBm.setState:+ ${sampleCountField.value} ${minExerciseInMillisField.value}');
      _samples = samples;
      // TODO(wink): Do this in another isolate
      _stats = Stats<double>.fromData(_samples);
    });
  }

  void onSelectCallback(int index, double value) {
    // TODO(wink): I think we need to make the selected item output
    // a separate StatefulWidget so we don't update the entire graph
    // twice, once when the graph updates itself when the selection is
    // made. And then agian when we run this code. That is obviously
    // unnecessary and slow but it "clears" the selection highlighting!
    print('_onSelectCallback: model index=$index selectedDatum=$value');
    setState(() {
      print(
          'setState._onSelectCallback: model index=$index selectedDatum=$value');
      _selectedIndex = index;
      _selectedValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Change visualize to true to see the border
    BoxDecoration visualizeBorder() {
      const bool visualize = false;
      final Color c = visualize ? Colors.black : Theme.of(context).canvasColor;
      //const Color c = Colors.black;
      return BoxDecoration(
        border: Border.all(color: c, width: 3),
      );
    }

    const double width = 150;
    const double height = 75;

    // Return this rebuilt widget
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Vertical Column layout for the home page
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
            Expanded(
              // Take all remaining real-estate
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: visualizeBorder(),
                child: SimpleLineChart('Data', _samples,
                    onSelectCallback: onSelectCallback),
              ),
            ),
            Container(
              decoration: visualizeBorder(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(0),
                      //decoration: visualizeBorder(),
                      child: statsRow(_stats, _selectedIndex, _selectedValue),
                    ),
                    Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      direction: Axis.horizontal,
                      children: <Widget>[
                        SizedBox(
                          width: width,
                          height: height,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: sampleCountField.textFormField,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          height: height,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: minExerciseInMillisField.textFormField,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          height: height,
                          child: Container(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: RaisedButton(
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      print(
                                          'BenchmarkFormState.RaisedButton.onPressed: '
                                          'sampleCountController.text=${sampleCountField.value} '
                                          'minExerciseInMillis.text=${minExerciseInMillisField.value}');
                                      runBm();
                                    }
                                  },
                                  child: const Text('Run'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
