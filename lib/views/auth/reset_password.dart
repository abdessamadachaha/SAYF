import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/snakbar.dart';
import '../widgets/button_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool isLoading = false;

  void _resetPassword() async {
    final newPass = _newPassword.text.trim();
    final confirmPass = _confirmPassword.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      ShowSnackBar(context, '❌ جميع الحقول مطلوبة', Colors.red);
      return;
    }

    if (newPass != confirmPass) {
      ShowSnackBar(context, '❌ كلمتا المرور غير متطابقتين', Colors.red);
      return;
    }

    if (newPass.length < 6) {
      ShowSnackBar(context, '❌ كلمة المرور يجب أن تتكون من 6 أحرف على الأقل', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(password: newPass));
      if (!mounted) return;
      ShowSnackBar(context, '✅ تم تغيير كلمة المرور بنجاح', Colors.green);
      Navigator.pop(context);
    } on AuthException catch (e) {
      ShowSnackBar(context, e.message, Colors.red);
    } catch (e) {
      ShowSnackBar(context, "خطأ غير متوقع: $e", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إعادة تعيين كلمة المرور")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _newPassword,
              decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPassword,
              decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: button(
                text: 'تغيير كلمة المرور',
                tap: _resetPassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
