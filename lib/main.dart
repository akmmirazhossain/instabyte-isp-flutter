import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 58, 183, 77)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int PORT = 80;
  int numberOfPings = 0;
  int totalPings = 5; // Total number of pings (changed to 5)
  Duration pingDelay = Duration(seconds: 1); // Delay between pings
  List<String> pingMessages = [];
  bool isPinging = false; // Flag to control pinging

  Future<void> establishSocketConnection() async {
    pingMessages.clear(); // Clear previous results

    setState(() {
      isPinging = true; // Set the flag to indicate pinging is active
      numberOfPings = 0; // Reset the number of pings
    });

    for (int i = 0; i < totalPings; i++) {
      if (!isPinging) {
        break; // If stop is pressed, exit the loop
      }

      try {
        final socket = await Socket.connect('192.168.0.1', PORT,
            timeout: Duration(seconds: 5));
        final responseTime = DateTime.now();
        socket.destroy();
        final elapsedTime =
            DateTime.now().difference(responseTime).inMilliseconds;
        final result =
            "Reply from 192.168.0.1: bytes=32 time=${elapsedTime}ms TTL=55";
        pingMessages.add(result);

        setState(() {
          numberOfPings = i + 1;
        });
      } catch (error) {
        final result = "Request timed out";
        pingMessages.add(result);
        setState(() {
          numberOfPings = i + 1;
        });
      }

      // Delay between pings
      await Future.delayed(pingDelay);
    }

    setState(() {
      isPinging = false; // Set the flag to indicate pinging is stopped
    });
  }

  void stopPing() {
    setState(() {
      isPinging = false; // Set the flag to stop pinging
    });
  }

  String getStatus() {
    if (isPinging) {
      return 'Running';
    } else if (numberOfPings == totalPings) {
      return 'Ended';
    } else {
      return 'About to Initiate'; // Updated to "About to Initiate"
    }
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Status: ${getStatus()}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Pings: $numberOfPings / $totalPings',
            ),
            ElevatedButton(
              onPressed: isPinging ? stopPing : establishSocketConnection,
              child: Text(isPinging ? 'Stop Pinging' : 'Start Pinging'),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.green,
                    child: Column(
                      children: [
                        Text(
                          'Ping Successes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Count: ${pingMessages.where((msg) => msg.startsWith("Reply")).length}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.red,
                    child: Column(
                      children: [
                        Text(
                          'Ping Failures',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Count: ${pingMessages.where((msg) => msg == "Request timed out").length}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Average Success Rate: ${getAverageSuccessRate().toStringAsFixed(2)}%',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pingMessages.length,
                itemBuilder: (context, index) {
                  return Text(pingMessages[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
