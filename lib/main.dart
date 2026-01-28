import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My AppBar'),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 19, 221, 79),
        ),
        body: const Center(
          child: Text(
            'Hello Flutter',
            style: TextStyle(fontSize: 20),
            
          ),
        ),
      ),
    );
  }
}
