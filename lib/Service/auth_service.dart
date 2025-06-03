import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../views/auth/login.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<String?> signup(String fullName, String email, String phone, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        await supabase.from('users').upsert({
          'id': user.id,
          'full_name': fullName,
          'phone': phone,
          'email': email,
          'password': password
        });

        return null; // Success
      }

      return "✅ تم التسجيل، تحقق من بريدك الإلكتروني لتفعيل الحساب.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        final userData = await supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        print("User Full Name: ${userData['full_name']}");
        print("Phone: ${userData['phone']}");


        return null;
      }

      return "Invalid email or password";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }


  Future<void> logout(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

}
