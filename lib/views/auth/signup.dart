import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sayf/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayf/views/auth/signup_screen.dart';
import 'package:sayf/views/widgets/move.dart';

import '../widgets/button_widget.dart';
import '../widgets/inputInfo.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController _fullName = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/4.svg', width: 150, height: 150),
          Text(
            'Sign up  to Sayf',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 40,
              color: KaccentColor,
            ),
          ),
          SizedBox(height: 30),
          InputInfo(
            controller1: _fullName,
            content: 'Full Name',
            is_obscure: false,
          ),
          InputInfo(controller1: _email, content: 'Email', is_obscure: false),
          InputInfo(
            controller1: _phone,
            content: 'Phone Number',
            is_obscure: false,
          ),
          InputInfo(
            controller1: _password,
            content: 'Password',
            is_obscure: true,
            suffixIcon: IconButton(
              onPressed: () {},
              icon: Icon(Icons.visibility),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 50.0,

              child: button(text: 'Sign up', tap: () {}),
            ),
          ),
          MoveWidget(text: "Already have an account?", tap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignupScreen()),
            );
          })

        ],
      ),
    );
  }
}
