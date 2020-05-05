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
  BenchmarkParams({this.sendPort, this.sampleCount});

  SendPort sendPort;
  final int sampleCount;
}

void runBm(BenchmarkParams params) {
  const BenchmarkBaseX bm = BenchmarkBaseX('Data');
  final List<double> samples = bm.measureSamples(
      sampleCount: params.sampleCount, minExerciseInMillis: 2000);
  params.sendPort.send(samples);
}

class SampleCountField {
  SampleCountField(this.label);

  void dispose() {
    controller.dispose();
  }

  int value;
  final String label;
  final TextEditingController controller = TextEditingController();
  TextFormField get textFormField => TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: (String valueStr) {
          if (valueStr.isEmpty || (int.parse(valueStr).toInt() < 0)) {
            print('$label.validator: "$valueStr" is not correct must be >= 1');
            return '$label must be >= 1';
          }

          // The param valueStr is good, set value.
          print('$label.validator: "$valueStr" is GOOD');
          value = int.parse(valueStr).toInt();
          return null; // All is well
        },
      );

  void addListener() {
    controller.addListener(() {
      // This will be invoked with every change i.e. every keystroke.
      print('SampleCountField.controller.text=${controller.text}');
    });
  }
}

class BenchmarkFormState extends State<BenchmarkForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<double> _samples = <double>[];

  @override
  void initState() {
    super.initState();

    sampleCountField.addListener();
  }

  @override
  void dispose() {
    print('BenchmarkFormState.dispose: sampleCountController.dispose()');
    sampleCountField.dispose();
    super.dispose();
  }

  // BenchmarkForm fields
  SampleCountField sampleCountField = SampleCountField('Sample count');

  Future<void> _runBm() async {
    print('_runBm:+ ${sampleCountField.value}');
    // Run the benchmark
    final ReceivePort receivePort = ReceivePort();

    final Isolate isolate = await Isolate.spawn(
        runBm,
        BenchmarkParams(
            sendPort: receivePort.sendPort,
            sampleCount: sampleCountField.value));

    List<double> samples;
    await receivePort.first.then((dynamic value) {
      if (value is List<double>) {
        samples = value;
      }
    });
    isolate.kill();

    // Use setState to update state variables so build gets called.
    setState(() {
      print('BenchmarkFormState._runBm.setState:+ ${sampleCountField.value}');
      _samples = samples;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Change to Colors.black to see the border
    BoxDecoration visualizeBorder() {
      const Color c = Colors.black; //.white; // black;
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
                    Container(
                      decoration: visualizeBorder(),
                      child: sampleCountField.textFormField,
                    ),
                    RaisedButton(onPressed: () {
                      if (_formKey.currentState.validate()) {
                        print('BenchmarkFormState.RaisedButton.onPressed: '
                            'sampleCountController.text=${sampleCountField.value}');
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
