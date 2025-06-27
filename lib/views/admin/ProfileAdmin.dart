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
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : const AssetImage('assets/default-avatar.png')) as ImageProvider,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: pickImage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (val) => val!.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (val) => val!.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Nouveau mot de passe (optionnel)'),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KaccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer les modifications'),
                      onPressed: saveChanges,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
