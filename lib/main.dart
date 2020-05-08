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

Widget statsRow(Stats<double> stats, SelectedValue selectedValue) {
  //, int selectedIndex, double selectedValue) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      selectedValue,
      //Container(
      //  margin: const EdgeInsets.only(left: 10, right: 10),
      //  child: LabeledSecond(
      //    label: selectedIndex == null ? 'v[?]' : 'v[$selectedIndex]',
      //    value: selectedValue,
      //  ),
      //),
      Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: LabeledSecond(
          label: 'avg',
          value: stats?.average?.toDouble(),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: LabeledSecond(label: 'min', value: stats?.min?.toDouble()),
      ),
      Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: LabeledSecond(label: 'max', value: stats?.max?.toDouble()),
      ),
      Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: LabeledSecond(label: 'median', value: stats?.median?.toDouble()),
      ),
      Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: LabeledSecond(
            label: 'SD', value: stats?.standardDeviation?.toDouble()),
      ),
    ],
  );
}

class BenchmarkFormState extends State<BenchmarkForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<double> _samples = <double>[];
  Stats<double> _stats;
  final SelectedValue _selectedValue = SelectedValue();

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
    print(
        'BenchmarkFormState.onSelectCallback: model index=$index selectedDatum=$value');
    _selectedValue.update(index, value);
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
                      child: statsRow(_stats,
                          _selectedValue), //, _selectedIndex, _selectedValue),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: sampleCountField.textFormField,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: minExerciseInMillisField.textFormField,
                          ),
                        ),
                        Container(
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

class SelectedValue extends StatefulWidget {
  SelectedValue({Key key})
      : _state = SelectedValueState(),
        super(key: key) {
    print('SelectedValue.ctor:+-');
  }

  final SelectedValueState _state;

  void update(int index, double value) => _state.update(index, value);

  @override
  State<StatefulWidget> createState() => SelectedValueState();
}

class SelectedValueState extends State<SelectedValue> {
  SelectedValueState() {
    print('SelectedValueState.ctor:+- mounted=$mounted');
  }

  int _index;
  double _value;

  void update(int index, double value) {
    print(
        'SelectedValueState.update: model index=$index selectedDatum=$value mounted=$mounted');
    _index = index;
    _value = value;
    //if (mounted) {
      print(
          'SelectedValueState.update: model index=$index selectedDatum=$value WE ARE mounted=$mounted');
      setState(() {
        print('setState.update: model index=$index selectedDatum=$value');
        _index = index;
        _value = value;
      });
    //}
  }

  @override
  void initState() {
    print('SelectedValueState.initState:- calling super mounted=$mounted');
    super.initState();
    print('SelectedValueState.initState:- retfrom super mounted=$mounted');
  }

  @override
  void didUpdateWidget(SelectedValue oldWidget) {
    print('SelectedValueState.didUpdateWidget:+ calling super mounted=$mounted');
    super.didUpdateWidget(oldWidget);
    print('SelectedValueState.didUpdateWidget:- retfrom super mounted=$mounted');
  }

  @override
  void reassemble() {
    print('SelectedValueState.reassemble:+ calling super mounted=$mounted');
    super.reassemble();
    print('SelectedValueState.reassemble:- retfrom super mounted=$mounted');
  }

  @override
  //Future<void> setState(void Function() fn) async {
  void setState(void Function() fn) {
    print('SelectedValueState.setState:+ calling super mounted=$mounted');
    super.setState(fn);
    print('SelectedValueState.setState:- retfrom super mounted=$mounted');
  }

  @override
  void deactivate() {
    print('SelectedValueState.deactivate:+ calling super mounted=$mounted');
    super.deactivate();
    print('SelectedValueState.deactivate:- retfrom super mounted=$mounted');
  }

  @override
  void dispose() {
    print('SelectedValueState.displose:+ calling super mounted=$mounted');
    super.dispose();
    print('SelectedValueState.displose:- retfrom super mounted=$mounted');
  }

  @override
  Widget build(BuildContext context) {
    print('SelectedValueState.build:+- mounted=$mounted');
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: LabeledSecond(
        label: _index == null ? 'v[?]' : 'v[$_index]',
        value: _value,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    print('SelectedValueState.didChangeDependencies:+ calling super mounted=$mounted');
    super.didChangeDependencies();
    print('SelectedValueState.didChangeDependencies:- retfrom super mounted=$mounted');
  }
}
