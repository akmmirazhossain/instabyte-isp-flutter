import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CheckWifi extends StatefulWidget {
  const CheckWifi({Key? key}) : super(key: key);

  @override
  _CheckWifiState createState() => _CheckWifiState();
}

class _CheckWifiState extends State<CheckWifi> {
  String message = '';
  static const int PORT = 80;
  int numberOfPings = 0;
  int defaultTotalPings = 40; // Default value for total pings
  Duration pingDelay = Duration(seconds: 1);
  List<String> pingMessages = [];
  bool isPinging = false;
  String wifiGateway = '142.250.193.132';
  TextEditingController totalPingsController = TextEditingController();
  double totalResponseTime = 0.0;
  ScrollController _scrollController = ScrollController();

  bool isWifiConnected = false; // Track Wi-Fi connectivity

  @override
  void initState() {
    super.initState();
    getWifiGateway();
    totalPingsController.text = defaultTotalPings.toString();
    _loadPreferences();
    checkWifiStatus(); // Check Wi-Fi status on initialization
  }

  Future<void> checkWifiStatus() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isWifiConnected = connectivityResult == ConnectivityResult.wifi;
    });
  }

  late SharedPreferences prefs;
  int currentIndex = 0;
  final List<String> tabNames = ["NetDoc", "Ping IP", "Profile"];

  void _showWifiNotConnectedModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wi-Fi Not Connected'),
          content:
              Text('Please connect to a Wi-Fi network and restart this app.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                exit(0); // Close the app
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> getWifiGateway() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      setState(() {
        wifiGateway = 'Location permission denied.';
      });
      return;
    }

    final info = NetworkInfo();
    try {
      final wifiGatewayIP = await info.getWifiGatewayIP();
      setState(() {
        wifiGateway = wifiGatewayIP ?? 'Not available';
      });
    } catch (e) {
      setState(() {
        wifiGateway = 'Error: $e';
      });
    }
  }

  _launchDefaultGatewayUrl() async {
    final url = wifiGateway != null
        ? 'http://$wifiGateway'
        : 'Fallback URL when wifiGateway is null';
    // Assuming wifiGateway contains the IP address
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      totalPingsController.text =
          prefs.getString('totalPings') ?? defaultTotalPings.toString();
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showWifiNotConnectedModal();
    }
  }

  _savePreferences() async {
    await prefs.setString('totalPings', totalPingsController.text);
  }

  Future<void> establishSocketConnection() async {
    if (!isWifiConnected) {
      _showWifiNotConnectedModal();
      return;
    }

    pingMessages.clear();
    totalResponseTime = 0.0;

    setState(() {
      isPinging = true;
      numberOfPings = 0;
    });

    for (int i = 0; i < defaultTotalPings; i++) {
      // Use defaultTotalPings here
      if (!isPinging) {
        break;
      }

      final stopwatch = Stopwatch()..start();

      try {
        final socket = await Socket.connect(wifiGateway, PORT,
            timeout: Duration(seconds: 5));
        final responseTime = stopwatch.elapsedMilliseconds;
        socket.destroy();
        final result =
            "Reply from $wifiGateway: bytes=32 time=${responseTime}ms TTL=55";
        pingMessages.add(result);

        setState(() {
          numberOfPings = i + 1;
          totalResponseTime += responseTime;
        });
      } catch (error) {
        final result = "Request timed out";
        pingMessages.add(result);
        setState(() {
          numberOfPings = i + 1;
        });
      }

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      await Future.delayed(pingDelay);
    }

    setState(() {
      isPinging = false;
    });
    _savePreferences();

    // Show the ping results modal
    _showPingResultsModal();
  }

  // Function to show an alert dialog
  void _showPingResultsModal() {
    int dataLossCount =
        pingMessages.where((msg) => msg == "Request timed out").length;
    double dataLossPercentage = (dataLossCount / defaultTotalPings) * 100;

    if (dataLossPercentage == 0) {
      setState(() {
        message =
            "Congratulations! You have no packet loss in your WiFi network. If you are still having poor internet performance at this moment, then please contact our support team. +880 1927616110";
      });
    } else {
      setState(() {
        message =
            "We've detected packet loss on your personal Wi-Fi network. If we don't fix this issue, your internet performance could suffer.\n\n"
            "Few tips:\n"
            "- Please get close to your Wi-Fi router.\n"
            "- Make sure the router is not overloaded with too many users.\n"
            "- Get a better router.\n"
            "- Contact our support team. +880 1927616110\n";
      });
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          // Center the modal
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 8),
                  Text(
                    dataLossPercentage == 0
                        ? "No packet loss detected."
                        : "Packet loss detected: ${dataLossPercentage.toStringAsFixed(2)}%",
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          dataLossPercentage == 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),
                  // Display the message here
                  Text(message),

                  SizedBox(height: 8),
                  Visibility(
                    visible: dataLossPercentage > 0,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle the "Send a report" button click here
                      },
                      child: Text("Send report"),
                    ),
                  ),

                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Close the modal
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void stopPing() {
    setState(() {
      isPinging = false;
    });
  }

  double getAverageSuccessRate() {
    if (pingMessages.isEmpty) {
      return 0.0;
    }
    final successCount =
        pingMessages.where((msg) => msg.startsWith("Reply")).length;
    final totalMessages = pingMessages.length;
    return (successCount / totalMessages) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.wifi_find,
                        size: 32,
                        color: Colors.blue, // You can adjust the color
                      ),
                      SizedBox(
                        width: 8, // Add some spacing between the icon and text
                      ),
                      Text(
                        'Check WiFi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height:
                          8), // Add spacing between the existing widget and the description
                  Text(
                    'This section will help you understand if your wifi has connectivity issue. (This test is totally independent from your ISP.)',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 120, // Adjust the width as needed for your button size
              height: 120, // Adjust the height as needed for your button size
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.lightGreen
                        .withOpacity(0.7), // Light green with opacity
                    Colors.green, // Darker green
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: isPinging ? stopPing : establishSocketConnection,
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, // Make the button transparent
                  elevation: 0, // Remove the button elevation
                  shadowColor: Colors.transparent, // Remove the shadow
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPinging
                          ? Icons.stop
                          : Icons.play_arrow, // Play icon or stop icon
                      size: 32,
                      color: Colors.white, // Icon color
                    ),
                    SizedBox(
                      width: 8, // Add spacing between the icon and text
                    ),
                    Text(
                      isPinging ? 'Stop' : 'Start', // Button text
                      style: TextStyle(
                        fontSize: 16, // Adjust the text size as needed
                        color: Colors.white, // White text color
                        fontWeight: FontWeight.bold, // Bold font
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Card(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: TextField(
            //       controller: totalPingsController,
            //       keyboardType: TextInputType.number,
            //       decoration: InputDecoration(
            //         labelText: 'Enter the number of pings',
            //         hintText: 'Default: 30',
            //       ),
            //     ),
            //   ),
            // ),

            SizedBox(height: 0),
            // Card for Default Gateway with IconButton
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0), // Add margin here
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Default Gateway: $wifiGateway',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _launchDefaultGatewayUrl(); // Call the function to open the URL
                        },
                        icon: Icon(Icons.settings),
                        // Adjust icon size, color, etc. as needed
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sent',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$numberOfPings/$defaultTotalPings',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Received',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${pingMessages.where((msg) => msg.startsWith("Reply")).length}',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lost',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${pingMessages.where((msg) => msg == "Request timed out").length}',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 0),
            // Row for Average Time and Data Loss
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avg. Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${numberOfPings > 0 ? (totalResponseTime / numberOfPings).toStringAsFixed(2) : 0}ms',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Packet Loss',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${numberOfPings > 0 ? (pingMessages.where((msg) => msg == "Request timed out").length / numberOfPings * 100).toStringAsFixed(2) : 0}%',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 0),
            // Expanded Scrollable Card for Ping Messages
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.0), // Add padding here
                child: Scrollbar(
                  controller: _scrollController,
                  child: Card(
                    elevation: 2, // Add elevation to the card
                    child: Align(
                      alignment: Alignment
                          .center, // Align content both horizontally and vertically
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: pingMessages.length,
                            itemBuilder: (context, index) {
                              final message = pingMessages[index];
                              final isTimeout = message == "Request timed out";
                              final bgColor = isTimeout
                                  ? Colors.red[100]
                                  : Colors.transparent;
                              final textColor =
                                  isTimeout ? Colors.black : Colors.black;

                              return Container(
                                color: bgColor,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                          fontSize: 10, color: textColor),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      message,
                                      style: TextStyle(
                                          fontSize: 10, color: textColor),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
