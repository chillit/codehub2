import 'package:duolingo/l10n/l10n.dart';
import 'package:duolingo/src/home/login/login_page.dart';
import 'package:duolingo/src/home/main_screen/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale("en"); // Добавьте поле для хранения локализации

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      supportedLocales: L10n.all,
      locale: _locale,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      title: "Code-Hub",
      theme: ThemeData(primaryColor: Colors.white),
      home: AuthChecker(setLocale: setLocale,),
    );
  }
}


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if the user is already logged in.
  Future<bool> isLoggedIn() async {
    final user = _auth.currentUser;
    return user != null;
  }

  // Sign in with email and password.
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      return user?.uid;
    } catch (e) {
      return null; // Handle authentication errors here.
    }
  }

  // Sign out the user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
class AuthChecker extends StatefulWidget {
  final Function(Locale) setLocale;

  const AuthChecker({Key? key, required this.setLocale}) : super(key: key);

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  void initState(){
    super.initState();
    _fetchUserData();
  }
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUserUID = "";
  String locale = "";
  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      currentUserUID = user.uid;

      final localeRef = _database.reference().child('users/$currentUserUID/locale');
      final languageRef = _database.reference().child('users/$currentUserUID/language');


      DatabaseEvent localeSnapshot = await localeRef.once();
      locale = localeSnapshot.snapshot.value?.toString() ?? '';
      widget.setLocale(Locale("$locale"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<bool>(
      future: authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Loading indicator while checking login status.
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? Home() : LoginPage(setLocale: widget.setLocale,);
        }
      },
    );
  }
}