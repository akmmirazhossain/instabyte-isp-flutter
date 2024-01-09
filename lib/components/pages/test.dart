import 'package:flutter/material.dart';

class MyComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightBlue,
      padding: EdgeInsets.all(16),
      child: Text(
        'This is my simple component',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
