import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sayf/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

final supabase = Supabase.instance.client;

class AddEditProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AddEditProductPage({super.key, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _imageBytes;
  String? _imageName;
  String? _uploadedImageUrl;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  int? _selectedCategoryId;
  String? _selectedCity;

  Map<int, String> categories = {}; // ✅ Fetched from Supabase

  final List<String> moroccanCities = [
    'Agadir',
    'Casablanca',
    'Marrakech',
    'Rabat',
    'Tanger',
    'Fès',
    'Tétouan',
    'Oujda',
    'Laâyoune',
    'Dakhla',
  ];

  @override
  void initState() {
    super.initState();
    fetchCategories(); // ✅ Fetch categories first

    final product = widget.product;
    if (product != null) {
      _nameController.text = product['name'] ?? '';
      _descController.text = product['description'] ?? '';
      _priceController.text = product['price']?.toString() ?? '';
      _uploadedImageUrl = product['image'];

      final catId = product['category_id'];
      if (catId is int) _selectedCategoryId = catId;
      else if (catId is String) _selectedCategoryId = int.tryParse(catId);

      final city = product['address'];
      if (city != null && moroccanCities.contains(city)) {
        _selectedCity = city;
      }
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('category').select();
      final Map<int, String> loadedCategories = {};
      for (final item in response) {
        loadedCategories[item['id']] = item['name'];
      }
      setState(() {
        categories = loadedCategories;
      });
    } catch (e) {
      print('Erreur chargement catégories: $e');
    }
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
      final response = await supabase.storage
          .from('products')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      if (response.isEmpty) return null;
      return supabase.storage.from('products').getPublicUrl(fileName);
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null || _selectedCity == null) return;

    String? imageUrl = _uploadedImageUrl;

    if (_imageBytes != null && _imageName != null) {
      final ext = p.extension(_imageName!);
      final fileName = '${const Uuid().v4()}$ext';
      imageUrl = await uploadImage(_imageBytes!, fileName);
    }

    final data = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'category_id': _selectedCategoryId,
      'image': imageUrl,
      'address': _selectedCity,
      'tenant_id': supabase.auth.currentUser!.id,
    };

    try {
      if (widget.product == null) {
        await supabase.from('products').insert(data);
      } else {
        await supabase.from('products').update(data).eq('id', widget.product!['id']);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      print('Erreur de sauvegarde: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: KaccentColor,
      elevation: 0,
      title: Text(
        widget.product == null ? '🆕 Ajouter un produit' : '✏️ Modifier le produit',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      )
                    : (_uploadedImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(_uploadedImageUrl!, fit: BoxFit.cover),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Appuyez pour ajouter une image', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )),
              ),
            ),
            const SizedBox(height: 25),
            _buildTextField(_nameController, 'Nom du produit', Icons.shopping_bag),
            const SizedBox(height: 15),
            _buildTextField(_descController, 'Description', Icons.description),
            const SizedBox(height: 15),
            _buildTextField(_priceController, 'Prix en DH', Icons.price_change, isNumber: true),
            const SizedBox(height: 15),
            _buildDropdownCategory(),
            const SizedBox(height: 15),
            _buildDropdownCity(),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: saveProduct,
              icon: const Icon(Icons.save_alt),
              label: const Text(
                'Enregistrer le produit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: KaccentColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 6,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTextField(TextEditingController controller, String label, IconData icon,
    {bool isNumber = false}) {
  return TextFormField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade100,
    ),
    validator: (val) => val == null || val.isEmpty ? 'Ce champ est requis' : null,
  );
}

Widget _buildDropdownCategory() {
  return DropdownButtonFormField<int>(
    value: _selectedCategoryId,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.category),
      labelText: 'Catégorie',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade100,
    ),
    items: categories.entries
        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
        .toList(),
    onChanged: (v) => setState(() => _selectedCategoryId = v),
    validator: (v) => v == null ? 'Sélectionnez une catégorie' : null,
  );
}

Widget _buildDropdownCity() {
  return DropdownButtonFormField<String>(
    value: _selectedCity,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.location_city),
      labelText: 'Ville',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade100,
    ),
    items: moroccanCities
        .map((city) => DropdownMenuItem(value: city, child: Text(city)))
        .toList(),
    onChanged: (value) => setState(() => _selectedCity = value),
    validator: (value) => value == null ? 'Sélectionnez une ville' : null,
  );
}
}