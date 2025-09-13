import 'package:flutter/material.dart';
import 'package:flutter_application/presentation/screens/auth/create_account.dart';
import 'presentation/screens/auth/sign_in.dart';
import 'presentation/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Widget> _getInitialScreen() async {
    return const SignIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARE',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'HvDTrial Brandon Grotesque',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFFFC800),
              width: 2,
            ),
          ),
          floatingLabelStyle: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Color(0xFFFFC800),
          circularTrackColor: Colors.grey[200],
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFFFFC800),
          selectionColor: Color(0xFFFFC800).withOpacity(0.3),
          selectionHandleColor: Color(0xFFFFC800),
        ),
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      routes: {
        '/home': (context) => const Home(),
        '/sign-in': (context) => const SignIn(),
        '/create-account': (context) => Create(),
      },
    );
  }
}
