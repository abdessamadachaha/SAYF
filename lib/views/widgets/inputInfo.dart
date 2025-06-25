import 'package:flutter/material.dart';

import '../../constants.dart';

class InputInfo extends StatelessWidget {
  InputInfo({
    super.key,
    required TextEditingController controller1,
    required this.content,  required this.is_obscure, this.suffixIcon,
  }) : _controller1 = controller1;


  final TextEditingController _controller1;
  final String content;
  bool is_obscure = false;
  final IconButton? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        child: TextField(
          obscureText: is_obscure!,
          controller: _controller1,
          decoration: InputDecoration(
            hintText: content,
            suffixIcon: suffixIcon,
            hintStyle: TextStyle(color: KprimaryColor.withAlpha(70)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    color: KprimaryColor,
                    width: 2.0
                )
            ),

          ),
        ),
      ),
    );
  }
}
