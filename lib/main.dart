import 'package:flutter/material.dart';
import 'package:sayf/config/supbase.dart';
import 'package:sayf/views/auth/login.dart';
import 'package:sayf/views/home.dart';
import 'package:sayf/views/homepage.dart';
import 'package:sayf/views/splash_scree.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupbaseConfig.url,
    anonKey: SupbaseConfig.anonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}