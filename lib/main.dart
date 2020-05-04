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

class BenchmarkFormState extends State<BenchmarkForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<double> _samples = <double>[];

  // BenchmarkForm fields
  static const String _sampleCountLabel = 'Sample count';
  int _sampleCount;

  Future<void> _runBm() async {
    print('_runBm:+ $_sampleCount');
    // Run the benchmark
    final ReceivePort receivePort = ReceivePort();

    final Isolate isolate = await Isolate.spawn(
        runBm,
        BenchmarkParams(
            sendPort: receivePort.sendPort, sampleCount: _sampleCount));

    List<double> samples;
    await receivePort.first.then((dynamic value) {
      if (value is List<double>) {
        samples = value;
      }
    });
    isolate.kill();

    // Use setState to update state variables so build gets called.
    setState(() {
      print('_runBm.setState:+ $_sampleCount');
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
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: _sampleCountLabel,
                        ),
                        onChanged: (String value) {
                          print('$_sampleCountLabel.onChanged: "$value"');
                          if (value.isNotEmpty) {
                            _sampleCount = int.parse(value);
                          }
                        },
                        validator: (String value) {
                          if (value.isEmpty || (int.parse(value).toInt() < 0)) {
                            print(
                                '$_sampleCountLabel.validator: "$value" is not correct must be >= 1');
                            return '$_sampleCountLabel must be >= 1';
                          }
                          print('$_sampleCountLabel.validator: "$value" is GOOD');
                          _sampleCount = int.parse(value).toInt();
                          return null; // All is well
                        },
                      ),
                    ),
                    RaisedButton(onPressed: () {
                      if (_formKey.currentState.validate()) {
                        print('Call benchmark');
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
