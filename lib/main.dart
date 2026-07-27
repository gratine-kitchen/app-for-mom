import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/passcode_screen.dart';
import 'services/firestore_service.dart';
import 'services/firestore_service_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('zh_TW', null);

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
    final home = HomeScreen(firestoreService: firestoreService);

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
      // On web, require a shared family passcode before showing the home screen.
      // Native apps (iOS/Android) skip this gate since only trusted devices
      // have the app installed.
      home: kIsWeb ? PasscodeGate(child: home) : home,
    );
  }
}

