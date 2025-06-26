import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayf/views/auth/signup.dart';
import 'package:sayf/views/home.dart';
import 'package:sayf/views/homepage.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Service/auth_service.dart';
import '../../constants.dart';
import '../../models/person.dart'; // تأكد من استيراد model
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

  try {
    final authResponse = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) throw Exception("Login failed: user is null");

    // ✅ نحاول نجيب البيانات من table users
    final userQuery = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    late Map<String, dynamic> userData;

    if (userQuery == null) {
      await Supabase.instance.client.from('users').insert({
        'id': user.id,
        'name': user.userMetadata?['name'] ?? '',
        'email': user.email,
        'phone': user.userMetadata?['phone'] ?? '',
        'role': 'customer',
        'is_ban': false,
      });

      userData = {
        'id': user.id,
        'name': user.userMetadata?['name'] ?? '',
        'email': user.email,
        'phone': user.userMetadata?['phone'] ?? '',
        'role': 'customer',
        'is_ban': false,
      };
    } else {
      userData = userQuery;
    }

    final bool ban = userData['is_ban'] ?? false;
    final String role = userData['role'] ?? 'customer';
    final person = Person.fromMap(userData);

    if (ban) {
      ShowSnackBar(context, '🚫 Votre compte est banni.', Colors.red);
      return;
    }

    if (role == 'customer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Home(person: person)),
      );
    } else if (role == 'tennant') {
      Navigator.pushReplacementNamed(context, '/tennat-dashboard');
    } else if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      ShowSnackBar(context, 'Rôle inconnu.', Colors.red);
    }
  } catch (e) {
    ShowSnackBar(
      context,
      e.toString().toLowerCase().contains('invalid login credentials')
          ? '❌ Email ou mot de passe incorrect'
          : 'Erreur: ${e.toString()}',
      Colors.red,
    );
  } finally {
    setState(() => isLoading = false);
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
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot-password');
                },
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
