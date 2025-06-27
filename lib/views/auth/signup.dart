import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayf/Service/auth_service.dart';
import 'package:sayf/constants.dart';
import 'package:sayf/views/auth/login.dart';
import 'package:sayf/views/widgets/move.dart';
import 'package:sayf/views/widgets/snakbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/button_widget.dart';
import '../widgets/inputInfo.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isPasswordHidden = true;
  bool isLoading = false;

  final AuthService _authService = AuthService();

  void _signUp() async {
    String fullName = _fullName.text.trim();
    String email = _email.text.trim();
    String phone = _phone.text.trim();
    String password = _password.text.trim();

    if (!email.contains("@") || !email.contains(".")) {
      ShowSnackBar(context, '❌ Invalid Email Format', Colors.red);
      return;
    }

    if (password.length < 6) {
      ShowSnackBar(context, '❌ Password must be at least 6 characters', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': fullName,
          'phone': phone,
        },
      );

      if (response.user != null) {
        ShowSnackBar(
          context,
          '✅ Signup successful. Please check your email to verify your account.',
          Colors.green,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ShowSnackBar(context, 'Signup failed. Try again.', Colors.red);
      }
    } catch (e) {
      ShowSnackBar(context, 'Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/4.svg', width: 150, height: 150),
            Text(
              'Sign up to Sayf',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: KaccentColor,
              ),
            ),
            const SizedBox(height: 30),
            InputInfo(controller1: _fullName, content: 'Full Name', is_obscure: false),
            InputInfo(controller1: _email, content: 'Email', is_obscure: false),
            InputInfo(controller1: _phone, content: 'Phone Number', is_obscure: false),
            InputInfo(
              controller1: _password,
              content: 'Password',
              is_obscure: isPasswordHidden,
              suffixIcon: IconButton(
                onPressed: () => setState(() => isPasswordHidden = !isPasswordHidden),
                icon: Icon(isPasswordHidden ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: double.infinity,
                height: 50.0,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : button(text: 'Sign up', tap: _signUp),
              ),
            ),
            const SizedBox(height: 10),
            MoveWidget(
              text: "Already have an account?",
              move: "Log in",
              tap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
