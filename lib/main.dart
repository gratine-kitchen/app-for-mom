import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AppForMom());
}

class AppForMom extends StatelessWidget {
  const AppForMom({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App for Mom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'System',
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Saturday, July 26, 2026',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

