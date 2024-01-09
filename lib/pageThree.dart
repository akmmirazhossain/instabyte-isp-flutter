import 'package:flutter/material.dart';

class PageThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.three_k,
            size: 100,
            color: Colors.red,
          ),
          SizedBox(height: 20),
          Text(
            'Page Three Content',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
