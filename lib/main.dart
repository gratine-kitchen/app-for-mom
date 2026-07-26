import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/firestore_service.dart';
import 'services/firestore_service_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestoreService = FirestoreServiceImpl();

  runApp(AppForMom(firestoreService: firestoreService));
}

class AppForMom extends StatelessWidget {
  final FirestoreService firestoreService;

  const AppForMom({super.key, required this.firestoreService});

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
      ),
      home: HomeScreen(firestoreService: firestoreService),
    );
  }
}

