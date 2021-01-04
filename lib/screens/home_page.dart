import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../shared/shared.dart';
import 'package:provider/provider.dart';
import '../services/auth.dart';

import '../generated/i18n.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService auth = AuthService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User firebaseUser = Provider.of<User>(context);
    if (firebaseUser != null) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Navigator.of(context).pushNamedAndRemoveUntil(
                '/scan',
                (_) => false,
              ));
    }

    if (firebaseUser == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[50], Colors.grey[350]],
          )),
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 360,
              ),
              child: ListView(
                children: <Widget>[
                  Card(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      constraints: BoxConstraints(
                        maxWidth: 280.0,
                      ),
                      child: Form(
                          child: Column(children: <Widget>[
                        RaisedButton(
                          child: Text(S.of(context).loginButton),
                          color: Colors.grey[850],
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0)),
                          textColor: Colors.white,
                          onPressed: () async {
                            try {
                              await auth.loginUser(
                                  email: 'francisco@mondey.co',
                                  password: 'probando123');
                            } on FirebaseAuthException catch (error) {
                              return _buildErrorDialog(context, error.message);
                            } on Exception catch (error) {
                              return _buildErrorDialog(
                                  context, error.toString());
                            }
                          },
                        ),
                      ])),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return LoadingScreen();
    }
  }

  Future _buildErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).errorMessageTitle),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text(S.of(context).dialogOk),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }
}
