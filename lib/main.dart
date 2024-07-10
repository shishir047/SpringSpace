import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:spring_space/providers/user_providers.dart';
import 'screens/splash_screen.dart';
import 'util/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyC1n1nlMtDc11lx1oZqh53-1x0AsGRyb-s',
        appId: '1:809607834498:web:faf770c1c861f1b032bd9b',
        messagingSenderId: '809607834498',
        projectId: 'springspace-firebase',
        storageBucket: 'springspace-firebase.appspot.com',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Spring Space',
        theme: customThemeData,
        home: const SplashScreen(),
      ),
    );
  }
}
