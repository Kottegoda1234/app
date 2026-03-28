import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'second.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AppBody());
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
  final supabase = Supabase.instance.client;

  double currentUnits = 0, currentRate = 0, currentFixed = 0, currentTotal = 0;

  // 🔥 INPUT STYLE
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

  // CREATE
  void calculateAndInsert() async {
    double u = double.tryParse(unitsController.text) ?? 0;
    double r = double.tryParse(rateController.text) ?? 0;
    double f = double.tryParse(fixedController.text) ?? 0;
    double t = (u * r) + f;

    setState(() {
      currentUnits = u;
      currentRate = r;
      currentFixed = f;
      currentTotal = t;
    });

    try {
      await supabase.from('bills').insert({
        'units': u,
        'rate': r,
        'fixed': f,
        'total': t
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved!')),
        );
      }

      setState(() {});
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // READ
  Future<List<Map<String, dynamic>>> fetchBills() async {
    try {
      final List<dynamic> data = await supabase
          .from('bills')
          .select()
          .order('id', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF64B5F6)],
          begin: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Electricity Bill Manager",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Icon(
              Icons.lightbulb_outline,
              color: Color.fromARGB(255, 252, 192, 29),
              size: 80,
            ),

            const SizedBox(height: 10),

            // INPUT CARD
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: unitsController,
                        keyboardType: TextInputType.number,
                        decoration:
                            inputStyle("Units", Icons.electric_meter),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: rateController,
                        keyboardType: TextInputType.number,
                        decoration:
                            inputStyle("Rate", Icons.attach_money),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: fixedController,
                        keyboardType: TextInputType.number,
                        decoration:
                            inputStyle("Fixed Charge", Icons.receipt_long),
                      ),

                      const SizedBox(height: 15),

                      // BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: calculateAndInsert,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 7, 172, 255),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Save"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => ResultPage(
                                    units: currentUnits,
                                    rate: currentRate,
                                    fixed: currentFixed,
                                    total: currentTotal,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("View"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            // LIST (ONLY VIEW - NO EDIT/DELETE)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchBills(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, i) {
                      final b = snapshot.data![i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text("Total: Rs. ${b['total']}"),
                          subtitle: Text(
                              "U: ${b['units']} | R: ${b['rate']}"),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}