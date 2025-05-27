import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize OneSignal with verbose logging
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  
  // Configure OneSignal
  OneSignal.initialize("74db709b-8690-49ce-8a70-7c0e15913f3c");
  
  // Request permission for notifications
  OneSignal.Notifications.requestPermission(true);
  
  // Handle notification opened
  OneSignal.Notifications.addClickListener((event) {
    print("Notification clicked: ${event.notification.title}");
  });

  // Handle notification received while app is in foreground
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("Notification received in foreground: ${event.notification.title}");
    event.preventDefault();
    event.notification.display();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriCare AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF109640),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF109640)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
