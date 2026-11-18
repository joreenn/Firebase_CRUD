import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'crud_service.dart';
import 'firebase_options.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final options = DefaultFirebaseOptions.currentPlatform;
  await Firebase.initializeApp(options: options);

  final firestore = FirebaseFirestore.instance;
  if (options.projectId.startsWith('demo-')) {
    firestore.useFirestoreEmulator(
      const String.fromEnvironment('FIRESTORE_HOST', defaultValue: '10.0.2.2'),
      8080,
      automaticHostMapping: false,
    );
  }

  runApp(MyApp(crudService: CrudService(firestore)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.crudService});

  final CrudService crudService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(crudService: crudService),
    );
  }
}
