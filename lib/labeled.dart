import 'package:benchmark_framework_x/benchmark_framework_x.dart' as bmrk;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' show NumberFormat;

class LabeledText extends StatelessWidget {
  const LabeledText({this.label, this.text}) : super();

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '$label:',
          textAlign: TextAlign.left,
        ),
        Text(
          text,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class LabeledDouble extends StatelessWidget {
  const LabeledDouble({this.label, this.value, this.format}) : super();

  final String label;
  final double value;
  final String format;

  @override
  Widget build(BuildContext context) {
    print('LabeledDouble.build: label=$label value=$value format=$format');
    String valueStr;
    if (value == null) {
      valueStr = '';
    } else {
      valueStr = NumberFormat(format ?? '0.0#E0').format(value);
    }

    return Row(
      children: <Widget>[
        Text(
          '$label: ',
          textAlign: TextAlign.left,
        ),
        Text(
          valueStr,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class LabeledSecond extends StatelessWidget {
  const LabeledSecond({this.label, this.value, this.decimalPlaces=1}) : super();

  final String label;
  final double value;
  final int decimalPlaces;

  @override
  Widget build(BuildContext context) {
    print('LabeledSecond.build: label=$label value=$value');
    String valueStr;
    if (value == null) {
      valueStr = '';
    } else {
      valueStr = bmrk.SecondTimeUnits.asString(value, decimalPlaces: decimalPlaces);
    }

    return Row(
      children: <Widget>[
        Text(
          '$label: ',
          textAlign: TextAlign.left,
        ),
        Text(
          valueStr,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
