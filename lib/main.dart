import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/i18n.dart';
import './screens/screens.dart';
import './services/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          value: AuthService().user,
          catchError: (context, obj) => null,
        ),
        StreamProvider<List<Attendee>>.value(
          value: Global.attendeesRef.streamData(),
          catchError: (context, obj) => null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          S.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: S.delegate.supportedLocales,
        title: 'QR Navidad',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          buttonTheme: ButtonThemeData(),
        ),
        routes: {
          '/': (context) => HomePage(),
          '/scan': (context) => ScanPage(),
        },
      ),
    );
  }
}
