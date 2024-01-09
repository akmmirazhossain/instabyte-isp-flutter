import 'package:flutter/material.dart';

class PingIpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ping IP'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This section is under development.',
              style: TextStyle(fontSize: 18),
            ),
            // Add any other widgets or functionality related to Ping IP here
          ],
        ),
      ),
    );
  }
}
