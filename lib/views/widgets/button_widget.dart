import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../constants.dart';


class button extends StatelessWidget {
  const button({
    super.key,
    required this.text,
    required this.tap

  });
  final String text;
  final void Function() tap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: KaccentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0),
        ),
      ),
      onPressed: tap,
      child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            letterSpacing: 1.3,
            fontWeight: FontWeight.bold,
          ),
      ),
    );
  }
}