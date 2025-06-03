import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayf/views/auth/signup.dart';
import 'package:sayf/views/home.dart';
import '../../Service/auth_service.dart';
import '../../constants.dart';
import '../widgets/button_widget.dart';
import '../widgets/inputInfo.dart';
import '../widgets/move.dart';
import '../widgets/snakbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  bool isPasswordHidden = true;
  bool isLoading = false;
  final AuthService _authService = AuthService();

  /// ✅ login function
  void _login() async {
    String email = _controller1.text.trim();
    String password = _controller2.text.trim();

    if (!email.contains("@") || !email.contains(".")) {
      ShowSnackBar(context, 'Invalid Email Format', Colors.red);
      return;
    }

    if (password.length < 6) {
      ShowSnackBar(context, 'Password must be at least 6 characters', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    final result = await _authService.login(email, password);

    setState(() => isLoading = false);

    if (result == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => home()));
    } else {
      ShowSnackBar(context, result, Colors.red);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
        child: Column(
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
            const SizedBox(height: 30),
            InputInfo(
              controller1: _controller1,
              content: 'Email',
              is_obscure: false,
            ),
            InputInfo(
              controller1: _controller2,
              content: 'Password',
              is_obscure: isPasswordHidden,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
                icon: Icon(
                  isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: (){},
                child: Text(
                  'Reset password',
                  style: GoogleFonts.roboto(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: KaccentColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: double.maxFinite,
                height: 50.0,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : button(text: 'Log in', tap: _login),
              ),
            ),
            const SizedBox(height: 10),
            MoveWidget(
              text: "Don't have an account?",
              move: "Sign up",
              tap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Signup()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
