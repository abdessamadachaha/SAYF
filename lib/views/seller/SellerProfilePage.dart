import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:sayf/constants.dart';

final supabase = Supabase.instance.client;

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;
  String? imageUrl;
  String currentRole = 'customer';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase.from('users').select().eq('id', user.id).single();
    setState(() {
      nameController.text = response['name'] ?? '';
      phoneController.text = response['phone'] ?? '';
      imageUrl = response['image'];
      currentRole = response['role'] ?? 'customer';
      isLoading = false;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
      });
    }
  }

  Future<String?> uploadImage(Uint8List bytes, String fileName) async {
    try {
      final response = await supabase.storage.from('users').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      if (response.isEmpty) return null;
      return supabase.storage.from('users').getPublicUrl(fileName);
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> saveChanges() async {
    final userId = supabase.auth.currentUser!.id;
    String? newImageUrl = imageUrl;

    if (_imageBytes != null && _imageName != null) {
      final ext = p.extension(_imageName!);
      final fileName = '${const Uuid().v4()}$ext';
      newImageUrl = await uploadImage(_imageBytes!, fileName);
    }

    await supabase.from('users').update({
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'image': newImageUrl,
      'role': currentRole,
    }).eq('id', userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Profil mis à jour')),
    );
  }

  Future<void> changePassword() async {
    final newPassword = passwordController.text.trim();
    if (newPassword.isEmpty) return;

    await supabase.auth.updateUser(UserAttributes(password: newPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔐 Mot de passe mis à jour')),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// Rôle switch en haut
                Card(
                  color: KbackgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Rôle actuel :", style: TextStyle(fontSize: 16, color: KtextColor)),
                        Row(
                          children: [
                            Text("Client", style: TextStyle(color: KtextColor)),
                            Switch(
                              value: currentRole == 'tenant',
                              onChanged: (val) {
                                setState(() {
                                  currentRole = val ? 'tenant' : 'customer';
                                });
                              },
                              activeColor: KaccentColor,
                            ),
                            Text("Propriétaire", style: TextStyle(color: KtextColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// Profil Card
                Card(
                  elevation: 6,
                  color: KbackgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        /// Avatar
                        GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 55,
                            backgroundImage: _imageBytes != null
                                ? MemoryImage(_imageBytes!)
                                : (imageUrl != null ? NetworkImage(imageUrl!) : null)
                                    as ImageProvider?,
                            child: _imageBytes == null && imageUrl == null
                                ? const Icon(Icons.person, size: 55, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),

                        const SizedBox(height: 20),
                        buildInputField(nameController, 'Nom', Icons.person),
                        const SizedBox(height: 12),
                        buildInputField(phoneController, 'Téléphone', Icons.phone,
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 12),
                        buildInputField(passwordController, 'Nouveau mot de passe', Icons.lock,
                            obscure: true),
                        const SizedBox(height: 20),

                        /// Boutons
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('Sauvegarder', style: TextStyle(color: Colors.white)),
                          onPressed: saveChanges,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: KaccentColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: Icon(Icons.password, color: KaccentColor),
                          label: Text("Changer le mot de passe", style: TextStyle(color: KaccentColor)),
                          onPressed: changePassword,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            side: BorderSide(color: KaccentColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
  );
}
Widget buildInputField(TextEditingController controller, String label, IconData icon,
      {bool obscure = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(color: KtextColor),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: KaccentColor),
        labelText: label,
        labelStyle: TextStyle(color: KtextColor),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
