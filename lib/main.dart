import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uilogin/domain/usecases/AuthUsecase.dart' as MyAppAuthProvider; 
import 'package:flutter_uilogin/presentation/screens/HomeScreen.dart';
import 'package:flutter_uilogin/presentation/screens/LoginScreen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MyAppAuthProvider.AuthProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Labolatorium FIT',
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx,snapshot){
              if(snapshot.hasData){
                return const HomePage();
              }
              return const LoginScreen();
            })
      ),
    ));
  }
}
