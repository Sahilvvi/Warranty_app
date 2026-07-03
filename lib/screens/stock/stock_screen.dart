import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/stock_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/stock_model.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStocks();
    });
  }

  void _loadStocks() {
    final role = context.read<AuthProvider>().role;
    final stockProvider = context.read<StockProvider>();

    if (role == 'Admin' || role == 'Manufacturer') {
      stockProvider.fetchManufacturerStocks();
    }
    if (role == 'Admin' || role == 'Distributor') {
      stockProvider.fetchDistributorStocks();
    }
    if (role == 'Admin' || role == 'Dealer') {
      stockProvider.fetchDealerStocks();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.factory), text: 'Manufacturer'),
              Tab(icon: Icon(Icons.local_shipping), text: 'Distributor'),
              Tab(icon: Icon(Icons.storefront), text: 'Dealer'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ManufacturerStockTab(),
              _DistributorStockTab(),
              _DealerStockTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManufacturerStockTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Manufacturer Stock',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddManufacturerDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.manufacturerStocks.isEmpty
                  ? _buildEmptyState('No manufacturer stock entries')
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchManufacturerStocks(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: provider.manufacturerStocks.length,
                        itemBuilder: (context, index) {
                          final stock = provider.manufacturerStocks[index];
                          return _ManufacturerStockCard(stock: stock);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  void _showAddManufacturerDialog(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
    if (productProvider.products.isEmpty) {
      productProvider.fetchProducts();
    }

    int? selectedProductId;
    final quantityController = TextEditingController();
    final batchController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Add Manufacturer Stock',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Consumer<ProductProvider>(
                builder: (_, pp, __) => DropdownButtonFormField<int>(
                  value: selectedProductId,
                  decoration: const InputDecoration(labelText: 'Product *', prefixIcon: Icon(Icons.category)),
                  items: pp.products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (v) => setModalState(() => selectedProductId = v),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity *', prefixIcon: Icon(Icons.numbers)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: batchController,
                decoration: const InputDecoration(labelText: 'Batch Number', prefixIcon: Icon(Icons.tag)),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setModalState(() => selectedDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Manufactured Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () async {
                    if (selectedProductId == null || quantityController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill required fields'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    final success = await context.read<StockProvider>().createManufacturerStock(
                          productId: selectedProductId!,
                          quantity: int.parse(quantityController.text),
                          batchNumber: batchController.text.isEmpty ? null : batchController.text,
                          manufacturedDate: selectedDate,
                        );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Stock added successfully!'), backgroundColor: Colors.green),
                        );
                      }
                    }
                  },
                  child: const Text('Add Stock'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManufacturerStockCard extends StatelessWidget {
  final ManufacturerStock stock;
  const _ManufacturerStockCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.indigo.withOpacity(0.05), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.factory, color: Colors.indigo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Batch: ${stock.batchNumber ?? "N/A"}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    Text('Date: ${DateFormat('dd MMM yyyy').format(stock.manufacturedDate)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Qty: ${stock.quantity}',
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistributorStockTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Distributor Stock',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddDistributorDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.distributorStocks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No distributor stock entries',
                              style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchDistributorStocks(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: provider.distributorStocks.length,
                        itemBuilder: (context, index) {
                          final stock = provider.distributorStocks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [Colors.amber.withOpacity(0.05), Colors.transparent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.local_shipping, color: Colors.amber[800]),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(stock.productName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                          const SizedBox(height: 4),
                                          Text('Distributor: ${stock.distributorName}',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                          Text('Received: ${DateFormat('dd MMM yyyy').format(stock.receivedDate)}',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Qty: ${stock.quantity}',
                                        style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddDistributorDialog(BuildContext context) {
    final stockProvider = context.read<StockProvider>();
    final productProvider = context.read<ProductProvider>();
    if (productProvider.products.isEmpty) productProvider.fetchProducts();

    int? selectedMfgStockId;
    int? selectedProductId;
    final quantityController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text('Add Distributor Stock',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Consumer<StockProvider>(
                builder: (_, sp, __) => DropdownButtonFormField<int>(
                  value: selectedMfgStockId,
                  decoration: const InputDecoration(labelText: 'From Manufacturer Stock *', prefixIcon: Icon(Icons.factory)),
                  items: sp.manufacturerStocks.map((s) => DropdownMenuItem(
                    value: s.id, child: Text('${s.productName} (Batch: ${s.batchNumber ?? "N/A"})'))).toList(),
                  onChanged: (v) => setModalState(() => selectedMfgStockId = v),
                ),
              ),
              const SizedBox(height: 12),
              Consumer<ProductProvider>(
                builder: (_, pp, __) => DropdownButtonFormField<int>(
                  value: selectedProductId,
                  decoration: const InputDecoration(labelText: 'Product *', prefixIcon: Icon(Icons.category)),
                  items: pp.products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (v) => setModalState(() => selectedProductId = v),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity *', prefixIcon: Icon(Icons.numbers)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(context: ctx, initialDate: selectedDate,
                    firstDate: DateTime(2000), lastDate: DateTime.now());
                  if (date != null) setModalState(() => selectedDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Received Date *', prefixIcon: Icon(Icons.calendar_today)),
                  child: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 48,
                child: FilledButton(
                  onPressed: () async {
                    if (selectedMfgStockId == null || selectedProductId == null || quantityController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fill all required fields'), backgroundColor: Colors.red));
                      return;
                    }
                    final success = await stockProvider.createDistributorStock(
                      manufacturerStockId: selectedMfgStockId!,
                      productId: selectedProductId!,
                      quantity: int.parse(quantityController.text),
                      receivedDate: selectedDate,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Distributor stock added!'), backgroundColor: Colors.green));
                      }
                    }
                  },
                  child: const Text('Add Stock'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DealerStockTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Dealer Stock',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddDealerDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.dealerStocks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No dealer stock entries', style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchDealerStocks(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: provider.dealerStocks.length,
                        itemBuilder: (context, index) {
                          final stock = provider.dealerStocks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [Colors.teal.withOpacity(0.05), Colors.transparent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: Colors.teal.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.storefront, color: Colors.teal),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(stock.productName,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              Text(stock.dealerName,
                                                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      children: [
                                        _buildInfoChip(Icons.devices, 'Model: ${stock.model}'),
                                        const SizedBox(width: 8),
                                        _buildInfoChip(Icons.tag, 'SN: ${stock.serialNumber}'),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _buildInfoChip(Icons.receipt, 'Inv: ${stock.invoiceNo}'),
                                        const SizedBox(width: 8),
                                        _buildInfoChip(Icons.calendar_today,
                                            DateFormat('dd MMM yyyy').format(stock.date)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showAddDealerDialog(BuildContext context) {
    final stockProvider = context.read<StockProvider>();
    final productProvider = context.read<ProductProvider>();
    if (productProvider.products.isEmpty) productProvider.fetchProducts();

    int? selectedDistStockId;
    int? selectedProductId;
    final modelController = TextEditingController();
    final invoiceController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text('Add Dealer Stock',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Consumer<StockProvider>(
                builder: (_, sp, __) => DropdownButtonFormField<int>(
                  value: selectedDistStockId,
                  decoration: const InputDecoration(labelText: 'From Distributor Stock *', prefixIcon: Icon(Icons.local_shipping)),
                  items: sp.distributorStocks.map((s) => DropdownMenuItem(
                    value: s.id, child: Text('${s.productName} (${s.distributorName})'))).toList(),
                  onChanged: (v) => setModalState(() => selectedDistStockId = v),
                ),
              ),
              const SizedBox(height: 12),
              Consumer<ProductProvider>(
                builder: (_, pp, __) => DropdownButtonFormField<int>(
                  value: selectedProductId,
                  decoration: const InputDecoration(labelText: 'Product *', prefixIcon: Icon(Icons.category)),
                  items: pp.products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (v) => setModalState(() => selectedProductId = v),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model *', prefixIcon: Icon(Icons.devices)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: invoiceController,
                decoration: const InputDecoration(labelText: 'Invoice Number *', prefixIcon: Icon(Icons.receipt)),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(context: ctx, initialDate: selectedDate,
                    firstDate: DateTime(2000), lastDate: DateTime.now());
                  if (date != null) setModalState(() => selectedDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date *', prefixIcon: Icon(Icons.calendar_today)),
                  child: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 48,
                child: FilledButton(
                  onPressed: () async {
                    if (selectedDistStockId == null || selectedProductId == null ||
                        modelController.text.isEmpty || invoiceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fill all required fields'), backgroundColor: Colors.red));
                      return;
                    }
                    final success = await stockProvider.createDealerStock(
                      distributorStockId: selectedDistStockId!,
                      productId: selectedProductId!,
                      date: selectedDate,
                      model: modelController.text,
                      invoiceNo: invoiceController.text,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dealer stock added!'), backgroundColor: Colors.green));
                      }
                    }
                  },
                  child: const Text('Add Stock'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
