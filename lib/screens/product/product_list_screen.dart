import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Expanded(
                child: Text('Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              FilledButton.icon(
                onPressed: () => _showProductDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Product'),
              ),
            ],
          ),
        ),

        // Product Grid
        Expanded(
          child: Consumer<ProductProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No products yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Add your first product', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.fetchProducts(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    return _ProductCard(
                      product: provider.products[index],
                      onEdit: () => _showProductDialog(context, product: provider.products[index]),
                      onDelete: () => _confirmDelete(context, provider.products[index]),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showProductDialog(BuildContext context, {Product? product}) {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final modelController = TextEditingController(text: product?.model ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(isEdit ? Icons.edit : Icons.add_box, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                Text(
                  isEdit ? 'Edit Product' : 'Add Product',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                prefixIcon: Icon(Icons.inventory),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: 'Model *',
                prefixIcon: Icon(Icons.devices),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () async {
                  if (nameController.text.isEmpty || modelController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name and model are required'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  bool success;
                  if (isEdit) {
                    success = await context.read<ProductProvider>().updateProduct(
                      id: product.id,
                      name: nameController.text.trim(),
                      model: modelController.text.trim(),
                      description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                      category: categoryController.text.trim().isEmpty ? null : categoryController.text.trim(),
                    );
                  } else {
                    success = await context.read<ProductProvider>().createProduct(
                      name: nameController.text.trim(),
                      model: modelController.text.trim(),
                      description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                      category: categoryController.text.trim().isEmpty ? null : categoryController.text.trim(),
                    );
                  }

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEdit ? 'Product updated!' : 'Product added!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                icon: Icon(isEdit ? Icons.save : Icons.add),
                label: Text(isEdit ? 'Update Product' : 'Add Product'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[400]),
            const SizedBox(width: 8),
            const Text('Deactivate Product'),
          ],
        ),
        content: Text('Are you sure you want to deactivate "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ProductProvider>().deleteProduct(product.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({required this.product, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final totalWarranties = product.activeWarranties + product.expiringSoonWarranties + product.expiredWarranties;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                product.isActive ? Colors.purple.withOpacity(0.03) : Colors.grey.withOpacity(0.05),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: product.isActive
                              ? [Colors.purple.withOpacity(0.2), Colors.indigo.withOpacity(0.1)]
                              : [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.category,
                        color: product.isActive ? Colors.purple : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              if (!product.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Inactive',
                                      style: TextStyle(fontSize: 11, color: Colors.red)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Model: ${product.model}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          if (product.category != null)
                            Text(
                              'Category: ${product.category}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Row(
                          children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
                        )),
                        const PopupMenuItem(value: 'delete', child: Row(
                          children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8),
                            Text('Deactivate', style: TextStyle(color: Colors.red))],
                        )),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                    ),
                  ],
                ),
                if (totalWarranties > 0) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      _buildWarrantyBadge('Active', product.activeWarranties, Colors.green),
                      const SizedBox(width: 8),
                      _buildWarrantyBadge('Expiring', product.expiringSoonWarranties, Colors.orange),
                      const SizedBox(width: 8),
                      _buildWarrantyBadge('Expired', product.expiredWarranties, Colors.red),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarrantyBadge(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
            ),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}
