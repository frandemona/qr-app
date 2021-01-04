import 'package:flutter/material.dart';

class Headline extends StatelessWidget {
  final String message;

  Headline({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message,
        textAlign: TextAlign.left,
        style: TextStyle(
            // background: Paint()..color.green,
            // color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20.0));
  }
}

class CommonText extends StatelessWidget {
  final String message;

  CommonText({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message, style: TextStyle(fontSize: 20.0));
  }
}

class CommonTextSmall extends StatelessWidget {
  final String message;

  CommonTextSmall({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message, style: TextStyle(fontSize: 16.0));
  }
}

class CommonTextBold extends StatelessWidget {
  final String message;

  CommonTextBold({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 19.0,
      ),
    );
  }
}

class CommonTextLarge extends StatelessWidget {
  final String message;

  CommonTextLarge({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        fontSize: 24.0,
      ),
    );
  }
}

class HeadlineBold extends StatelessWidget {
  final String message;

  HeadlineBold({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
    );
  }
}
