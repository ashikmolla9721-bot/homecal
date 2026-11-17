import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

class KhataScreen extends StatefulWidget {
  const KhataScreen({super.key});

  @override
  State<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends State<KhataScreen> {
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('customers_list');
      if (data != null) {
        final List decoded = jsonDecode(data);
        setState(() {
          _customers = decoded.map((e) => Customer.fromJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('customers_list', jsonEncode(_customers.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void _addOrUpdateCustomer({Customer? customer}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final amountController = TextEditingController(text: customer != null ? customer.balance.abs().toString() : '');
    bool isDue = customer == null ? true : customer.balance >= 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(customer == null ? 'নতুন কাস্টমার যোগ করুন' : 'হিসাব আপডেট করুন'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'কাস্টমারের নাম')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর'), keyboardType: TextInputType.phone),
                TextField(controller: amountController, decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)'), keyboardType: TextInputType.number),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('বাকী (পাবে)'),
                      selected: isDue,
                      onSelected: (val) => setDialogState(() => isDue = true),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('জমা (দিবে)'),
                      selected: !isDue,
                      onSelected: (val) => setDialogState(() => isDue = false),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  double amount = double.tryParse(amountController.text) ?? 0.0;
                  double finalBalance = isDue ? amount : -amount;

                  setState(() {
                    if (customer == null) {
                      _customers.insert(0, Customer(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        balance: finalBalance,
                      ));
                    } else {
                      customer.name = nameController.text.trim();
                      customer.phone = phoneController.text.trim();
                      customer.balance = finalBalance;
                    }
                    _saveCustomers();
                  });
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('সংরক্ষণ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalDue = _customers.where((c) => c.balance > 0).fold(0.0, (sum, c) => sum + c.balance);
    double totalAdvance = _customers.where((c) => c.balance < 0).fold(0.0, (sum, c) => sum + c.balance.abs());

    return Scaffold(
      appBar: AppBar(title: const Text('বাকির খাতা - কাস্টমার হিসাব'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.shade50.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('মোট বাকী (পাবে)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    Text('৳ $totalDue', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('মোট জমা (দিবে)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text('৳ $totalAdvance', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _customers.isEmpty
                ? const Center(child: Text('কোনো কাস্টমার যোগ করা হয়নি', style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView.builder(
                    itemCount: _customers.length,
                    itemBuilder: (context, index) {
                      final cust = _customers[index];
                      bool due = cust.balance >= 0;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(cust.phone.isNotEmpty ? cust.phone : 'নম্বর নেই'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(due ? 'পাবে: ৳${cust.balance}' : 'জমা: ৳${cust.balance.abs()}',
                                  style: TextStyle(color: due ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _addOrUpdateCustomer(customer: cust),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _customers.removeAt(index);
                                    _saveCustomers();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrUpdateCustomer(),
        label: const Text('কাস্টমার যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.person_add, color: Colors.white),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
