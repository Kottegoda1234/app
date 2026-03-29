import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'second.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ykjpwcwxbiscvdsoxglx.supabase.co',
    anonKey: 'sb_publishable_I0htRulKH7DYJZezEmD4wA_OISC61Ci',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Moved background to Scaffold for better UI management
      body: AppBody(),
    );
  }
}

class AppBody extends StatefulWidget {
  const AppBody({super.key});

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  final TextEditingController unitsController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController fixedController = TextEditingController();
  
  // Use a getter for the client to ensure it's always ready
  SupabaseClient get supabase => Supabase.instance.client;

  double currentUnits = 0, currentRate = 0, currentFixed = 0, currentTotal = 0;

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // -----------------------------CREATE---------------------------------
  void calculateAndInsert() async {
    double u = double.tryParse(unitsController.text) ?? 0;
    double r = double.tryParse(rateController.text) ?? 0;
    double f = double.tryParse(fixedController.text) ?? 0;
    double t = (u * r) + f;

    try {
      await supabase.from('bills').insert({
        'units': u,
        'rate': r,
        'fixed': f,
        'total': t,
      });

      if (mounted) {
        setState(() {
          currentUnits = u;
          currentRate = r;
          currentFixed = f;
          currentTotal = t;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved Successfully!')),
        );
        // Clear fields after save
        unitsController.clear();
        rateController.clear();
        fixedController.clear();
      }
    } catch (e) {
      debugPrint("Error inserting: $e");
    }
  }

  //----------------------------------- READ------------------------------------
  Future<List<Map<String, dynamic>>> fetchBills() async {
    try {
      final data = await supabase
          .from('bills')
          .select()
          .order('id', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint("Fetch error: $e");
      return [];
    }
  }

  //-------------------------------------- UPDATE---
  void showUpdateDialog(Map<String, dynamic> bill) {
    final uEdit = TextEditingController(text: bill['units'].toString());
    final rEdit = TextEditingController(text: bill['rate'].toString());
    final fEdit = TextEditingController(text: bill['fixed'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Bill"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: uEdit, keyboardType: TextInputType.number, decoration: inputStyle("Units", Icons.electric_meter)),
              const SizedBox(height: 12),
              TextField(controller: rEdit, keyboardType: TextInputType.number, decoration: inputStyle("Rate", Icons.attach_money)),
              const SizedBox(height: 12),
              TextField(controller: fEdit, keyboardType: TextInputType.number, decoration: inputStyle("Fixed Charge", Icons.receipt_long)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              double u = double.tryParse(uEdit.text) ?? 0;
              double r = double.tryParse(rEdit.text) ?? 0;
              double f = double.tryParse(fEdit.text) ?? 0;
              double t = (u * r) + f;

              await supabase.from('bills').update({
                'units': u, 'rate': r, 'fixed': f, 'total': t
              }).eq('id', bill['id']);

              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  //---------------------------------- DELETE---------------------------------------
  void deleteBill(int id) async {
    try {
      await supabase.from('bills').delete().eq('id', id);
      setState(() {});
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF64B5F6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Electricity Bill Manager",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const Icon(Icons.lightbulb, color: Colors.amber, size: 60),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(controller: unitsController, keyboardType: TextInputType.number, decoration: inputStyle("Units", Icons.electric_meter)),
                      const SizedBox(height: 12),
                      TextField(controller: rateController, keyboardType: TextInputType.number, decoration: inputStyle("Rate", Icons.attach_money)),
                      const SizedBox(height: 12),
                      TextField(controller: fixedController, keyboardType: TextInputType.number, decoration: inputStyle("Fixed Charge", Icons.receipt_long)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: calculateAndInsert,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                              child: const Text("Save"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (c) => ResultPage(
                                  units: currentUnits, rate: currentRate, fixed: currentFixed, total: currentTotal,
                                )),
                              ),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
                              child: const Text("View Last"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchBills(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  final bills = snapshot.data ?? [];
                  if (bills.isEmpty) {
                    return const Center(child: Text("No bills found.", style: TextStyle(color: Colors.white)));
                  }
                  return ListView.builder(
                    itemCount: bills.length,
                    itemBuilder: (context, i) {
                      final b = bills[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text("Total: Rs. ${b['total']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("U: ${b['units']} | R: ${b['rate']} | F: ${b['fixed']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => showUpdateDialog(b)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deleteBill(b['id'])),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}