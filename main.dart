import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepauth/core/theme/app_theme.dart';
import 'package:stepauth/firebase_options.dart';
import 'package:stepauth/presentation/screens/auth_gate.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    
    const ProviderScope(
      child: StepAuthApp(),
    ),
  );
}
class StepAuthApp extends StatelessWidget {
  const StepAuthApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
     
      home: const AuthGate(),
    );
  }
}
