import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:sayf/constants.dart';
import 'package:sayf/models/person.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final Person person;
  const ProfileScreen({super.key, required this.person});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final SupabaseClient _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool _isSeller = false;
  bool _isSwitchingRole = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person.name);
    _phoneController = TextEditingController(text: widget.person.phone ?? '');
    _passwordController = TextEditingController();
    _isSeller = widget.person.role == 'tenant';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  ImageProvider<Object>? _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (widget.person.image != null && widget.person.image!.isNotEmpty) {
      return NetworkImage(widget.person.image!);
    }
    return const AssetImage('assets/avatar.jpg');
  }

  Future<String?> _uploadImage(File file) async {
    final fileExt = path.extension(file.path);
    final fileName = '${widget.person.id}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
    final filePath = 'users/$fileName';

    try {
      final bytes = await file.readAsBytes();
      await _supabase.storage.from('users').uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );
      final publicUrl = _supabase.storage.from('users').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  Future<void> _showImageSourceSelector() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() => _isUploading = true);
        final file = File(pickedFile.path);
        final imageUrl = await _uploadImage(file);
        if (imageUrl != null) {
          await _supabase
              .from('users')
              .update({'image': imageUrl}) // ← column name
              .eq('id', widget.person.id);
          setState(() {
            _imageFile = file;
            widget.person.image = imageUrl;
          });
        }
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);

    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    if (_passwordController.text.isNotEmpty) {
      try {
        await _supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text.trim()),
        );
      } catch (e) {
        _showErrorSnackbar('Failed to update password: ${e.toString()}');
        setState(() => _isUploading = false);
        return;
      }
    }

    try {
      await _supabase.from('users').update(updates).eq('id', widget.person.id);
      _showSuccessSnackbar('Profile updated successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to update profile: ${e.toString()}');
    }
    setState(() => _isUploading = false);
  }

  Future<void> _switchRole(bool newValue) async {
    setState(() => _isSwitchingRole = true);
    try {
      await _supabase
          .from('users')
          .update({'role': newValue ? 'tenant' : 'customer'})
          .eq('id', widget.person.id);
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to switch role: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSwitchingRole = false);
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KprimaryColor,
        title: Text('My Profile', style: GoogleFonts.poppins(
          fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Container(), 
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _supabase.auth.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: KprimaryColor, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _getProfileImage(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: KprimaryColor,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      onPressed: _isUploading ? null : _showImageSourceSelector,
                    ),
                  ),
                ),
                if (_isUploading)
                  const Positioned.fill(child: CircularProgressIndicator()),
              ],
            ),
            const SizedBox(height: 20),
            Text(widget.person.email ?? '',
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: KprimaryColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tenant Account',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Switch(
                    value: _isSeller,
                    onChanged: _isSwitchingRole ? null : (value) => _showRoleSwitchDialog(value),
                    activeColor: KprimaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _passwordController,
                    label: 'New Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KprimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isUploading ? null : _saveProfileChanges,
                      child: _isUploading
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          :  Text(
                              'Save Changes',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: KprimaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: KprimaryColor),
        ),
      ),
    );
  }

  Future<void> _showRoleSwitchDialog(bool newValue) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Account Type'),
        content: Text(
          'Are you sure you want to switch to ${newValue ? 'Tenant' : 'Customer'} mode? '
          'You will need to log in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Switch', style: TextStyle(color: KprimaryColor)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _switchRole(newValue);
    }
  }
}
