import 'package:flutter/material.dart';

class PageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.two_k,
            size: 100,
            color: Colors.green,
          ),
          SizedBox(height: 20),
          Text(
            'Page Two Conten ad wadt',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
