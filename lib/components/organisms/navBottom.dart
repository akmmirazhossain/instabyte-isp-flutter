import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Adjust the height as needed
      decoration: BoxDecoration(
        color: Colors.blue, // Change the background color as needed
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi_find, size: 32), // Increase the icon size
            label: 'Check WiFi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.network_ping, size: 32), // Increase the icon size
            label: 'Ping IP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback, size: 32), // Increase the icon size
            label: 'Submit Issue',
          ),
        ],
      ),
    );
  }
}
