import 'dart:async';
import 'dart:isolate';

import 'package:benchmark_framework_x/benchmark_framework_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

void runBm(BenchmarkParams params) {
  const BenchmarkBaseX bm = BenchmarkBaseX('Data');
  final List<double> samples = bm.measureSamples(
      sampleCount: params.sampleCount,
      minExerciseInMillis: params.minExerciseInMillis);
  params.sendPort.send(samples);
}

class BaseIntField {
  BaseIntField(this.label, int initialValue) :
    controller = TextEditingController(text: initialValue.toString());

  void dispose() {
    controller.dispose();
  }

  int value;
  final String label;
  final TextEditingController controller;
  TextFormField get textFormField => TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: validator,
      );

  String validator(String valueStr) {
    if (valueStr.isEmpty || (int.parse(valueStr).toInt() < 0)) {
      print('$label.validator: "$valueStr" is not correct must be >= 1');
      return '$label must be >= 1';
    }

    // The param valueStr is good, set value.
    print('$label.validator: "$valueStr" is GOOD');
    value = int.parse(valueStr).toInt();
    return null; // All is well
  }

  void addListener() {
    controller.addListener(() {
      // This will be invoked with every change i.e. every keystroke.
      print('$label.controller.text=${controller.text}');
    });
  }
}

class SampleCountField extends BaseIntField {
  SampleCountField(String label, int initialValue) : super(label, initialValue);
}

class MinExerciseInMillisField extends BaseIntField {
  MinExerciseInMillisField(String label, int initialValue) : super(label, initialValue);
}

class BenchmarkFormState extends State<BenchmarkForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<double> _samples = <double>[];

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
      MinExerciseInMillisField('minExercise ms', 5000);

  Future<void> _runBm() async {
    print(
        '_runBm:+ ${sampleCountField.value} ${minExerciseInMillisField.value}');
    // Run the benchmark
    final ReceivePort receivePort = ReceivePort();

    final Isolate isolate = await Isolate.spawn(
        runBm,
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
          '_runBm.setState:+ ${sampleCountField.value} ${minExerciseInMillisField.value}');
      _samples = samples;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Change to Colors.black to see the border
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
                child: SimpleLineChart('Data', _samples),
              ),
            ),
            Container(
              decoration: visualizeBorder(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
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
                      ],
                    ),
                    RaisedButton(onPressed: () {
                      if (_formKey.currentState.validate()) {
                        print('BenchmarkFormState.RaisedButton.onPressed: '
                            'sampleCountController.text=${sampleCountField.value} '
                            'minExerciseInMillis.text=${minExerciseInMillisField.value}');
                        print('BenchmarkFormState.RaisedButton.onPressed: '
                            'call _runBm');
                        _runBm();
                      }
                    }),
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
