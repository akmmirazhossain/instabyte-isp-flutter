import 'package:flutter/material.dart';

class SubmitIssue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // You can customize the container's styling if needed
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Submit issue component.',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: SubmitIssue(),
    ),
  ));
}
