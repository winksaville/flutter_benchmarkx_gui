import 'package:flutter/material.dart';

class BaseIntField {
  BaseIntField(this.label, int initialValue)
      : controller = TextEditingController(text: initialValue.toString());

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
