import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/warranty_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/consumer_provider.dart';

class WarrantyRegisterScreen extends StatefulWidget {
  const WarrantyRegisterScreen({super.key});

  @override
  State<WarrantyRegisterScreen> createState() => _WarrantyRegisterScreenState();
}

class _WarrantyRegisterScreenState extends State<WarrantyRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _billNumberController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _vendorController = TextEditingController();

  int? _selectedProductId;
  int? _selectedConsumerId;
  DateTime _manufacturedDate = DateTime.now();
  String _selectedWarrantyPeriod = '1Year';
  String _selectedWarrantyType = 'Standard';
  File? _selectedPhoto;

  final List<Map<String, String>> _warrantyPeriods = [
    {'value': '6Months', 'label': '6 Months'},
    {'value': '1Year', 'label': '1 Year'},
    {'value': '2Years', 'label': '2 Years'},
  ];

  final List<Map<String, String>> _warrantyTypes = [
    {'value': 'Standard', 'label': 'Standard'},
    {'value': 'FullGuarantee', 'label': 'Full Guarantee'},
    {'value': 'Exchange', 'label': 'Exchange'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<ConsumerProvider>().fetchConsumers();
    });
  }

  @override
  void dispose() {
    _modelController.dispose();
    _billNumberController.dispose();
    _quantityController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 80);
      if (picked != null) {
        setState(() => _selectedPhoto = File(picked.path));
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _manufacturedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _manufacturedDate = date);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product'), backgroundColor: Colors.red),
      );
      return;
    }

    final provider = context.read<WarrantyProvider>();
    final success = await provider.registerWarranty(
      productId: _selectedProductId!,
      model: _modelController.text.trim(),
      manufacturedDate: _manufacturedDate,
      billNumber: _billNumberController.text.trim(),
      quantity: int.parse(_quantityController.text),
      vendor: _vendorController.text.trim().isEmpty ? null : _vendorController.text.trim(),
      warrantyPeriod: _selectedWarrantyPeriod,
      warrantyType: _selectedWarrantyType,
      consumerId: _selectedConsumerId,
      photo: _selectedPhoto,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Warranty registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Warranty'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Selection
              Text('Product *', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Consumer<ProductProvider>(
                builder: (context, productProvider, _) {
                  return DropdownButtonFormField<int>(
                    value: _selectedProductId,
                    decoration: const InputDecoration(
                      hintText: 'Select Product',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: productProvider.products.map((p) {
                      return DropdownMenuItem(value: p.id, child: Text(p.name));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedProductId = value),
                    validator: (value) => value == null ? 'Please select a product' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Model
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model *',
                  prefixIcon: Icon(Icons.devices),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Model is required' : null,
              ),
              const SizedBox(height: 16),

              // Manufactured Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Manufactured Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_manufacturedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Bill Number
              TextFormField(
                controller: _billNumberController,
                decoration: const InputDecoration(
                  labelText: 'Bill Number *',
                  prefixIcon: Icon(Icons.receipt),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Bill number is required' : null,
              ),
              const SizedBox(height: 16),

              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Quantity is required';
                  if (int.tryParse(v) == null || int.parse(v) < 1) return 'Enter valid quantity';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vendor
              TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  labelText: 'Vendor',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),

              // Warranty Period
              DropdownButtonFormField<String>(
                value: _selectedWarrantyPeriod,
                decoration: const InputDecoration(
                  labelText: 'Warranty Period *',
                  prefixIcon: Icon(Icons.access_time),
                ),
                items: _warrantyPeriods.map((p) {
                  return DropdownMenuItem(value: p['value'], child: Text(p['label']!));
                }).toList(),
                onChanged: (value) => setState(() => _selectedWarrantyPeriod = value!),
              ),
              const SizedBox(height: 16),

              // Warranty Type
              DropdownButtonFormField<String>(
                value: _selectedWarrantyType,
                decoration: const InputDecoration(
                  labelText: 'Warranty Type *',
                  prefixIcon: Icon(Icons.shield),
                ),
                items: _warrantyTypes.map((t) {
                  return DropdownMenuItem(value: t['value'], child: Text(t['label']!));
                }).toList(),
                onChanged: (value) => setState(() => _selectedWarrantyType = value!),
              ),
              const SizedBox(height: 16),

              // Consumer Selection
              Text('Consumer (Optional)', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Consumer<ConsumerProvider>(
                builder: (context, consumerProvider, _) {
                  return DropdownButtonFormField<int?>(
                    value: _selectedConsumerId,
                    decoration: const InputDecoration(
                      hintText: 'Select Consumer',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ...consumerProvider.consumers.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.name} (${c.mobileNumber})'),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() => _selectedConsumerId = value),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Photo Upload
              Text('Photo (Product/Bill)', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: _selectedPhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedPhoto!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: Colors.grey[500]),
                            const SizedBox(height: 8),
                            Text('Tap to upload photo', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Consumer<WarrantyProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _submit,
                      icon: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified),
                      label: Text(provider.isLoading ? 'Registering...' : 'Register Warranty'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
