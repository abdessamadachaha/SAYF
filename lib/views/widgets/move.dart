import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayf/constants.dart';

class MoveWidget extends StatelessWidget {
  MoveWidget({
    super.key,
    required this.text,
    required this.tap, required this.move,
  });

  final String text;
  void Function() tap;
  final String move;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: TextStyle(
              fontSize: 15.0
          ),),

          TextButton(
            onPressed: tap,

            child: Text(move, style: GoogleFonts.roboto(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: KaccentColor,
            ),),
          ),

        ],
      ),

    );
  }
}