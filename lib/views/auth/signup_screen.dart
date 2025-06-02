import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sayf/constants.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants.dart';
import '../widgets/button_widget.dart';
import '../widgets/inputInfo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/4.svg', width: 150, height: 150),
          Text(
            'Log in to Sayf',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 40,
              color: KaccentColor,
            ),
          ),
          SizedBox(height: 30),
          InputInfo(
            controller1: _controller1,
            content: 'Email',
            is_obscure: false,
          ),
          InputInfo(
            controller1: _controller2,
            content: 'Password',
            is_obscure: true,
            suffixIcon: IconButton(
              onPressed: () {
                
              },
              icon: Icon(Icons.visibility),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: (){},
                  child: Text('Reset password', style: GoogleFonts.roboto(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: KaccentColor,

                  ),),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 50.0,

              child: button(text: 'Login', tap: () {}),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?", style: TextStyle(
                  fontSize: 15.0
                ),),
                
                TextButton(
                  onPressed: (){},
                  child: Text('Sign up', style: GoogleFonts.roboto(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: KaccentColor,
                  ),),
                ),

              ],
            ),

          ),

        ],
      ),
    );
  }
}
