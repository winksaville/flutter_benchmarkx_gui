import 'dart:async';
import 'dart:isolate';

import 'package:benchmark_framework_x/benchmark_framework_x.dart';
import 'package:flutter/material.dart';
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
      home: const MyHomePage(title: name),
    );
  }
}

// The home page of the applicaiton.
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// The private State managment for HomePage
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<double> _samples = <double>[];

  static void runBenchmark(SendPort sendPort) {
    const BenchmarkBaseX bm = BenchmarkBaseX('Data');
    final List<double> samples =
        bm.measureSamples(sampleCount: 200, minExerciseInMillis: 2000);
    sendPort.send(samples);
  }

  Future<void> _incrementCounter() async {
    // Run the benchmark
    final ReceivePort receivePort = ReceivePort();

    final Isolate isolate = await Isolate.spawn(runBenchmark, receivePort.sendPort);

    List<double> samples;
    await receivePort.first.then((dynamic value) {
      if (value is List<double>) {
        samples = value;
      }
    });
    isolate.kill();

    // Use setState to update state variables so build gets called.
    setState(() {
      _counter++;
      _samples = samples;
    });
  }

  /// build is rerun everytime setState is called.
  @override
  Widget build(BuildContext context) {

    // Change to Colors.black to see the border
    BoxDecoration visualizeBorder() {
      const Color c = Colors.white; // black;
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
            Container(
              decoration: visualizeBorder(),
              child: const Text(
                'You have pushed the button this many times:',
              ),
            ),
            Container(
              decoration: visualizeBorder(),
              child: Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            Expanded( // Take all remaining real-estate
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: visualizeBorder(),
                child: SimpleLineChart('Data', _samples),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
