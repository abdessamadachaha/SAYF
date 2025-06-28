import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sayf/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileAdmin extends StatefulWidget {
  const ProfileAdmin({super.key});

  @override
  State<ProfileAdmin> createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<ProfileAdmin> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  File? _pickedImage;
  String? _profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    setState(() {
      _nameCtrl.text = response['name'] ?? '';
      _emailCtrl.text = response['email'] ?? '';
      _profileImageUrl = response['image'];
      isLoading = false;
    });
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> uploadProfileImage(File file) async {
    final fileName = "admin_${DateTime.now().millisecondsSinceEpoch}.jpg";
    await supabase.storage.from('avatars').upload(fileName, file,
        fileOptions: const FileOptions(upsert: true));
    return supabase.storage.from('avatars').getPublicUrl(fileName);
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    String? imageUrl = _profileImageUrl;

    if (_pickedImage != null) {
      imageUrl = await uploadProfileImage(_pickedImage!);
    }

    await supabase.from('users').update({
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'image': imageUrl,
    }).eq('id', user.id);

    if (_passwordCtrl.text.isNotEmpty) {
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordCtrl.text),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Profil mis à jour")),
    );
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KbackgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : (_profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : const AssetImage("assets/default-avatar.png")) as ImageProvider,
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: KaccentColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.edit, size: 18, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    buildTextField("Nom", _nameCtrl),
                    const SizedBox(height: 20),
                    buildTextField("Email", _emailCtrl, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    buildTextField("Nouveau mot de passe", _passwordCtrl,
                        obscureText: true, hint: "(Laisser vide si inchangé)"),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
  onPressed: saveChanges,
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    backgroundColor: KaccentColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 6,
    shadowColor: KaccentColor.withOpacity(0.4),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.save_alt, size: 22),
      const SizedBox(width: 10),
      const Text(
        "Sauvegarder les modifications",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ],
  ),
),

                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text, String? hint}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty && !obscureText ? 'Ce champ est requis' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: label == "Email"
            ? const Icon(Icons.email)
            : label == "Nom"
                ? const Icon(Icons.person)
                : const Icon(Icons.lock),
      ),
    );
  }
}
