import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roy_mariane_mobile/providers/user_provider.dart';
import 'package:roy_mariane_mobile/responsive/mobile_screen_layout.dart';
import 'package:roy_mariane_mobile/responsive/responsive_layout_screen.dart';
import 'package:roy_mariane_mobile/responsive/web_screen_layout.dart';
import 'package:roy_mariane_mobile/screens/login_screen.dart';
import 'package:roy_mariane_mobile/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: "AIzaSyB9pFYC8RNRwP38IAs87PA1V2f2C8F-Ecg",
      authDomain: "mobileproject-97bbf.firebaseapp.com",
      projectId: "mobileproject-97bbf",
      storageBucket: "mobileproject-97bbf.appspot.com",
      messagingSenderId: "790427819678",
      appId: "1:790427819678:web:1e4cc2c0d3407eddb7658f")
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Clone',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              // Checking if the snapshot has any data or not
              if (snapshot.hasData) {
                // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            // means connection to future hasnt been made yet
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
