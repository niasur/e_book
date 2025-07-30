import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_data.dart';

class ProductInputScreen extends StatefulWidget {
  const ProductInputScreen({Key? key}) : super(key: key);

  @override
  State<ProductInputScreen> createState() => _ProductInputScreenState();
}

class _ProductInputScreenState extends State<ProductInputScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _author = '';
  String _description = '';
  String _imageUrl = '';
  double _price = 0.0;
  bool _isLoading = false;
  List<String> _selectedCategoryIds = [];

  Future<void> _saveProduct() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua field dan pilih kategori')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'title': _title,
        'author': _author,
        'description': _description,
        'imageUrl': _imageUrl,
        'price': _price,
        'category': _selectedCategoryIds, // array kategori
        'createdAt': Timestamp.now(),
      });
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan produk: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, Color color) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: color),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
      ),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF009688) : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: _buildInputDecoration('Title', Icons.title, primaryColor),
                      onSaved: (value) => _title = value ?? '',
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Masukkan judul' : null,
                      cursorColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: _buildInputDecoration('Author', Icons.person, primaryColor),
                      onSaved: (value) => _author = value ?? '',
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Masukkan nama penulis' : null,
                      cursorColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: _buildInputDecoration('Description', Icons.description, primaryColor),
                      maxLines: 3,
                      onSaved: (value) => _description = value ?? '',
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Masukkan deskripsi' : null,
                      cursorColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: _buildInputDecoration('Image URL', Icons.image, primaryColor),
                      onSaved: (value) => _imageUrl = value ?? '',
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Masukkan URL gambar' : null,
                      cursorColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: _buildInputDecoration('Price', Icons.money, primaryColor),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _price = double.tryParse(value ?? '') ?? 0.0,
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Masukkan harga valid';
                        }
                        return null;
                      },
                      cursorColor: primaryColor,
                    ),
                    const SizedBox(height: 16),

                    // MULTI CATEGORY SELECTION
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pilih Kategori',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: DUMMY_CATEGORIES.map((cat) {
                        final isSelected = _selectedCategoryIds.contains(cat.id);
                        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

                        return ChoiceChip(
                          label: Text(
                            cat.title,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDarkMode ? Colors.white : Colors.black),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategoryIds.add(cat.id);
                              } else {
                                _selectedCategoryIds.remove(cat.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                        onPressed: _saveProduct,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}