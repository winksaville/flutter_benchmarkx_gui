# benchmarkx_gui

An attempt at creating a GUI for my [dart_benchmark_framework_x](https://github.com/winksaville/dart_benchmark_framework_x).

Currently this funtions on Linux, Windows, MacOSX, Android and iPhone.
It doesn't work on the web because Isolates are not yet supported
by on the [web platform](https://github.com/flutter/flutter/issues/33577).

# Prerequisites

Dart: https://dart.dev/
Flutter: https://flutter.dev/

Execute `Flutter doctor` and install everything until everyting is Checked (Green):

```
wink@3900x:~/prgs/flutter/projects/benchmarkx_gui (master)
$ flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel Teach-flutter-to-rebuild-itself, 1.19.0-1.0.pre.44, on Linux, locale en_US.UTF-8)
[✓] Android toolchain - develop for Android devices (Android SDK version 29.0.3)
[✓] Linux toolchain - develop for Linux desktop
[✓] Android Studio (version 3.6)
[✓] Connected device (1 available)

• No issues found!
```

# Run the app

```
wink@3900x:~/prgs/flutter/projects/benchmarkx_gui (master)
$ flutter run -d linux
Launching lib/main.dart on Linux in debug mode...
Building Linux application...                                           
Waiting for Linux to report its views...                             2ms
flutter: LabeledSecond.build: label=v[?] value=null                     
flutter: LabeledSecond.build: label=avg value=null                      
flutter: LabeledSecond.build: label=min value=null                      
flutter: LabeledSecond.build: label=max value=null                      
flutter: LabeledSecond.build: label=median value=null                   
flutter: LabeledSecond.build: label=SD value=null                       
Syncing files to device Linux...                                   117ms

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h Repeat this help message.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
An Observatory debugger and profiler on Linux is available at: http://127.0.0.1:46591/87mewBX_cK4=/
flutter: Sample count.validator: "100" is GOOD
flutter: minExercise ms.validator: "1000" is GOOD
flutter: BenchmarkFormState.RaisedButton.onPressed: sampleCountController.text=100 minExerciseInMillis.text=1000
flutter: runBm:+ 100 1000
flutter: runBm.setState:+ 100 1000
flutter: LabeledSecond.build: label=v[?] value=null
flutter: LabeledSecond.build: label=avg value=2.3231939533948777e-10
flutter: LabeledSecond.build: label=min value=2.3001099960361495e-10
flutter: LabeledSecond.build: label=max value=2.567806125583574e-10
flutter: LabeledSecond.build: label=median value=2.3159046365762034e-10
flutter: LabeledSecond.build: label=SD value=3.4955147458323424e-12
```

Here is the screenshot before pressing 'Run':

![Run Once](/resources/Benchmarkx_gui-initial.png)

Here is the screen capture after pressing 'Run' once:

![Run Once](/resources/Benchmarkx_gui-run.png)




