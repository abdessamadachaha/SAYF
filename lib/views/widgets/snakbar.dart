import 'package:flutter/material.dart';

import '../../constants.dart';

void ShowSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(
        message,
        style: TextStyle(color: KbackgroundColor, fontSize: 15),
      ),
    ),
  );
}
